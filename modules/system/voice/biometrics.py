import os
import json
import time
import numpy as np
import scipy.fftpack as fftpack
from config import CONFIG_DIR, PROFILE_PATH, load_voice_config

# Standard styling colors
C_PRIMARY = "\033[38;5;75m"
C_SUCCESS = "\033[38;5;120m"
C_ERROR = "\033[38;5;196m"
C_HIGHLIGHT = "\033[38;5;220m"
C_MUTED = "\033[38;5;244m"
NC = "\033[0m"

def log(msg, style=C_PRIMARY):
    print(f"{style}[NIXI]{NC} {msg}")

def get_mel_filterbanks(num_filters, fft_len, sample_rate):
    low_freq_mel = 0
    high_freq_mel = 2595 * np.log10(1 + (sample_rate / 2) / 700)
    mel_points = np.linspace(low_freq_mel, high_freq_mel, num_filters + 2)
    hz_points = 700 * (10**(mel_points / 2595) - 1)
    bin_points = np.floor((fft_len + 1) * hz_points / sample_rate).astype(int)
    
    filters = np.zeros((num_filters, fft_len // 2 + 1))
    for m in range(1, num_filters + 1):
        f_m_minus = bin_points[m - 1]
        f_m = bin_points[m]
        f_m_plus = bin_points[m + 1]
        
        for k in range(f_m_minus, f_m):
            filters[m - 1, k] = (k - bin_points[m - 1]) / (bin_points[m] - bin_points[m - 1])
        for k in range(f_m, f_m_plus):
            filters[m - 1, k] = (bin_points[m + 1] - k) / (bin_points[m + 1] - bin_points[m])
            
    return filters

def extract_mfcc(audio, sample_rate=16000, num_mfcc=13, num_filters=26, fft_len=512):
    if len(audio.shape) > 1:
        audio = audio.mean(axis=1)
    # Pre-emphasis
    audio = np.append(audio[0], audio[1:] - 0.97 * audio[:-1])
    
    # Frame blocking
    frame_len = int(0.025 * sample_rate)
    frame_step = int(0.01 * sample_rate)
    audio_len = len(audio)
    
    num_frames = int(np.ceil(float(np.abs(audio_len - frame_len)) / frame_step)) + 1
    pad_audio_len = num_frames * frame_step + frame_len
    pad_audio = np.append(audio, np.zeros(pad_audio_len - audio_len))
    
    indices = np.tile(np.arange(0, frame_len), (num_frames, 1)) + np.tile(np.arange(0, num_frames * frame_step, frame_step), (frame_len, 1)).T
    frames = pad_audio[indices.astype(np.int32, copy=False)]
    
    # Hamming window
    frames *= np.hamming(frame_len)
    
    # FFT Power Spectrum
    mag_frames = np.absolute(np.fft.rfft(frames, fft_len))
    pow_frames = ((1.0 / frame_len) * (mag_frames ** 2))
    
    # Filterbanks
    filterbanks = get_mel_filterbanks(num_filters, fft_len, sample_rate)
    filterbank_energies = np.dot(pow_frames, filterbanks.T)
    filterbank_energies = np.where(filterbank_energies == 0, np.finfo(float).eps, filterbank_energies)
    
    log_filterbank_energies = 20 * np.log10(filterbank_energies)
    mfcc = fftpack.dct(log_filterbank_energies, type=2, axis=1, norm='ortho')[:, :num_mfcc]
    
    # Mean Normalization
    mfcc -= (np.mean(mfcc, axis=0) + 1e-8)
    return mfcc

def dtw_distance(s1, s2):
    """Computes Dynamic Time Warping distance between two MFCC feature sequences."""
    m, n = len(s1), len(s2)
    dtw_matrix = np.zeros((m+1, n+1))
    dtw_matrix[1:, 0] = np.inf
    dtw_matrix[0, 1:] = np.inf
    dtw_matrix[0, 0] = 0
    
    # Pairwise Euclidean distances
    diff = s1[:, None, :] - s2[None, :, :]
    dist_matrix = np.sqrt(np.sum(diff ** 2, axis=-1))
    
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            cost = dist_matrix[i-1, j-1]
            dtw_matrix[i, j] = cost + min(dtw_matrix[i-1, j],    # insertion
                                          dtw_matrix[i, j-1],    # deletion
                                          dtw_matrix[i-1, j-1])  # match
            
    return dtw_matrix[m, n] / (m + n)

def verify_speaker(audio_data, sample_rate=16000):
    """Verifies speaker against enrolled voice print templates."""
    if not os.path.exists(PROFILE_PATH):
        return 0
        
    try:
        with open(PROFILE_PATH, "r") as f:
            profile = json.load(f)
    except Exception:
        return 0
        
    mfcc = extract_mfcc(audio_data, sample_rate)
    new_mean = np.mean(mfcc, axis=0)
    new_std = np.std(mfcc, axis=0)
    
    best_score = 0
    
    if "templates" not in profile:
        # Compatibility with old single-template profile
        enrolled_mean = np.array(profile.get("mean", []))
        enrolled_std = np.array(profile.get("std", []))
        if len(enrolled_mean) == 0 or len(enrolled_std) == 0:
            return 0
        cosine_sim = np.dot(enrolled_mean, new_mean) / (np.linalg.norm(enrolled_mean) * np.linalg.norm(new_mean) + 1e-8)
        correlation = np.corrcoef(enrolled_std, new_std)[0, 1]
        if np.isnan(correlation): correlation = 0
        confidence = (cosine_sim * 0.7) + (correlation * 0.3)
        return max(0, min(100, int((confidence + 1) / 2 * 100)))
        
    for t in profile["templates"]:
        enrolled_mean = np.array(t["mean"])
        enrolled_std = np.array(t["std"])
        
        cosine_sim = np.dot(enrolled_mean, new_mean) / (np.linalg.norm(enrolled_mean) * np.linalg.norm(new_mean) + 1e-8)
        correlation = np.corrcoef(enrolled_std, new_std)[0, 1]
        if np.isnan(correlation):
            correlation = 0
            
        confidence = (cosine_sim * 0.7) + (correlation * 0.3)
        score = max(0, min(100, int((confidence + 1) / 2 * 100)))
        if score > best_score:
            best_score = score
            
    return best_score

def match_wakeword(audio_data, sample_rate=16000):
    """Computes local offline wake-word matching score using DTW on MFCCs."""
    if not os.path.exists(PROFILE_PATH):
        return 0
        
    try:
        with open(PROFILE_PATH, "r") as f:
            profile = json.load(f)
    except Exception:
        return 0
        
    # Check if wakeword templates exist
    wakeword_templates = profile.get("wakeword_templates", [])
    if not wakeword_templates:
        return 0
        
    mfcc = extract_mfcc(audio_data, sample_rate)
    
    best_dtw = float('inf')
    for template in wakeword_templates:
        enrolled_mfcc = np.array(template["mfcc"])
        dist = dtw_distance(mfcc, enrolled_mfcc)
        if dist < best_dtw:
            best_dtw = dist
            
    # Convert DTW distance to robust matching confidence percentage
    # In standard speech frames, distance of < 4.5 is an excellent match.
    score = max(0, 100 - int(best_dtw * 13))
    return score

def adapt_voice_profile(audio_data, sample_rate=16000):
    """Continuously adapts and refines the speaker biometrics profile based on verified inputs."""
    try:
        mfcc = extract_mfcc(audio_data, sample_rate)
        new_mean = np.mean(mfcc, axis=0).tolist()
        new_std = np.std(mfcc, axis=0).tolist()
        
        if not os.path.exists(PROFILE_PATH):
            return
            
        with open(PROFILE_PATH, "r") as f:
            profile = json.load(f)
            
        if "templates" not in profile:
            profile["templates"] = []
            
        if len(profile["templates"]) >= 5:
            profile["templates"].pop(0)  # pop oldest
            
        profile["templates"].append({
            "name": f"auto_adaptive_{int(time.time())}",
            "mean": new_mean,
            "std": new_std
        })
        
        with open(PROFILE_PATH, "w") as f:
            json.dump(profile, f, indent=4)
        log("Voice biometrics adapted and updated successfully.", C_MUTED)
    except Exception as e:
        log(f"Dynamic biometrics adaptation skipped: {e}", C_MUTED)
