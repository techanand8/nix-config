{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.startup.homepage" = "file:///home/mayank-anand/.config/firefox/newtab.html";
        "browser.newtabpage.enabled" = false;
        "browser.newtab.preload" = false;
        "browser.startup.page" = 1; # Show homepage on startup
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "signon.rememberSignons" = false;
        "media.ffmpeg.vaapi.enabled" = true; # High-performance hardware acceleration
        "browser.uidensity" = 1; # compact but readable
        "layout.css.prefers-color-scheme.content-override" = 0; # prefer dark websites
      };

      userChrome = ''
        /* Clean premium Firefox UI: stable and readable */

        @import url("file:///home/mayank-anand/.config/firefox/theme.css");

        :root {
          --mx-bg: #0b0f14 !important;
          --mx-surface: #111823 !important;
          --mx-surface-2: #141d2a !important;
          --mx-accent: #7c3aed !important;
          --mx-accent-soft: rgba(124, 58, 237, 0.25) !important;
          --mx-border: rgba(255, 255, 255, 0.1) !important;
          --mx-text: #e5e7eb !important;
          --mx-text-muted: #9aa4b2 !important;
        }

        #main-window,
        #navigator-toolbox,
        #nav-bar,
        #TabsToolbar {
          background: var(--mx-bg) !important;
        }

        #navigator-toolbox {
          border-bottom: 1px solid var(--mx-border) !important;
        }

        #TabsToolbar {
          padding: 4px 8px 0 8px !important;
        }

        .tabbrowser-tab {
          padding-inline: 4px !important;
        }

        .tab-background {
          border-radius: 10px 10px 0 0 !important;
          border: 1px solid transparent !important;
          margin-block: 2px 0 !important;
          background: transparent !important;
          transition: background-color 0.15s ease, border-color 0.15s ease !important;
        }

        .tab-background[selected="true"] {
          background: var(--mx-surface) !important;
          border-color: var(--mx-border) !important;
          border-bottom-color: transparent !important;
          box-shadow: 0 6px 16px rgba(0, 0, 0, 0.25) !important;
        }

        .tab-background:hover:not([selected="true"]) {
          background: var(--mx-surface-2) !important;
          border-color: rgba(255, 255, 255, 0.14) !important;
        }

        #nav-bar {
          padding: 6px 10px !important;
          border: none !important;
          box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.02) !important;
        }

        #urlbar-background {
          background: var(--mx-surface) !important;
          border: 1px solid var(--mx-border) !important;
          border-radius: 10px !important;
          transition: border-color 0.15s ease, box-shadow 0.15s ease !important;
        }

        #urlbar[focused="true"] > #urlbar-background {
          border-color: var(--mx-accent) !important;
          box-shadow: 0 0 0 3px var(--mx-accent-soft) !important;
        }

        #urlbar-input,
        #urlbar .urlbar-input {
          color: var(--mx-text) !important;
          font-family: "Inter", "JetBrains Mono", sans-serif !important;
          font-size: 13px !important;
        }

        .tab-label {
          color: var(--mx-text) !important;
        }

        .tab-text,
        .tab-label-container {
          font-family: "Inter", sans-serif !important;
          font-size: 12px !important;
        }

        #PersonalToolbar {
          background: var(--mx-bg) !important;
          border-top: 1px solid rgba(255, 255, 255, 0.04) !important;
        }

        .toolbarbutton-1 {
          border-radius: 8px !important;
        }
      '';
    };
  };

  home.file.".config/firefox/newtab.html".text = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>MANX Start</title>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
      <style>
        :root {
          --bg: #0a0f16;
          --bg-2: #101826;
          --card: rgba(19, 28, 42, 0.75);
          --border: rgba(255, 255, 255, 0.12);
          --text: #e5e7eb;
          --muted: #9aa4b2;
          --accent: #7c3aed;
          --accent-soft: rgba(124, 58, 237, 0.22);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
          color: var(--text);
          font-family: 'Inter', -apple-system, sans-serif;
          background-color: var(--bg);
          background-image: 
            radial-gradient(circle at 15% 15%, rgba(124, 58, 237, 0.08) 0%, transparent 25%),
            radial-gradient(circle at 85% 85%, rgba(124, 58, 237, 0.05) 0%, transparent 25%);
          min-height: 100vh;
          display: flex;
          justify-content: center;
          align-items: center;
          padding: 20px;
        }

        .app {
          width: 100%;
          max-width: 840px;
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .panel {
          background: var(--card);
          backdrop-filter: blur(12px);
          border: 1px solid var(--border);
          border-radius: 16px;
          padding: 32px;
          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
        }

        .hero {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        .title {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        h1 {
          font-size: 28px;
          font-weight: 700;
          letter-spacing: -0.5px;
          background: linear-gradient(135deg, #fff 0%, #a78bfa 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }

        .clock {
          font-family: 'JetBrains Mono', monospace;
          font-size: 16px;
          color: var(--muted);
          background: var(--bg-2);
          padding: 6px 12px;
          border-radius: 8px;
          border: 1px solid var(--border);
        }

        .search-row {
          display: grid;
          grid-template-columns: 1fr 140px;
          gap: 12px;
        }

        .search-input {
          background: var(--bg-2);
          border: 1px solid var(--border);
          border-radius: 10px;
          padding: 14px 18px;
          color: #fff;
          font-size: 15px;
          width: 100%;
          outline: none;
          transition: all 0.2s;
        }

        .search-input:focus {
          border-color: var(--accent);
          box-shadow: 0 0 0 3px var(--accent-soft);
        }

        .engine-select {
          background: var(--bg-2);
          border: 1px solid var(--border);
          border-radius: 10px;
          padding: 0 12px;
          color: var(--muted);
          font-size: 14px;
          outline: none;
          cursor: pointer;
        }

        .grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 24px;
        }

        h2 {
          font-size: 14px;
          text-transform: uppercase;
          letter-spacing: 1px;
          color: var(--muted);
          margin-bottom: 20px;
        }

        .links {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .link {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 12px 16px;
          border-radius: 10px;
          text-decoration: none;
          color: var(--text);
          transition: all 0.2s;
          border: 1px solid transparent;
        }

        .link:hover {
          background: var(--accent-soft);
          border-color: rgba(124, 58, 237, 0.3);
          transform: translateX(4px);
        }

        .link span { font-weight: 500; font-size: 15px; }
        .link small { color: var(--muted); font-size: 12px; }

        .quick-add {
          display: flex;
          flex-direction: column;
          gap: 12px;
        }

        .quick-add input {
          background: var(--bg-2);
          border: 1px solid var(--border);
          border-radius: 10px;
          padding: 12px;
          color: #fff;
          outline: none;
        }

        .quick-add button {
          background: var(--accent);
          color: #fff;
          border: none;
          border-radius: 10px;
          padding: 12px;
          font-weight: 600;
          cursor: pointer;
          transition: filter 0.2s;
          margin-top: 4px;
        }

        .quick-add button:hover {
          filter: brightness(1.1);
        }

        @media (max-width: 860px) {
          .grid { grid-template-columns: 1fr; }
          .search-row { grid-template-columns: 1fr; }
        }
      </style>
    </head>
    <body>
      <main class="app">
        <section class="panel hero">
          <div class="title">
            <h1>MANX Start</h1>
            <div class="clock" id="clock">--:--</div>
          </div>
          <div class="search-row">
            <input id="search" class="search-input" placeholder="Search the web..." autocomplete="off">
            <select id="engine" class="engine-select" title="Search engine">
              <option value="google">Google</option>
              <option value="duckduckgo">DuckDuckGo</option>
              <option value="perplexity">Perplexity</option>
              <option value="bing">Bing</option>
            </select>
          </div>
        </section>

        <section class="grid">
          <section class="panel card">
            <h2>Quick Links</h2>
            <div class="links" id="links"></div>
          </section>

          <section class="panel card">
            <h2>Add Link</h2>
            <div class="quick-add">
              <input id="name" placeholder="Name (e.g. GitHub)">
              <input id="url" placeholder="URL (e.g. github.com)">
              <button id="add">Add</button>
            </div>
          </section>
        </section>
      </main>

      <script>
        (function() {
          const STORAGE_KEY = "MANX_START_LINKS_V2";
          const DEFAULT_LINKS = [
            { name: "GitHub", url: "https://github.com", desc: "Code" },
            { name: "YouTube", url: "https://youtube.com", desc: "Media" },
            { name: "Gmail", url: "https://mail.google.com", desc: "Mail" },
            { name: "Perplexity", url: "https://www.perplexity.ai", desc: "AI Search" },
            { name: "NixOS", url: "https://search.nixos.org/packages", desc: "Packages" },
            { name: "Hyprland Wiki", url: "https://wiki.hypr.land", desc: "Docs" }
          ];

          const engines = {
            google: "https://www.google.com/search?q=",
            duckduckgo: "https://duckduckgo.com/?q=",
            perplexity: "https://www.perplexity.ai/search?q=",
            bing: "https://www.bing.com/search?q="
          };

          function getLinks() {
            try {
              const saved = localStorage.getItem(STORAGE_KEY);
              return saved ? JSON.parse(saved) : DEFAULT_LINKS;
            } catch (e) {
              return DEFAULT_LINKS;
            }
          }

          function setLinks(links) {
            try {
              localStorage.setItem(STORAGE_KEY, JSON.stringify(links));
            } catch (e) {}
          }

          function renderLinks() {
            const container = document.getElementById("links");
            if (!container) return;
            const links = getLinks();
            container.innerHTML = "";
            links.forEach(function(item, idx) {
              const a = document.createElement("a");
              a.className = "link";
              a.href = item.url;
              a.innerHTML = "<span>" + item.name + "</span><small>" + (item.desc || "Link") + "</small>";
              a.addEventListener("contextmenu", function(e) {
                e.preventDefault();
                const next = getLinks();
                next.splice(idx, 1);
                setLinks(next);
                renderLinks();
              });
              container.appendChild(a);
            });
          }

          function addLink() {
            const nameEl = document.getElementById("name");
            const urlEl = document.getElementById("url");
            if (!nameEl || !urlEl) return;
            const name = nameEl.value.trim();
            let url = urlEl.value.trim();
            if (!name || !url) return;
            if (!/^https?:\/\//i.test(url)) url = "https://" + url;
            const links = getLinks();
            links.push({ name: name, url: url, desc: "Custom" });
            setLinks(links);
            nameEl.value = "";
            urlEl.value = "";
            renderLinks();
          }

          function runSearch() {
            const searchEl = document.getElementById("search");
            const engineEl = document.getElementById("engine");
            if (!searchEl || !engineEl) return;
            const query = searchEl.value.trim();
            const engine = engineEl.value;
            if (!query) return;
            window.location.href = engines[engine] + encodeURIComponent(query);
          }

          function updateClock() {
            const clock = document.getElementById("clock");
            if (!clock) return;
            const now = new Date();
            const timeStr = now.toLocaleString("en-US", {
              weekday: "short",
              hour: "2-digit",
              minute: "2-digit",
              hour12: true
            });
            clock.textContent = timeStr.replace(" AM", " am").replace(" PM", " pm");
          }

          function init() {
            const addBtn = document.getElementById("add");
            if (addBtn) addBtn.addEventListener("click", addLink);
            
            const urlEl = document.getElementById("url");
            if (urlEl) {
              urlEl.addEventListener("keydown", function(e) {
                if (e.key === "Enter") addLink();
              });
            }

            const searchEl = document.getElementById("search");
            if (searchEl) {
              searchEl.addEventListener("keydown", function(e) {
                if (e.key === "Enter") runSearch();
              });
            }

            setInterval(updateClock, 1000);
            updateClock();
            renderLinks();
          }

          if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", init);
          } else {
            init();
          }
        })();
      </script>
    </body>
    </html>
  '';
}
