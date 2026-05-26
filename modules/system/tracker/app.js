// ==========================================================================
// MANX ROUTINE TRACKER - FRONTEND ENGINE
// ==========================================================================

const API_BASE = ''; // Server serves frontend directly, so relative URLs work perfectly

// State Management
let currentState = {
    date: getTodayDateString(),
    focusScore: 0,
    reflectionScore: 0,
    tasksCompleted: 0,
    tasksTotal: 0,
    yesterdayDone: '',
    yesterdayImprove: '',
    todayDone: '',
    todayDoingNow: '',
    tomorrowDone: '',
    todayImprove: '',
    tasks: [],
    // Habits Correctness
    habits: {
        water: false,
        sleep: false,
        exercise: false,
        screen: false,
        read: false,
        revise: false,
        meditate: false,
        badHabitsAvoided: false
    },
    // Routine Timeline alignment
    routineAligned: 0,
    routineTimeline: [false, false, false, false, false, false],
    sleepHours: 8.0,
    screenHours: 4.0,
    // Academic Focus
    academicFocus: [],
    academicTasks: '',
    academicHours: 0,
    // VLSI Section
    vlsiType: 'dv',
    vlsiLanguages: [],
    vlsiMethodologies: [],
    vlsiTasks: '',
    vlsiHours: 0
};

let historyRecords = [];
let chartTrendInstance = null;
let chartAllocationInstance = null;
let isDirty = false;

// Set dirtiness flag
function markDirty() {
    isDirty = true;
}

// Confirmation helper for date switches
function confirmDateSwitch(callback) {
    if (isDirty) {
        if (confirm("Warning: You have unsaved changes on this page. Switching dates will discard your changes. Do you want to continue?")) {
            isDirty = false;
            callback();
        }
    } else {
        callback();
    }
}

// On Page Load
document.addEventListener('DOMContentLoaded', () => {
    initApp();
});

// Get formatted today string in local timezone
function getTodayDateString() {
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    const day = String(today.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// Format date for human reading
function formatHumanDate(dateStr) {
    const options = { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' };
    const date = new Date(dateStr + 'T00:00:00'); // Prevent timezone offset shift
    return date.toLocaleDateString('en-US', options);
}

// Initializing UI & Bindings
function initApp() {
    // Setup date picker default
    const datePicker = document.getElementById('datePicker');
    datePicker.value = currentState.date;

    // Load initial data
    loadDateData(currentState.date);
    refreshHistory();

    // --- EVENT LISTENERS ---
    
    // Date changes wrapped in override safety shields
    datePicker.addEventListener('change', (e) => {
        const selectedDate = e.target.value;
        confirmDateSwitch(() => {
            currentState.date = selectedDate;
            loadDateData(selectedDate);
        });
    });

    document.getElementById('btnPrevDay').addEventListener('click', () => {
        confirmDateSwitch(() => adjustDate(-1));
    });
    document.getElementById('btnNextDay').addEventListener('click', () => {
        confirmDateSwitch(() => adjustDate(1));
    });
    document.getElementById('btnGoToday').addEventListener('click', () => {
        confirmDateSwitch(() => {
            const todayStr = getTodayDateString();
            datePicker.value = todayStr;
            currentState.date = todayStr;
            loadDateData(todayStr);
        });
    });

    // Range Sliders with dirty tracking
    const inputFocus = document.getElementById('inputFocus');
    const inputReflection = document.getElementById('inputReflection');
    
    inputFocus.addEventListener('input', (e) => {
        markDirty();
        document.getElementById('badgeFocus').innerText = `${e.target.value} / 10`;
        document.getElementById('valFocus').innerText = e.target.value;
    });
    
    inputReflection.addEventListener('input', (e) => {
        markDirty();
        document.getElementById('badgeReflection').innerText = `${e.target.value} / 10`;
    });

    const inputSleep = document.getElementById('inputSleep');
    const inputScreen = document.getElementById('inputScreen');
    
    if (inputSleep) {
        inputSleep.addEventListener('input', (e) => {
            markDirty();
            document.getElementById('badgeSleep').innerText = `${parseFloat(e.target.value).toFixed(1)} hrs`;
        });
    }

    if (inputScreen) {
        inputScreen.addEventListener('input', (e) => {
            markDirty();
            document.getElementById('badgeScreen').innerText = `${parseFloat(e.target.value).toFixed(1)} hrs`;
        });
    }

    // Textarea and Input dirty listeners
    const textareas = ['inputYesterdayDone', 'inputYesterdayImprove', 'inputTodayDone', 'inputTodayDoingNow', 'inputTomorrowDone', 'inputTodayImprove', 'inputAcademicTasks', 'inputVlsiTasks'];
    textareas.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('input', markDirty);
    });

    // Habit Correctness Grid Bindings
    const habitsIds = ['habitWater', 'habitSleep', 'habitExercise', 'habitScreen', 'habitRead', 'habitRevise', 'habitMeditate', 'habitBadHabitsAvoided'];
    habitsIds.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.addEventListener('change', () => {
                markDirty();
                updateHabitsProgress();
            });
        }
    });

    // Routine timeline checkboxes bindings
    document.querySelectorAll('input[name="routineSlots"]').forEach(box => {
        box.addEventListener('change', () => {
            markDirty();
            updateRoutineProgress();
        });
    });

    // Academic coursework quick toggles
    document.querySelectorAll('.btn-academic-toggle').forEach(btn => {
        btn.addEventListener('click', (e) => {
            markDirty();
            const hoursVal = parseFloat(e.target.getAttribute('data-val'));
            document.getElementById('inputAcademicHours').value = hoursVal;
            document.getElementById('valAcademicHours').innerText = hoursVal;
        });
    });

    document.getElementById('inputAcademicHours').addEventListener('input', (e) => {
        markDirty();
        document.getElementById('valAcademicHours').innerText = e.target.value || 0;
    });

    document.querySelectorAll('input[name="academicFocus"]').forEach(box => {
        box.addEventListener('change', markDirty);
    });

    // VLSI quick hours toggles
    document.querySelectorAll('.btn-hour-toggle').forEach(btn => {
        btn.addEventListener('click', (e) => {
            markDirty();
            const hoursVal = parseFloat(e.target.getAttribute('data-val'));
            document.getElementById('inputVlsiHours').value = hoursVal;
            document.getElementById('valVlsiHours').innerText = hoursVal;
        });
    });

    document.getElementById('inputVlsiHours').addEventListener('input', (e) => {
        markDirty();
        document.getElementById('valVlsiHours').innerText = e.target.value || 0;
    });

    // VLSI discipline selections
    document.querySelectorAll('input[name="vlsiType"]').forEach(radio => {
        radio.addEventListener('change', (e) => {
            markDirty();
            document.querySelectorAll('.discipline-card').forEach(c => c.classList.remove('active'));
            e.target.closest('.discipline-card').classList.add('active');
            
            // Adjust card view
            const vlsiLangSec = document.getElementById('vlsiLanguagesSection');
            const vlsiMethSec = document.getElementById('vlsiMethodologiesSection');
            if (e.target.value === 'none') {
                vlsiLangSec.style.opacity = '0.4';
                vlsiMethSec.style.opacity = '0.4';
            } else {
                vlsiLangSec.style.opacity = '1';
                vlsiMethSec.style.opacity = '1';
            }
        });
    });

    document.querySelectorAll('input[name="vlsiLanguages"]').forEach(box => {
        box.addEventListener('change', markDirty);
    });

    document.querySelectorAll('input[name="vlsiMethodologies"]').forEach(box => {
        box.addEventListener('change', markDirty);
    });

    // Todo functionality
    document.getElementById('btnAddTodo').addEventListener('click', () => {
        markDirty();
        addTodo();
    });
    document.getElementById('todoInput').addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            markDirty();
            addTodo();
        }
    });

    // Footer actions
    document.getElementById('btnSave').addEventListener('click', saveCurrentData);
    document.getElementById('btnReset').addEventListener('click', resetFormValues);

    // Tab Navigation switching
    document.querySelectorAll('.tab-link').forEach(tab => {
        tab.addEventListener('click', (e) => {
            document.querySelectorAll('.tab-link').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            
            tab.classList.add('active');
            const tabId = tab.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');

            // Force charts redraw when arriving at analytics tab
            if (tabId === 'tabAnalytics') {
                setTimeout(() => {
                    renderAnalyticsCharts();
                }, 100);
            }
        });
    });

    // Eye Saver mode
    const warmToggle = document.getElementById('btnWarmToggle');
    if (warmToggle) {
        warmToggle.addEventListener('click', () => {
            document.body.classList.toggle('warm-mode');
            const isActive = document.body.classList.contains('warm-mode');
            localStorage.setItem('manxWarmMode', isActive ? 'true' : 'false');
            if (isActive) {
                warmToggle.classList.add('active');
            } else {
                warmToggle.classList.remove('active');
            }
        });
        if (localStorage.getItem('manxWarmMode') === 'true') {
            document.body.classList.add('warm-mode');
            warmToggle.classList.add('active');
        }
    }
}

// Adjust date by offset (+1 or -1 days)
function adjustDate(daysOffset) {
    const picker = document.getElementById('datePicker');
    const current = new Date(currentState.date + 'T00:00:00');
    current.setDate(current.getDate() + daysOffset);
    
    const year = current.getFullYear();
    const month = String(current.getMonth() + 1).padStart(2, '0');
    const day = String(current.getDate()).padStart(2, '0');
    const nextDateStr = `${year}-${month}-${day}`;
    
    picker.value = nextDateStr;
    currentState.date = nextDateStr;
    loadDateData(nextDateStr);
}

// Fetch details for YYYY-MM-DD
async function loadDateData(dateStr) {
    document.getElementById('saveStatus').innerText = "Loading local record...";
    try {
        const response = await fetch(`${API_BASE}/api/data?date=${dateStr}`);
        if (!response.ok) throw new Error('API query failed');
        
        const data = await response.json();
        populateForm(data);
        document.getElementById('saveStatus').innerText = "Data synced and secure.";
    } catch (err) {
        showToast('error', 'Error loading logs from secure disk.');
        document.getElementById('saveStatus').innerText = "Error syncing local database.";
    }
}

// Dynamic Habits Calculations
function updateHabitsProgress() {
    const list = {
        water: 'habitWater',
        sleep: 'habitSleep',
        exercise: 'habitExercise',
        screen: 'habitScreen',
        read: 'habitRead',
        revise: 'habitRevise',
        meditate: 'habitMeditate',
        badHabitsAvoided: 'habitBadHabitsAvoided'
    };
    
    let completed = 0;
    const total = Object.keys(list).length;
    
    Object.keys(list).forEach(key => {
        const el = document.getElementById(list[key]);
        if (el && el.checked) {
            completed++;
        }
    });
    
    const percentage = Math.round((completed / total) * 100);
    document.getElementById('badgeHabits').innerText = `${percentage}% Complete`;
    document.getElementById('valHabits').innerText = completed;
}

// Routine Waveform calculations
function updateRoutineProgress() {
    const boxes = document.querySelectorAll('input[name="routineSlots"]');
    let checkedCount = 0;
    boxes.forEach(box => {
        if (box.checked) checkedCount++;
    });
    const percentage = Math.round((checkedCount / boxes.length) * 100);
    document.getElementById('badgeRoutine').innerText = `${percentage}% Routine Match`;
    return percentage;
}

// Put JSON response into the form fields
function populateForm(data) {
    isDirty = false; // Reset dirtiness when mapping a saved payload

    // Sliders
    document.getElementById('inputFocus').value = data.focusScore || 0;
    document.getElementById('badgeFocus').innerText = `${data.focusScore || 0} / 10`;
    document.getElementById('valFocus').innerText = data.focusScore || 0;

    document.getElementById('inputReflection').value = data.reflectionScore || 0;
    document.getElementById('badgeReflection').innerText = `${data.reflectionScore || 0} / 10`;

    const sleepHours = data.sleepHours !== undefined ? data.sleepHours : 8.0;
    const screenHours = data.screenHours !== undefined ? data.screenHours : 4.0;
    
    const sliderSleep = document.getElementById('inputSleep');
    if (sliderSleep) {
        sliderSleep.value = sleepHours;
        document.getElementById('badgeSleep').innerText = `${parseFloat(sleepHours).toFixed(1)} hrs`;
    }
    
    const sliderScreen = document.getElementById('inputScreen');
    if (sliderScreen) {
        sliderScreen.value = screenHours;
        document.getElementById('badgeScreen').innerText = `${parseFloat(screenHours).toFixed(1)} hrs`;
    }

    // Text areas
    document.getElementById('inputYesterdayDone').value = data.yesterdayDone || '';
    document.getElementById('inputYesterdayImprove').value = data.yesterdayImprove || '';
    document.getElementById('inputTodayDone').value = data.todayDone || '';
    document.getElementById('inputTodayDoingNow').value = data.todayDoingNow || '';
    document.getElementById('inputTomorrowDone').value = data.tomorrowDone || '';
    document.getElementById('inputTodayImprove').value = data.todayImprove || '';

    // Checklist
    currentState.tasks = data.tasks || [];
    renderTodoList();

    // Habit Correctness Checkboxes Mapping
    const habits = data.habits || {};
    const list = {
        water: 'habitWater',
        sleep: 'habitSleep',
        exercise: 'habitExercise',
        screen: 'habitScreen',
        read: 'habitRead',
        revise: 'habitRevise',
        meditate: 'habitMeditate',
        badHabitsAvoided: 'habitBadHabitsAvoided'
    };
    Object.keys(list).forEach(key => {
        const el = document.getElementById(list[key]);
        if (el) el.checked = !!habits[key];
    });
    updateHabitsProgress();

    // Map 6 routine slots
    const routineTimeline = data.routineTimeline || [false, false, false, false, false, false];
    const routineBoxes = document.querySelectorAll('input[name="routineSlots"]');
    routineBoxes.forEach((box, idx) => {
        if (idx < routineTimeline.length) {
            box.checked = !!routineTimeline[idx];
        } else {
            box.checked = false;
        }
    });
    updateRoutineProgress();

    // Academic Focus Checkboxes Mapping
    const activeAcad = data.academicFocus || [];
    document.querySelectorAll('input[name="academicFocus"]').forEach(box => {
        box.checked = activeAcad.includes(box.value);
    });

    document.getElementById('inputAcademicTasks').value = data.academicTasks || '';
    document.getElementById('inputAcademicHours').value = data.academicHours || 0;
    document.getElementById('valAcademicHours').innerText = data.academicHours || 0;

    // VLSI
    const discipline = data.vlsiType || 'dv';
    document.querySelectorAll('input[name="vlsiType"]').forEach(radio => {
        if (radio.value === discipline) {
            radio.checked = true;
            // Update wrapper card classes
            document.querySelectorAll('.discipline-card').forEach(c => c.classList.remove('active'));
            radio.closest('.discipline-card').classList.add('active');
        }
    });

    // Adjust card opacity
    const vlsiLangSec = document.getElementById('vlsiLanguagesSection');
    const vlsiMethSec = document.getElementById('vlsiMethodologiesSection');
    if (discipline === 'none') {
        vlsiLangSec.style.opacity = '0.4';
        vlsiMethSec.style.opacity = '0.4';
    } else {
        vlsiLangSec.style.opacity = '1';
        vlsiMethSec.style.opacity = '1';
    }

    // Languages checkboxes
    const activeLangs = data.vlsiLanguages || [];
    document.querySelectorAll('input[name="vlsiLanguages"]').forEach(box => {
        box.checked = activeLangs.includes(box.value);
    });

    // Methodologies checkboxes
    const activeMeths = data.vlsiMethodologies || [];
    document.querySelectorAll('input[name="vlsiMethodologies"]').forEach(box => {
        box.checked = activeMeths.includes(box.value);
    });

    document.getElementById('inputVlsiTasks').value = data.vlsiTasks || '';
    document.getElementById('inputVlsiHours').value = data.vlsiHours || 0;
    document.getElementById('valVlsiHours').innerText = data.vlsiHours || 0;
}

// Fetch chronological entries for sidebar and graphs
async function refreshHistory() {
    try {
        const response = await fetch(`${API_BASE}/api/history`);
        if (!response.ok) throw new Error('API history call failed');
        
        historyRecords = await response.json();
        renderSidebarHistory();
        calculateDashboardMetrics();
    } catch (err) {
        console.error('History fetch failed', err);
    }
}

// Populate Sidebar Timeline
// Populate Sidebar Timeline with safety checks
function renderSidebarHistory() {
    const list = document.getElementById('historyList');
    list.innerHTML = '';

    if (historyRecords.length === 0) {
        list.innerHTML = `<div class="history-placeholder">No logged data yet. Start tracking today!</div>`;
        return;
    }

    // Reverse history to show newest at the top
    const displayList = [...historyRecords].reverse();

    displayList.forEach(item => {
        const row = document.createElement('div');
        row.className = `history-item ${item.date === currentState.date ? 'active' : ''}`;
        
        // Humanize display date
        const cleanDate = formatHumanDate(item.date);
        
        row.innerHTML = `
            <span class="hist-date">${cleanDate}</span>
            <div class="hist-metrics">
                <span class="hist-badge focus">🎯 ${item.focusScore}</span>
                ${item.vlsiHours > 0 ? `<span class="hist-badge vlsi">⚡ ${item.vlsiHours}h</span>` : ''}
            </div>
        `;

        row.addEventListener('click', () => {
            confirmDateSwitch(() => {
                currentState.date = item.date;
                document.getElementById('datePicker').value = item.date;
                loadDateData(item.date);
                // Re-render history list to update active highlight
                document.querySelectorAll('.history-item').forEach(el => el.classList.remove('active'));
                row.classList.add('active');
            });
        });

        list.appendChild(row);
    });
}

// Calculate rolling 7d metrics and streaks
function calculateDashboardMetrics() {
    if (historyRecords.length === 0) return;

    // Focus 7d avg
    const last7 = historyRecords.slice(-7);
    const focusSum = last7.reduce((sum, item) => sum + item.focusScore, 0);
    const avgFocus = (focusSum / last7.length).toFixed(1);
    document.getElementById('statWeeklyAvg').innerText = `${avgFocus} / 10`;

    // VLSI 7d hours sum
    const vlsiHoursSum = last7.reduce((sum, item) => sum + item.vlsiHours, 0);
    document.getElementById('statVlsiHours').innerText = `${vlsiHoursSum} hrs`;

    // Academic hours 7d sum
    const academicHoursSum = last7.reduce((sum, item) => sum + (item.academicHours || 0), 0);
    document.getElementById('statTasksComp').innerText = `${academicHoursSum} hrs`;

    // Streak calculation (consecutive dates including today/yesterday)
    let streak = 0;
    const sortedDates = historyRecords.map(r => r.date).sort();
    
    if (sortedDates.length > 0) {
        let currentStreak = 1;
        for (let i = 1; i < sortedDates.length; i++) {
            const prev = new Date(sortedDates[i - 1] + 'T00:00:00');
            const curr = new Date(sortedDates[i] + 'T00:00:00');
            const diffTime = Math.abs(curr - prev);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            
            if (diffDays === 1) {
                currentStreak++;
            } else if (diffDays > 1) {
                currentStreak = 1;
            }
        }
        streak = currentStreak;
    }
    document.getElementById('statStreak').innerText = `${streak} days`;
}

// Save all form values into home folder YYYY-MM-DD.json
async function saveCurrentData() {
    document.getElementById('saveStatus').innerText = "Syncing local database...";
    
    // Gather Habits state
    const habits = {
        water: document.getElementById('habitWater').checked,
        sleep: document.getElementById('habitSleep').checked,
        exercise: document.getElementById('habitExercise').checked,
        screen: document.getElementById('habitScreen').checked,
        read: document.getElementById('habitRead').checked,
        revise: document.getElementById('habitRevise').checked,
        meditate: document.getElementById('habitMeditate').checked,
        badHabitsAvoided: document.getElementById('habitBadHabitsAvoided').checked
    };

    // Gather Routine slots state
    const routineTimeline = [];
    document.querySelectorAll('input[name="routineSlots"]').forEach(box => {
        routineTimeline.push(box.checked);
    });
    const routineAligned = updateRoutineProgress();

    // Gather Academic coursework checkboxes
    const academicFocus = [];
    document.querySelectorAll('input[name="academicFocus"]:checked').forEach(box => {
        academicFocus.push(box.value);
    });

    // Gather VLSI languages checkboxes
    const languages = [];
    document.querySelectorAll('input[name="vlsiLanguages"]:checked').forEach(box => {
        languages.push(box.value);
    });

    // Gather VLSI methodologies checkboxes
    const methodologies = [];
    document.querySelectorAll('input[name="vlsiMethodologies"]:checked').forEach(box => {
        methodologies.push(box.value);
    });

    // Calculate completed vs total tasks
    const total = currentState.tasks.length;
    const completed = currentState.tasks.filter(t => t.completed).length;

    // Compile active state
    const payload = {
        date: currentState.date,
        focusScore: parseInt(document.getElementById('inputFocus').value),
        reflectionScore: parseInt(document.getElementById('valHabits').innerText), // Map habit correctness score here
        tasksCompleted: completed,
        tasksTotal: total,
        yesterdayDone: document.getElementById('inputYesterdayDone').value,
        yesterdayImprove: document.getElementById('inputYesterdayImprove').value,
        todayDone: document.getElementById('inputTodayDone').value,
        todayDoingNow: document.getElementById('inputTodayDoingNow').value,
        tomorrowDone: document.getElementById('inputTomorrowDone').value,
        todayImprove: document.getElementById('inputTodayImprove').value,
        tasks: currentState.tasks,
        // Habits & Academics & Routine Chrono
        habits: habits,
        routineTimeline: routineTimeline,
        routineAligned: routineAligned,
        sleepHours: parseFloat(document.getElementById('inputSleep').value || 8),
        screenHours: parseFloat(document.getElementById('inputScreen').value || 4),
        academicFocus: academicFocus,
        academicTasks: document.getElementById('inputAcademicTasks').value,
        academicHours: parseFloat(document.getElementById('inputAcademicHours').value || 0),
        // VLSI Section
        vlsiType: document.querySelector('input[name="vlsiType"]:checked').value,
        vlsiLanguages: languages,
        vlsiMethodologies: methodologies,
        vlsiTasks: document.getElementById('inputVlsiTasks').value,
        vlsiHours: parseFloat(document.getElementById('inputVlsiHours').value || 0)
    };

    try {
        const response = await fetch(`${API_BASE}/api/save`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!response.ok) throw new Error('API save operation failed');

        isDirty = false; // Reset dirtiness on success save
        showToast('success', 'Tracker securely saved to local disk!');
        document.getElementById('saveStatus').innerText = "All data secure and locally synced.";
        
        // Refresh sidebar and dashboard statistics
        await refreshHistory();
    } catch (err) {
        showToast('error', 'Error writing routine logs to hard disk.');
        document.getElementById('saveStatus').innerText = "Database sync failed.";
    }
}

// Reset form
function resetFormValues() {
    if (confirm('Are you sure you want to clear this entry? (Will reset values on screen back to clean defaults)')) {
        populateForm({
            date: currentState.date,
            focusScore: 0,
            reflectionScore: 0,
            tasksCompleted: 0,
            tasksTotal: 0,
            yesterdayDone: '',
            yesterdayImprove: '',
            todayDone: '',
            todayDoingNow: '',
            tomorrowDone: '',
            todayImprove: '',
            tasks: [],
            habits: {
                water: false,
                sleep: false,
                exercise: false,
                screen: false,
                read: false,
                revise: false,
                meditate: false,
                badHabitsAvoided: false
            },
            routineAligned: 0,
            routineTimeline: [false, false, false, false, false, false],
            sleepHours: 8.0,
            screenHours: 4.0,
            academicFocus: [],
            academicTasks: '',
            academicHours: 0,
            vlsiType: 'dv',
            vlsiLanguages: [],
            vlsiMethodologies: [],
            vlsiTasks: '',
            vlsiHours: 0
        });
        markDirty(); // Reset acts as a change state
        showToast('info', 'Screen values reset. Press Save to write blank values to disk.');
    }
}

// --- TODO CHECKLIST FUNCTIONS ---

function renderTodoList() {
    const list = document.getElementById('todoList');
    list.innerHTML = '';

    const completed = currentState.tasks.filter(t => t.completed).length;
    const total = currentState.tasks.length;

    // Update metrics top bar (completions tracked in sidebar now)

    if (currentState.tasks.length === 0) {
        list.innerHTML = `<li class="history-placeholder">No action items added yet. Outlining tasks drives alignment!</li>`;
        return;
    }

    currentState.tasks.forEach(task => {
        const li = document.createElement('li');
        li.className = `todo-item ${task.completed ? 'completed' : ''}`;

        li.innerHTML = `
            <div class="todo-item-left">
                <div class="todo-checkbox">
                    ${task.completed ? '<span class="material-symbols-outlined" style="font-size:14px; font-weight:900;">done</span>' : ''}
                </div>
                <span class="todo-text">${task.text}</span>
            </div>
            <button class="btn-todo-delete" title="Delete Task">
                <span class="material-symbols-outlined" style="font-size:18px;">delete</span>
            </button>
        `;

        // Toggle checkbox state on left click
        li.querySelector('.todo-item-left').addEventListener('click', () => {
            task.completed = !task.completed;
            renderTodoList();
        });

        // Delete task
        li.querySelector('.btn-todo-delete').addEventListener('click', (e) => {
            e.stopPropagation();
            currentState.tasks = currentState.tasks.filter(t => t.id !== task.id);
            renderTodoList();
        });

        list.appendChild(li);
    });
}

function addTodo() {
    const input = document.getElementById('todoInput');
    const text = input.value.trim();
    if (!text) return;

    currentState.tasks.push({
        id: Date.now().toString(),
        text: text,
        completed: false
    });

    input.value = '';
    renderTodoList();
}

// --- ANALYTICS CHART DRAWING ---

function renderAnalyticsCharts() {
    if (historyRecords.length === 0) return;

    const ctxTrend = document.getElementById('chartTrend').getContext('2d');
    const ctxAlloc = document.getElementById('chartAllocation').getContext('2d');

    // Destroy old charts to prevent duplicate bugs
    if (chartTrendInstance) chartTrendInstance.destroy();
    if (chartAllocationInstance) chartAllocationInstance.destroy();

    // Pull last 7 logged days
    const last7 = historyRecords.slice(-7);
    const labels = last7.map(d => formatHumanDate(d.date).replace(', 2026', ''));
    const focusData = last7.map(d => d.focusScore);
    const reflectionData = last7.map(d => d.reflectionScore || 0); // Represents Habit Score out of 8
    const vlsiHoursData = last7.map(d => d.vlsiHours || 0);
    const academicHoursData = last7.map(d => d.academicHours || 0);
    const routineData = last7.map(d => (d.routineAligned || 0) / 10); // Scaled to 0-10

    // Chart 1: Focus Level & Habit Correctness Progress Line Chart
    chartTrendInstance = new Chart(ctxTrend, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Focus Score (0-10)',
                    data: focusData,
                    borderColor: '#ff5722',
                    backgroundColor: 'rgba(255, 87, 34, 0.1)',
                    borderWidth: 3,
                    tension: 0.3,
                    fill: true,
                    pointBackgroundColor: '#ff5722',
                    pointBorderColor: '#fff',
                    pointRadius: 5
                },
                {
                    label: 'Habit Correctness Score (0-8)',
                    data: reflectionData,
                    borderColor: '#00e676',
                    backgroundColor: 'rgba(0, 230, 118, 0.08)',
                    borderWidth: 3,
                    tension: 0.3,
                    fill: true,
                    pointBackgroundColor: '#00e676',
                    pointBorderColor: '#fff',
                    pointRadius: 5
                },
                {
                    label: 'Routine Chrono-Match (0-100%)',
                    data: routineData,
                    borderColor: '#00bcd4',
                    backgroundColor: 'rgba(0, 188, 212, 0.05)',
                    borderWidth: 3,
                    tension: 0.3,
                    fill: true,
                    pointBackgroundColor: '#00bcd4',
                    pointBorderColor: '#fff',
                    pointRadius: 5
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    labels: { color: '#fff', font: { family: 'Outfit', weight: 'bold' } }
                }
            },
            scales: {
                y: {
                    min: 0,
                    max: 10,
                    grid: { color: 'rgba(255, 255, 255, 0.05)' },
                    ticks: { color: '#8892b0', font: { family: 'JetBrains Mono' } }
                },
                x: {
                    grid: { display: false },
                    ticks: { color: '#8892b0', font: { family: 'JetBrains Mono' } }
                }
            }
        }
    });

    // Chart 2: Double-Bar Chart displaying Study vs Silicon Hour Allocation
    chartAllocationInstance = new Chart(ctxAlloc, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Academic Studies (Hours)',
                    data: academicHoursData,
                    backgroundColor: 'rgba(255, 183, 77, 0.7)',
                    borderColor: '#ffb74d',
                    borderWidth: 2,
                    borderRadius: 4
                },
                {
                    label: 'Silicon & VLSI Design (Hours)',
                    data: vlsiHoursData,
                    backgroundColor: 'rgba(0, 229, 255, 0.7)',
                    borderColor: '#00e5ff',
                    borderWidth: 2,
                    borderRadius: 4
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    labels: { color: '#fff', font: { family: 'Outfit', weight: 'bold' } }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: 'rgba(255, 255, 255, 0.05)' },
                    ticks: { color: '#8892b0', font: { family: 'JetBrains Mono' } }
                },
                x: {
                    grid: { display: false },
                    ticks: { color: '#8892b0', font: { family: 'JetBrains Mono' } }
                }
            }
        }
    });
}

// --- DYNAMIC TOAST SYSTEM ---

function showToast(type, text) {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    let icon = 'info';
    if (type === 'success') icon = 'check_circle';
    if (type === 'error') icon = 'cancel';

    toast.innerHTML = `
        <span class="material-symbols-outlined">${icon}</span>
        <span class="toast-text">${text}</span>
    `;

    container.appendChild(toast);

    // Animate out and remove from DOM after 3.2 seconds
    setTimeout(() => {
        toast.style.transform = 'translateX(120%)';
        toast.style.transition = 'transform 0.4s cubic-bezier(0.4, 0, 0.2, 1)';
        setTimeout(() => {
            toast.remove();
        }, 400);
    }, 2800);
}
