import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.VirtualKeyboard
import SddmComponents
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#050107"
    focus: true

    Keys.onReturnPressed: attemptLogin()
    Keys.onEnterPressed: attemptLogin()

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    readonly property real scaleFactor: (Screen.devicePixelRatio > 0) ? Screen.devicePixelRatio : 1.0
    readonly property real uiScale: Math.max(0.75, Math.min(width / 1920, height / 1080) * scaleFactor)

    readonly property color neonGreen: "#39FF14"
    readonly property color maroon: "#A80800"
    readonly property color maroonBright: "#FF1133"
    readonly property color panelBase: "#C10B020D"
    readonly property color panelAlt: "#A10A0211"
    readonly property color stroke: "#4D39FF14"
    readonly property color strokeSoft: "#26FFFFFF"
    readonly property color textPrimary: "#F5FFF0"
    readonly property color textMuted: "#B8F5FFF0"
    readonly property color textDanger: "#FF6262"
    readonly property color textWarning: "#FFB347"
    readonly property color inputFill: "#CC09010A"
    readonly property color inputBorder: "#6639FF14"
    readonly property color cardGlow: "#8039FF14"
    readonly property color maroonGlow: "#80A80800"
    readonly property color hoverFill: "#1F39FF14"
    readonly property color selectedFill: "#2B39FF14"
    readonly property color selectedBorder: "#CC39FF14"
    readonly property color buttonFill: "#1839FF14"
    readonly property color buttonTextDark: "#050107"
    readonly property color subtleLine: "#1FFFFFFF"
    readonly property color leftPanelTop: "#D20C0312"
    readonly property color leftPanelBottom: "#9E09020F"
    readonly property color rightPanelTop: "#CC0D0310"
    readonly property color rightPanelBottom: "#A009020C"
    readonly property color chipFill: "#18000000"
    readonly property color chipBorder: "#3A39FF14"
    readonly property color sessionGlow: "#1139FF14"
    readonly property color passwordGlow: "#2239FF14"
    readonly property color shutdownGlow: "#26FF1133"
    readonly property color suspendGlow: "#26FFB347"
    readonly property color hibernateBorder: maroonBright
    readonly property color hibernateGlow: shutdownGlow

    readonly property font titleFont: Qt.font({ family: "Orbitron", pixelSize: Math.max(16, Math.round(30 * uiScale)), bold: true, letterSpacing: 5 })
    readonly property font sectionFont: Qt.font({ family: "JetBrainsMono Nerd Font", pixelSize: Math.max(10, Math.round(13 * uiScale)), bold: true, letterSpacing: 2 })
    readonly property font bodyFont: Qt.font({ family: "JetBrainsMono Nerd Font", pixelSize: Math.max(9, Math.round(12 * uiScale)), bold: true })
    readonly property font actionFont: Qt.font({ family: "JetBrainsMono Nerd Font", pixelSize: Math.max(11, Math.round(14 * uiScale)), bold: true, letterSpacing: 1 })
    readonly property font capsWarningFont: Qt.font({ family: "JetBrainsMono Nerd Font", pixelSize: Math.max(9, Math.round(10 * uiScale)), bold: true, letterSpacing: 2 })

    property bool authenticating: false
    property string messageText: "Awaiting secure authentication"
    property color messageColor: textMuted
    property string selectedUserName: ""
    property string selectedUserDisplayName: ""
    property string selectedUserIcon: ""
    property string selectedSessionName: ""
    property string timeString: Qt.formatTime(new Date(), "hh:mm")
    property string dateString: Qt.formatDate(new Date(), "dddd, dd MMM yyyy")
    property string binarySeconds: "0b000000"
    property string timingStats: "tpd 0.8s  |  f = 60Hz  |  VDD = 1.8V"

    property bool virtualKeyboardActive: false
    property color spectrumColor: neonGreen

    // --- IDLE & STABILITY ENGINE ---
    property int lastActivityTime: 0
    property bool isIdle: false
    property int frameCount: 0

    Timer {
        id: idleDetector
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            lastActivityTime++
            if (lastActivityTime > 300) { // 5 minutes of inactivity
                isIdle = true
            }
        }
    }

    function resetIdle() {
        lastActivityTime = 0
        isIdle = false
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // Crucial: Do not block clicks for elements below
        onPositionChanged: resetIdle()
        z: -1 // Behind everything
    }

    SequentialAnimation {
        id: spectrumAnimation
        running: !isIdle
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "spectrumColor"; from: "#39FF14"; to: "#99FF11"; duration: 4000; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#99FF11"; to: "#FF9900"; duration: 4000; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#FF9900"; to: "#FF1133"; duration: 4000; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#FF1133"; to: "#FF9900"; duration: 4000; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#FF9900"; to: "#99FF11"; duration: 4000; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#99FF11"; to: "#39FF14"; duration: 4000; easing.type: Easing.InOutQuad }
    }

    property bool isCapsActiveHeuristic: false
    readonly property bool isCapsActive: isCapsActiveHeuristic

    property real cpuLoad: 0.35
    property real telemetrySpeedMultiplier: 1.0
    property real telemetryJitter: 0.0
    property real telemetryNoiseAccumulator: 0.0
    property int verilogIndex: 0
    property var verilogLines1: ["module workstation_auth_logic;", "always @(posedge clk or negedge rst_n)", "assign parity_error = ^data_bus;", "always @(*) begin", "wire [255:0] sha256_hash;"]
    property var verilogLines2: ["assign active_operator = \"mayank-anand\";", "  if (!rst_n) state <= IDLE; else state <= next;", "assign dec_valid = (key == SIGNATURE);", "  case(opcode) ALU_ADD: out = a + b;", "decrypt_core u0 (.clk(clk), .in(key));"]
    property bool isGlitchActive: false
    property bool isSuccessWaveActive: false
    property real successWaveProgress: 0.0
    property int hoveredGateIndex: -1
    property int hoveredTableIndex: -1
    property real verilogOpacity: 1.0

    property color rainbowColor: maroonBright

    SequentialAnimation {
        id: rainbowAnimation
        running: !isIdle
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "rainbowColor"; to: "#00E5FF"; duration: 2000; easing.type: Easing.InOutQuad } // VLSI Cyan (Clock)
        ColorAnimation { target: root; property: "rainbowColor"; to: "#FF9900"; duration: 2000; easing.type: Easing.InOutQuad } // VLSI Gold (Power)
        ColorAnimation { target: root; property: "rainbowColor"; to: "#FF00FF"; duration: 2000; easing.type: Easing.InOutQuad } // Magenta
        ColorAnimation { target: root; property: "rainbowColor"; to: neonGreen; duration: 2000; easing.type: Easing.InOutQuad } // Neon
        ColorAnimation { target: root; property: "rainbowColor"; to: maroonBright; duration: 2000; easing.type: Easing.InOutQuad } // Maroon
    }

    function syncSelectedUser() {
        if (userList.currentItem) {
            selectedUserName = userList.currentItem.userName
            selectedUserDisplayName = userList.currentItem.displayName
            selectedUserIcon = userList.currentItem.iconSource
        }
    }

    function attemptLogin() {
        if (authenticating)
            return

        if (selectedUserName === "") {
            messageColor = textWarning
            messageText = "Select a user profile first"
            userList.forceActiveFocus()
            return
        }

        if (sessionSelector.currentIndex < 0) {
            messageColor = textWarning
            messageText = "Choose a valid session before login"
            sessionSelector.forceActiveFocus()
            return
        }

        authenticating = true
        messageColor = neonGreen
        messageText = "Opening MANX VLSI Customized Workstation..."
        if (typeof sddm !== "undefined" && sddm !== null) {
            sddm.login(selectedUserName, passwordField.text, sessionSelector.currentIndex)
        }
    }

    TextConstants {
        id: textConstants
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            timeString = Qt.formatTime(now, "hh:mm")
            dateString = Qt.formatDate(now, "dddd, dd MMM yyyy")
            var secs = now.getSeconds()
            var binStr = "0b"
            for (var bi = 5; bi >= 0; bi--) binStr += ((secs >> bi) & 1).toString()
            binarySeconds = binStr + "  \u00b7  t=" + (secs < 10 ? "0" : "") + secs + "s"
        }
    }

    Timer {
        id: resetMessageTimer
        interval: 3000
        repeat: false
        onTriggered: {
            if (!authenticating) {
                messageColor = textMuted
                messageText = "Awaiting secure authentication"
            }
        }
    }

    Timer {
        id: authGlitchTimer
        interval: 1500
        repeat: false
        onTriggered: {
            root.isGlitchActive = false
        }
    }

    SequentialAnimation {
        id: verilogTransitionAnim
        running: false
        NumberAnimation { target: root; property: "verilogOpacity"; to: 0.0; duration: 300; easing.type: Easing.InOutQuad }
        ScriptAction {
            script: {
                root.verilogIndex = (root.verilogIndex + 1) % 5
            }
        }
        NumberAnimation { target: root; property: "verilogOpacity"; to: 1.0; duration: 300; easing.type: Easing.InOutQuad }
    }

    Timer {
        id: verilogCycleTimer
        interval: 12000
        running: true
        repeat: true
        onTriggered: {
            verilogTransitionAnim.start()
        }
    }

    Canvas {
        id: bgCanvas
        anchors.fill: parent
        z: 0
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Immediate // Use Immediate to prevent synchronization freezes in SDDM

        property var particles: []
        property int numParticles: 15 // Reduced for performance
        property real pulse: 0
        property real simulationProgress: 0

        function checkHover(mx, my) {
            var foundGateIdx = -1
            var foundTableIdx = -1

            var scale = uiScale
            var shellWidth = Math.min(width - Math.round(80 * scale), 1420)
            var shellHeight = Math.min(height - Math.round(40 * scale), 860)
            var shellX = (width - shellWidth) / 2
            var shellY = (height - shellHeight) / 2

            var shellSafeR = shellX + shellWidth + 10 * scale
            var shellSafeB = shellY + shellHeight + 10 * scale

            var gatesX = [
                width * 0.5,
                shellX * 0.52,
                shellX * 0.52,
                shellX * 0.52,
                width * 0.5,
                shellSafeR + (width - shellSafeR) * 0.48,
                shellSafeR + (width - shellSafeR) * 0.48,
                shellSafeR + (width - shellSafeR) * 0.48
            ]

            var gatesY = [
                shellY * 0.58,
                shellY + shellHeight * 0.07,
                shellY + shellHeight * 0.39,
                shellY + shellHeight * 0.71,
                shellSafeB + (height - shellSafeB) * 0.35,
                shellY + shellHeight * 0.07,
                shellY + shellHeight * 0.39,
                shellY + shellHeight * 0.71
            ]

            var gw = 36 * scale
            var gh = 36 * scale

            for (var gi = 0; gi < 8; gi++) {
                var gx = gatesX[gi]
                var gy = gatesY[gi]

                // Gate body bounds check
                if (Math.abs(mx - gx) < gw / 2 + 10 * scale && Math.abs(my - gy) < gh / 2 + 10 * scale) {
                    foundGateIdx = gi
                }

                // HUD/Waveform cards bounds check
                var isLeft = (gx < width * 0.4)
                var isRight = (gx > width * 0.6)
                var gateStubLen = (gi === 0 || gi === 4) ? 80 * scale : 56 * scale

                var totalStates = (gi === 0 || gi === 4) ? 2 : 4
                var hudW = (totalStates < 3) ? 128 * scale : 118 * scale
                var hudH = (totalStates < 3) ? 70 * scale : 88 * scale
                var wfW = hudW
                var wfH = (totalStates < 3) ? 50 * scale : 58 * scale

                var hx = 0; var hy = 0; var wx = 0; var wy = 0
                if (isLeft || isRight) {
                    hx = gx - hudW / 2
                    hy = gy + gh / 2 + 14 * scale
                    wx = gx - wfW / 2
                    wy = hy + hudH + 8 * scale
                } else {
                    hx = gx - gateStubLen - hudW - 60 * scale
                    hy = gy - hudH / 2
                    wx = gx + gateStubLen + 60 * scale
                    wy = gy - wfH / 2
                }

                // Boundary clamping
                hx = Math.max(10, Math.min(hx, width - hudW - 10)); hy = Math.max(10, Math.min(hy, height - hudH - 10))
                wx = Math.max(10, Math.min(wx, width - wfW - 10)); wy = Math.max(10, Math.min(wy, height - wfH - 10))

                // Check inside HUD Card bounds
                if (mx >= hx && mx <= hx + hudW && my >= hy && my <= hy + hudH) {
                    foundTableIdx = gi
                }
                // Check inside Waveform Card bounds
                if (mx >= wx && mx <= wx + wfW && my >= wy && my <= wy + wfH) {
                    foundTableIdx = gi
                }
            }

            if (root.hoveredGateIndex !== foundGateIdx || root.hoveredTableIndex !== foundTableIdx) {
                root.hoveredGateIndex = foundGateIdx
                root.hoveredTableIndex = foundTableIdx
                bgCanvas.requestPaint()
            }
        }

        onWidthChanged: initParticles()
        onHeightChanged: initParticles()

        Component.onCompleted: initParticles()

        function initParticles() {
            if (width <= 0 || height <= 0)
                return

            particles = []
            for (var i = 0; i < numParticles; ++i) {
                particles.push({
                    x: Math.random() * width,
                    y: Math.random() * height,
                    vx: (Math.random() - 0.5) * 3.0,
                    vy: (Math.random() - 0.5) * 3.0,
                    r: Math.random() * 2.2 + 0.8,
                    a: Math.random() * 0.35 + 0.12,
                    isRed: Math.random() < 0.20
                })
            }
        }

        function hexToRgb(hex) {
            var c = hex.substring(1)
            var val = parseInt(c, 16)
            var r = (val >> 16) & 255
            var g = (val >> 8) & 255
            var b = val & 255
            return r + ", " + g + ", " + b
        }

        function drawGateWaveform(ctx, wx, wy, ww, wh, gateType, rows, isActive, sp) {
            var isSingle = (gateType === "BUF" || gateType === "NOT")
            var numSigs = isSingle ? 2 : 3
            var sigNames  = isSingle ? ["IN", "Y"] : ["A", "B", "Y"]
            var numPoints = 80
            var rowCount  = rows.length
            var labelW    = 18 * uiScale
            var sigH      = wh / numSigs

            // High-contrast Glassmorphic Card background
            ctx.save()
            var rr = 6 * uiScale
            ctx.fillStyle = "rgba(5, 1, 8, 0.96)"
            ctx.shadowBlur = 6 * uiScale
            ctx.shadowColor = "rgba(0,0,0,0.8)"
            ctx.beginPath()
            ctx.moveTo(wx + rr, wy)
            ctx.lineTo(wx + ww - rr, wy)
            ctx.quadraticCurveTo(wx + ww, wy, wx + ww, wy + rr)
            ctx.lineTo(wx + ww, wy + wh - rr)
            ctx.quadraticCurveTo(wx + ww, wy + wh, wx + ww - rr, wy + wh)
            ctx.lineTo(wx + rr, wy + wh)
            ctx.quadraticCurveTo(wx, wy + wh, wx, wy + wh - rr)
            ctx.lineTo(wx, wy + rr)
            ctx.quadraticCurveTo(wx, wy, wx + rr, wy)
            ctx.closePath()
            ctx.fill()
            ctx.strokeStyle = isActive ? "rgba(57, 255, 20, 0.35)" : "rgba(255, 17, 51, 0.25)"
            ctx.lineWidth = 1 * uiScale
            ctx.stroke()
            ctx.restore()

            // Draw each signal trace
            for (var si = 0; si < numSigs; si++) {
                var baseY  = wy + si * sigH + sigH * 0.5
                var amp    = sigH * 0.32
                var sName  = sigNames[si]
                var colIdx = (isSingle ? [0, 2] : [0, 1, 2])[si]

                // Signal label
                ctx.save()
                ctx.fillStyle = "rgba(255, 255, 255, 0.5)"
                ctx.font = "bold " + Math.max(7, Math.round(8 * uiScale)) + "px 'JetBrainsMono Nerd Font'"
                ctx.textAlign = "left"
                ctx.textBaseline = "middle"
                ctx.fillText(sName, wx + 4, baseY)
                ctx.restore()

                // Waveform trace with dynamic segment coloring
                ctx.save()
                ctx.lineWidth = 1.8 * uiScale

                var prevVal = -1
                var startX = wx + labelW
                var endX = wx + ww - 6 * uiScale

                for (var pi = 0; pi <= numPoints; pi++) {
                    var t = (pi / numPoints + sp) % 1.0

                    // tpd delay shift for output signal
                    var sampleT = t
                    if (si === numSigs - 1) sampleT = (t - (0.6 / rowCount) + 1.0) % 1.0

                    var rowIdx = Math.floor(sampleT * rowCount) % rowCount
                    var row = rows[rowIdx]
                    var val = parseInt(row[colIdx])
                    if (isNaN(val)) val = 0
                    if (root.isGlitchActive) {
                        val = (Math.random() < 0.05) ? (Math.random() < 0.5 ? 1 : 0) : 0
                    }

                    var px = startX + (pi / numPoints) * (endX - startX)
                    var py = baseY + (val === 0 ? amp : -amp)
                    var segmentColor = (val === 1) ? "#39FF14" : "#FF1133"

                    if (pi === 0) {
                        ctx.beginPath()
                        ctx.moveTo(px, py)
                        prevVal = val
                    } else if (val !== prevVal) {
                        // Vertical transition
                        ctx.lineTo(px, prevVal === 0 ? baseY + amp : baseY - amp)
                        ctx.lineTo(px, py)

                        // Close and stroke previous segment with its color
                        ctx.strokeStyle = (prevVal === 1) ? "#39FF14" : "#FF1133"
                        ctx.stroke()

                        // Start new segment
                        ctx.beginPath()
                        ctx.moveTo(px, py)
                    } else {
                        ctx.lineTo(px, py)
                    }

                    if (pi === numPoints) {
                        ctx.strokeStyle = segmentColor
                        ctx.stroke()
                    }

                    prevVal = val
                }
                ctx.restore()
            }

            // "NOW" line
            ctx.save()
            ctx.strokeStyle = "rgba(255,255,255,0.4)"
            ctx.lineWidth = 1
            ctx.setLineDash([2, 2])
            ctx.beginPath()
            ctx.moveTo(wx + ww - 6 * uiScale, wy + 4)
            ctx.lineTo(wx + ww - 6 * uiScale, wy + wh - 4)
            ctx.stroke()
            ctx.restore()
        }

        function easeInOut(t) {
            var c = t < 0.0 ? 0.0 : (t > 1.0 ? 1.0 : t)
            return c < 0.5 ? 2.0 * c * c : -1.0 + (4.0 - 2.0 * c) * c
        }

        function drawWireLabel(ctx, x, y, label, val, alignRight) {
            ctx.save()
            var valColor = (val === "1") ? "#39FF14" : "#FF1133"
            ctx.font = "bold " + Math.round(10 * uiScale) + "px 'JetBrainsMono Nerd Font'"
            ctx.textBaseline = "middle"

            var combinedText = label + " = " + val
            var textW = ctx.measureText(combinedText).width
            var labelW = ctx.measureText(label + " = ").width

            if (alignRight) {
                ctx.textAlign = "right"
                ctx.fillStyle = "rgba(255, 255, 255, 0.7)"
                ctx.fillText(label + " =", x - 8 * uiScale - (textW - labelW), y)
                ctx.fillStyle = valColor
                ctx.fillText(val, x - 8 * uiScale, y)
            } else {
                ctx.textAlign = "left"
                ctx.fillStyle = "rgba(255, 255, 255, 0.7)"
                ctx.fillText(label + " =", x + 8 * uiScale, y)
                ctx.fillStyle = valColor
                ctx.fillText(val, x + 8 * uiScale + labelW, y)
            }
            ctx.restore()
        }

        function drawWireLabelCenter(ctx, x, y, label, val) {
            ctx.save()
            var valColor = (val === "1") ? "#39FF14" : "#FF1133"
            ctx.font = "bold " + Math.round(10 * uiScale) + "px 'JetBrainsMono Nerd Font'"
            ctx.textBaseline = "middle"

            var combinedText = label + " = " + val
            var textW = ctx.measureText(combinedText).width
            var labelW = ctx.measureText(label + " = ").width
            var startX = x - textW / 2

            ctx.fillStyle = "rgba(255, 255, 255, 0.7)"
            ctx.textAlign = "left"
            ctx.fillText(label + " =", startX, y)
            ctx.fillStyle = valColor
            ctx.fillText(val, startX + labelW, y)
            ctx.restore()
        }

        function drawWaveguide(ctx, xStart, yStart, xEnd, yEnd, logicVal, progress, phase, isInput) {
            ctx.save()
            var isHigh = (logicVal === "1")
            var baseColor = isHigh ? "#39FF14" : "#FF1133"
            var dimColor = isHigh ? "rgba(57, 255, 20, 0.3)" : "rgba(255, 17, 51, 0.25)"

            // PCB Channel Backing
            ctx.beginPath()
            ctx.moveTo(xStart, yStart)
            ctx.lineTo(xEnd, yEnd)
            ctx.strokeStyle = "rgba(10, 2, 18, 0.6)"
            ctx.lineWidth = 4 * uiScale
            ctx.stroke()

            // Waveguide path
            ctx.strokeStyle = dimColor
            ctx.lineWidth = 1.5 * uiScale
            ctx.stroke()

            // Dash signal flow (direction: Input -> Gate -> Output)
            ctx.beginPath()
            ctx.moveTo(xStart, yStart)
            ctx.lineTo(xEnd, yEnd)
            ctx.strokeStyle = baseColor
            ctx.setLineDash([6 * uiScale, 8 * uiScale])
            // If input, flow towards gate. If output, flow away from gate.
            ctx.lineDashOffset = (isInput ? -1 : -1) * simulationProgress * 500 * uiScale
            ctx.stroke()
            ctx.setLineDash([])
            ctx.restore()

            // Electron pulse
            ctx.save()
            var curX = xStart
            var curY = yStart

            if (isInput) {
                if (phase === 1) { 
                    curX = xStart + (xEnd - xStart) * progress
                    curY = yStart + (yEnd - yStart) * progress
                } else { 
                    curX = xEnd
                    curY = yEnd
                }
            } else {
                if (phase === 3) {
                    curX = xStart + (xEnd - xStart) * progress
                    curY = yStart + (yEnd - yStart) * progress
                } else {
                    curX = xEnd
                    curY = yEnd
                }
            }

            ctx.beginPath()
            ctx.arc(curX, curY, 4.5 * uiScale, 0, Math.PI * 2)
            ctx.fillStyle = baseColor
            ctx.shadowBlur = 12 * uiScale
            ctx.shadowColor = baseColor
            ctx.fill()
            ctx.beginPath()
            ctx.arc(curX, curY, 1.8 * uiScale, 0, Math.PI * 2)
            ctx.fillStyle = "#FFFFFF"
            ctx.fill()
            ctx.restore()
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            // Deep outer-space background gradient
            var bg = ctx.createLinearGradient(0, 0, width, height)
            bg.addColorStop(0.0, "#040107")
            bg.addColorStop(0.4, "#0B0210")
            bg.addColorStop(0.7, "#09040C")
            bg.addColorStop(1.0, "#020203")
            ctx.fillStyle = bg
            ctx.fillRect(0, 0, width, height)

            // Dynamic vignette overlays
            var vignette = ctx.createRadialGradient(width * 0.5, height * 0.5, Math.min(width, height) * 0.1,
                                                    width * 0.5, height * 0.5, Math.max(width, height) * 0.7)
            vignette.addColorStop(0.0, "rgba(168, 8, 0, 0.16)")
            vignette.addColorStop(0.45, "rgba(57, 255, 20, 0.03)")
            vignette.addColorStop(1.0, "rgba(0, 0, 0, 0.94)")
            ctx.fillStyle = vignette
            ctx.fillRect(0, 0, width, height)

            pulse += authenticating ? 0.030 : 0.012

            // High-fidelity background grid lines
            ctx.strokeStyle = "rgba(57, 255, 20, 0.05)"
            ctx.lineWidth = 1
            var gridOffsetY = Math.sin(pulse * 0.4) * 12
            var gridOffsetX = Math.cos(pulse * 0.4) * 12
            for (var gy = 0; gy < height + 48; gy += 48) {
                var y = gy - 24 + gridOffsetY
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
            for (var gx = 0; gx < width + 64; gx += 64) {
                var x = gx - 32 + gridOffsetX
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }

            var wcx = width * 0.5
            var wcy = height * 0.5
            var wra = Math.min(width, height) * 0.38

            // Concentric high-tech digital circle systems (radar sweep look)
            ctx.save()
            ctx.beginPath()
            ctx.arc(wcx, wcy, wra, 0, 2 * Math.PI)
            ctx.strokeStyle = "rgba(57, 255, 20, 0.08)"
            ctx.lineWidth = 1
            ctx.stroke()

            ctx.beginPath()
            ctx.arc(wcx, wcy, wra * 0.6, 0, 2 * Math.PI)
            ctx.strokeStyle = "rgba(57, 255, 20, 0.03)"
            ctx.stroke()

            var sweepAngle = (simulationProgress * 2 * Math.PI)
            ctx.beginPath()
            ctx.moveTo(wcx, wcy)
            ctx.lineTo(wcx + wra * Math.cos(sweepAngle), wcy + wra * Math.sin(sweepAngle))
            ctx.strokeStyle = "rgba(57, 255, 20, 0.08)"
            ctx.lineWidth = 2
            ctx.stroke()
            ctx.restore()

            // Adaptive positioning engine
            var shellWidth = Math.min(width - Math.round(80 * uiScale), 1420)
            var shellHeight = Math.min(height - Math.round(40 * uiScale), 860)
            var shellX = (width - shellWidth) / 2
            var shellY = (height - shellHeight) / 2

            var shellSafeX = shellX - 10 * uiScale
            var shellSafeR = shellX + shellWidth + 10 * uiScale
            var shellSafeY = shellY - 10 * uiScale
            var shellSafeB = shellY + shellHeight + 10 * uiScale

            var gates = [
                { type: "BUF", x: width * 0.5, y: shellY * 0.58, name: "BUFFER GATE" },
                { type: "AND", x: shellX * 0.52, y: shellY + shellHeight * 0.07, name: "AND GATE" },
                { type: "OR", x: shellX * 0.52, y: shellY + shellHeight * 0.39, name: "OR GATE" },
                { type: "XOR", x: shellX * 0.52, y: shellY + shellHeight * 0.71, name: "XOR GATE" },
                { type: "NOT", x: width * 0.5, y: shellSafeB + (height - shellSafeB) * 0.35, name: "NOT GATE" },
                { type: "NAND", x: shellSafeR + (width - shellSafeR) * 0.48, y: shellY + shellHeight * 0.07, name: "NAND GATE" },
                { type: "NOR", x: shellSafeR + (width - shellSafeR) * 0.48, y: shellY + shellHeight * 0.39, name: "NOR GATE" },
                { type: "XNOR", x: shellSafeR + (width - shellSafeR) * 0.48, y: shellY + shellHeight * 0.71, name: "XNOR GATE" }
            ]

            var gw = 36 * uiScale
            var gh = 36 * uiScale

            for (var gi = 0; gi < gates.length; ++gi) {
                var gate = gates[gi]
                var gx = gate.x; var gy = gate.y
                var isLeft = (gx < width * 0.4); var isRight = (gx > width * 0.6)
                var isTop = (gy < height * 0.3); var isBottom = (gy > height * 0.7)
                var gateStubLen = (gate.type === "BUF" || gate.type === "NOT") ? 80 * uiScale : 56 * uiScale

                var rows = []
                if (gate.type === "BUF") rows = [["0", " ", "0"], ["1", " ", "1"]]
                else if (gate.type === "NOT") rows = [["0", " ", "1"], ["1", " ", "0"]]
                else if (gate.type === "AND") rows = [["0", "0", "0"], ["0", "1", "0"], ["1", "0", "0"], ["1", "1", "1"]]
                else if (gate.type === "NAND") rows = [["0", "0", "1"], ["0", "1", "1"], ["1", "0", "1"], ["1", "1", "0"]]
                else if (gate.type === "OR") rows = [["0", "0", "0"], ["0", "1", "1"], ["1", "0", "1"], ["1", "1", "1"]]
                else if (gate.type === "NOR") rows = [["0", "0", "1"], ["0", "1", "0"], ["1", "0", "0"], ["1", "1", "0"]]
                else if (gate.type === "XOR") rows = [["0", "0", "0"], ["0", "1", "1"], ["1", "0", "1"], ["1", "1", "0"]]
                else if (gate.type === "XNOR") rows = [["0", "0", "1"], ["0", "1", "0"], ["1", "0", "0"], ["1", "1", "1"]]

                // --- CLOCK & PHASE SYNC ENGINE ---
                var totalStates = rows.length
                var cycleProgress = (simulationProgress + gi * 0.125) % 1.0
                var activeRowIndex = Math.floor(cycleProgress * totalStates)
                var activeRow = rows[activeRowIndex]

                var rowFrac = (cycleProgress * totalStates) % 1.0
                var phase = 1; var inputProgress = 0; var processProgress = 0; var outputProgress = 0
                if (rowFrac < 0.2) { phase = 1; inputProgress = easeInOut(rowFrac / 0.2) }
                else if (rowFrac < 0.6) { phase = 2; processProgress = easeInOut((rowFrac - 0.2) / 0.4) }
                else { phase = 3; outputProgress = easeInOut((rowFrac - 0.6) / 0.4) }

                var valA = activeRow[0]; var valB = activeRow[1]; var valY = activeRow[2]
                var prevActiveIndex = (activeRowIndex - 1 + totalStates) % totalStates
                var isGateActive = (phase === 3) ? (valY === "1") : (rows[prevActiveIndex][rows[prevActiveIndex].length-1] === "1")
                var currentOutVal = (phase === 3) ? valY : rows[prevActiveIndex][rows[prevActiveIndex].length-1]

                // --- WAVEGUIDES & LABELS ---
                if (isLeft || isRight) {
                    drawWaveguide(ctx, gx - gateStubLen, gy - 6 * uiScale, gx - gw/2, gy - 6 * uiScale, valA, inputProgress, phase, true)
                    drawWaveguide(ctx, gx - gateStubLen, gy + 6 * uiScale, gx - gw/2, gy + 6 * uiScale, valB, inputProgress, phase, true)
                    drawWaveguide(ctx, gx + gw/2, gy, gx + gateStubLen, gy, currentOutVal, outputProgress, phase, false)
                    drawWireLabel(ctx, gx - gateStubLen, gy - 6 * uiScale, "A", valA, true)
                    drawWireLabel(ctx, gx - gateStubLen, gy + 6 * uiScale, "B", valB, true)
                    drawWireLabel(ctx, gx + gateStubLen, gy, "Y", currentOutVal, false)
                } else {
                    drawWaveguide(ctx, gx - gateStubLen, gy, gx - gw/2, gy, valA, inputProgress, phase, true)
                    drawWaveguide(ctx, gx + gw/2, gy, gx + gateStubLen, gy, currentOutVal, outputProgress, phase, false)
                    drawWireLabelCenter(ctx, gx - gateStubLen - 30 * uiScale, gy, "IN", valA)
                    drawWireLabelCenter(ctx, gx + gateStubLen + 30 * uiScale, gy, "OUT", currentOutVal)
                }

                // --- GATE BODY ---
                ctx.save(); ctx.lineWidth = 2 * uiScale;
                var logicColor = root.isGlitchActive ? "#8B0000" : (passwordField.text.length > 0 ? (isGateActive ? "#00F0FF" : "#FFD700") : (isGateActive ? "#39FF14" : "#FF1133"))
                ctx.strokeStyle = logicColor
                var gateGrad = ctx.createLinearGradient(gx-gw/2, gy-gh/2, gx+gw/2, gy+gh/2); gateGrad.addColorStop(0, "rgba(4,1,8,0.98)")
                var dynamicGradColor = root.isGlitchActive ? "rgba(139,0,0,0.2)" : (passwordField.text.length > 0 ? (isGateActive ? "rgba(0,240,255,0.2)" : "rgba(255,215,0,0.15)") : (isGateActive ? "rgba(57,255,20,0.2)" : "rgba(255,17,51,0.15)"))
                gateGrad.addColorStop(1, dynamicGradColor)
                ctx.fillStyle = gateGrad
                var glow = (phase === 2) ? (16 + 10 * Math.sin(simulationProgress * 60)) : (isGateActive ? 12 : 4)
                var isGateHovered = (gi === root.hoveredGateIndex)
                if (isGateHovered) {
                    glow = glow * 1.8
                }
                ctx.shadowBlur = glow * uiScale; ctx.shadowColor = logicColor
                if (isGateHovered) {
                    ctx.save()
                    ctx.translate(gx, gy)
                    ctx.scale(1.08, 1.08)
                    ctx.translate(-gx, -gy)
                }
                ctx.beginPath()
                if (gate.type === "BUF") { ctx.moveTo(gx-gw/2, gy-gh/2); ctx.lineTo(gx+gw/2, gy); ctx.lineTo(gx-gw/2, gy+gh/2); ctx.closePath() }
                else if (gate.type === "NOT") { ctx.moveTo(gx-gw/2, gy-gh/2); ctx.lineTo(gx+gw/4, gy); ctx.lineTo(gx-gw/2, gy+gh/2); ctx.closePath(); ctx.stroke(); ctx.fill(); ctx.beginPath(); ctx.arc(gx+gw/2-2*uiScale, gy, 3*uiScale, 0, 7) }
                else if (gate.type === "AND" || gate.type === "NAND") { ctx.moveTo(gx-gw/2, gy-gh/2); ctx.lineTo(gx, gy-gh/2); ctx.arc(gx, gy, gh/2, -1.57, 1.57, false); ctx.lineTo(gx-gw/2, gy+gh/2); ctx.closePath(); if(gate.type === "NAND"){ctx.stroke(); ctx.fill(); ctx.beginPath(); ctx.arc(gx+gw/2+2*uiScale, gy, 3*uiScale, 0, 7)} }
                else if (gate.type === "OR" || gate.type === "NOR") { ctx.moveTo(gx-gw/2, gy-gh/2); ctx.quadraticCurveTo(gx-gw/4, gy, gx-gw/2, gy+gh/2); ctx.quadraticCurveTo(gx, gy+gh/2, gx+gw/2, gy); ctx.quadraticCurveTo(gx, gy-gh/2, gx-gw/2, gy-gh/2); ctx.closePath(); if(gate.type === "NOR"){ctx.stroke(); ctx.fill(); ctx.beginPath(); ctx.arc(gx+gw/2+2*uiScale, gy, 3*uiScale, 0, 7)} }
                else if (gate.type === "XOR" || gate.type === "XNOR") { ctx.moveTo(gx-gw/2-4*uiScale, gy-gh/2); ctx.quadraticCurveTo(gx-gw/4-4*uiScale, gy, gx-gw/2-4*uiScale, gy+gh/2); ctx.stroke(); ctx.beginPath(); ctx.moveTo(gx-gw/2, gy-gh/2); ctx.quadraticCurveTo(gx-gw/4, gy, gx-gw/2, gy+gh/2); ctx.quadraticCurveTo(gx, gy+gh/2, gx+gw/2, gy); ctx.quadraticCurveTo(gx, gy-gh/2, gx-gw/2, gy-gh/2); ctx.closePath(); if(gate.type === "XNOR"){ctx.stroke(); ctx.fill(); ctx.beginPath(); ctx.arc(gx+gw/2+2*uiScale, gy, 3*uiScale, 0, 7)} }
                ctx.fill(); ctx.stroke()
                if (isGateHovered) {
                    ctx.restore()
                }
                ctx.restore()

                // --- SYMBOL ---
                ctx.save(); ctx.fillStyle = logicColor; ctx.textAlign = "center"; ctx.textBaseline = "middle"; ctx.font = "bold " + Math.round(11*uiScale) + "px 'JetBrainsMono Nerd Font'"
                var sym = (gate.type === "AND" || gate.type === "NAND") ? "&" : ((gate.type === "OR" || gate.type === "NOR") ? "≥1" : ((gate.type === "XOR" || gate.type === "XNOR") ? "=1" : "1"))
                ctx.fillText(sym, gx - (gate.type=="NOT"?3*uiScale:0), gy); ctx.restore()

                // --- ADAPTIVE HUD & WAVEFORM LAYOUT ---
                var hudW = (totalStates < 3) ? 128 * uiScale : 118 * uiScale
                var hudH = (totalStates < 3) ? 70 * uiScale : 88 * uiScale
                var wfW = hudW; var wfH = (totalStates < 3) ? 50 * uiScale : 58 * uiScale
                var hx = 0; var hy = 0; var wx = 0; var wy = 0
 
                if (isLeft || isRight) { // Side Gates: Stack vertically directly below the gate body, centered at gx
                    hx = gx - hudW / 2
                    hy = gy + gh / 2 + 14 * uiScale
                    wx = gx - wfW / 2
                    wy = hy + hudH + 8 * uiScale
                } else { // Top/Bottom Gates: Side-by-side layout, centered vertically around gy and spaced far horizontally
                    hx = gx - gateStubLen - hudW - 60 * uiScale
                    hy = gy - hudH / 2
                    wx = gx + gateStubLen + 60 * uiScale
                    wy = gy - wfH / 2
                }

                // Final screen boundary clamping
                hx = Math.max(10, Math.min(hx, width - hudW - 10)); hy = Math.max(10, Math.min(hy, height - hudH - 10))
                wx = Math.max(10, Math.min(wx, width - wfW - 10)); wy = Math.max(10, Math.min(wy, height - wfH - 10))

                // --- DRAW HUD ---
                var isTableHovered = (gi === root.hoveredTableIndex)
                if (isTableHovered) {
                    ctx.save()
                    var cardCenterX = (hx + wx + hudW) / 2
                    var cardCenterY = (hy + wy + hudH) / 2
                    ctx.translate(cardCenterX, cardCenterY)
                    ctx.scale(1.05, 1.05)
                    ctx.translate(-cardCenterX, -cardCenterY)
                }
                ctx.save(); ctx.fillStyle = "rgba(4,1,8,0.98)"; ctx.shadowBlur = (isTableHovered ? 20 : 10)*uiScale; ctx.shadowColor = isTableHovered ? logicColor : "rgba(0,0,0,0.9)"; var rr=10*uiScale; ctx.beginPath(); ctx.moveTo(hx+rr, hy); ctx.lineTo(hx+hudW-rr, hy); ctx.quadraticCurveTo(hx+hudW, hy, hx+hudW, hy+rr); ctx.lineTo(hx+hudW, hy+hudH-rr); ctx.quadraticCurveTo(hx+hudW, hy+hudH, hx+hudW-rr, hy+hudH); ctx.lineTo(hx+rr, hy+hudH); ctx.quadraticCurveTo(hx, hy+hudH, hx, hy+hudH-rr); ctx.lineTo(hx, hy+rr); ctx.quadraticCurveTo(hx, hy, hx+rr, hy); ctx.closePath(); ctx.fill(); ctx.strokeStyle = logicColor; ctx.lineWidth = (isTableHovered ? 1.6 : 1)*uiScale; ctx.stroke(); ctx.restore()
                ctx.save(); ctx.fillStyle = logicColor; ctx.font = "bold " + Math.round(9*uiScale) + "px 'JetBrainsMono Nerd Font'"; ctx.fillText(gate.name, hx+12*uiScale, hy+13*uiScale); ctx.restore()
                ctx.save(); ctx.textAlign = "center"; ctx.fillStyle = "rgba(255,255,255,0.4)"; ctx.font = "bold " + Math.round(9*uiScale) + "px 'JetBrainsMono Nerd Font'"
                if(totalStates<3){ctx.fillText("IN", hx+36*uiScale, hy+26*uiScale); ctx.fillText("OUT", hx+82*uiScale, hy+26*uiScale)}
                else{ctx.fillText("A", hx+28*uiScale, hy+26*uiScale); ctx.fillText("B", hx+58*uiScale, hy+26*uiScale); ctx.fillText("Y", hx+88*uiScale, hy+26*uiScale)}
                ctx.restore(); ctx.strokeStyle = "rgba(255,255,255,0.15)"; ctx.beginPath(); ctx.moveTo(hx+10*uiScale, hy+32*uiScale); ctx.lineTo(hx+hudW-10*uiScale, hy+32*uiScale); ctx.stroke()

                var rowH = 11*uiScale; var ryStart = hy + 40 * uiScale
                ctx.save(); ctx.fillStyle = isGateActive ? "rgba(57,255,20,0.2)" : "rgba(255,17,51,0.15)"; ctx.fillRect(hx+4*uiScale, ryStart + activeRowIndex*rowH - rowH/2, hudW-8*uiScale, rowH); ctx.fillStyle = logicColor; ctx.fillRect(hx+4*uiScale, ryStart + activeRowIndex*rowH - rowH/2, 3*uiScale, rowH); ctx.restore()
                for (var ri=0; ri<totalStates; ri++) {
                    ctx.save(); ctx.textAlign = "center"; ctx.textBaseline = "middle"; ctx.fillStyle = (ri==activeRowIndex) ? logicColor : "rgba(255,255,255,0.35)"; ctx.font = (ri==activeRowIndex?"bold ":"")+Math.round(9*uiScale)+"px 'JetBrainsMono Nerd Font'"
                    if(totalStates<3){ctx.fillText(rows[ri][0], hx+36*uiScale, ryStart+ri*rowH); ctx.fillText(rows[ri][2], hx+82*uiScale, ryStart+ri*rowH)}
                    else{ctx.fillText(rows[ri][0], hx+28*uiScale, ryStart+ri*rowH); ctx.fillText(rows[ri][1], hx+58*uiScale, ryStart+ri*rowH); ctx.fillText(rows[ri][2], hx+88*uiScale, ryStart+ri*rowH)}
                    ctx.restore()
                }

                drawGateWaveform(ctx, wx, wy, wfW, wfH, gate.type, rows, isGateActive, cycleProgress)
                if (isTableHovered) {
                    ctx.restore()
                }
                }

            // Animate floating energy quantum particles strictly constrained to prevent credentials card overlay
            for (var i = 0; i < particles.length; ++i) {
                var p = particles[i]
                p.x += p.vx
                p.y += p.vy

                if (p.x < -10) p.x = width + 10
                if (p.x > width + 10) p.x = -10
                if (p.y < -10) p.y = height + 10
                if (p.y > height + 10) p.y = -10

                // Container check to prevent text overriding
                var inCenter = (p.x > shellX && p.x < shellX + shellWidth && p.y > shellY && p.y < shellY + shellHeight)
                var pAlpha = inCenter ? 0.02 * p.a : p.a

                ctx.beginPath()
                ctx.arc(p.x, p.y, p.r * 2.8, 0, Math.PI * 2)
                ctx.fillStyle = p.isRed ? "rgba(255, 17, 51, " + (pAlpha * 0.25) + ")" : "rgba(57, 255, 20, " + (pAlpha * 0.25) + ")"
                ctx.fill()

                ctx.beginPath()
                ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
                ctx.fillStyle = p.isRed ? "rgba(255, 17, 51, " + pAlpha + ")" : "rgba(57, 255, 20, " + pAlpha + ")"
                ctx.fill()

                for (var j = i + 1; j < particles.length; ++j) {
                    var p2 = particles[j]
                    var dx = p.x - p2.x
                    if (Math.abs(dx) >= 90) continue
                    var dy = p.y - p2.y
                    if (Math.abs(dy) >= 90) continue
                    var distSq = dx * dx + dy * dy
                    if (distSq < 8100) {
                        var dist = Math.sqrt(distSq)
                        var alpha = (1.0 - dist / 90.0) * 0.08

                        // Dim grid particle connections in center
                        if (inCenter) alpha *= 0.1

                        ctx.beginPath()
                        ctx.moveTo(p.x, p.y)
                        ctx.lineTo(p2.x, p2.y)
                        ctx.strokeStyle = "rgba(255, 17, 51, " + alpha + ")"
                        ctx.lineWidth = 1
                        ctx.stroke()
                    }
                }
            }

            // --- FLOATING DIAGNOSTICS TOOLTIP ---
            if (root.hoveredGateIndex !== -1) {
                var hgi = root.hoveredGateIndex
                var hg = gates[hgi]
                if (hg) {
                    var hgx = hg.x; var hgy = hg.y
                    var ttW = 160 * uiScale
                    var ttH = 46 * uiScale
                    var ttx = 0; var tty = 0

                    if (hgx < width * 0.4) {
                        ttx = hgx + 30 * uiScale
                        tty = hgy - ttH / 2
                    } else if (hgx > width * 0.6) {
                        ttx = hgx - 30 * uiScale - ttW
                        tty = hgy - ttH / 2
                    } else {
                        ttx = hgx - ttW / 2
                        tty = hgy + 28 * uiScale
                    }

                    ttx = Math.max(10, Math.min(ttx, width - ttW - 10))
                    tty = Math.max(10, Math.min(tty, height - ttH - 10))

                    var ttColor = (root.isGlitchActive) ? "#8B0000" : (passwordField.text.length > 0 ? "#00F0FF" : "#39FF14")

                    ctx.save()
                    ctx.fillStyle = "rgba(4, 1, 8, 0.98)"
                    ctx.shadowBlur = 12 * uiScale
                    ctx.shadowColor = ttColor
                    var tr = 8 * uiScale
                    ctx.beginPath()
                    ctx.moveTo(ttx + tr, tty)
                    ctx.lineTo(ttx + ttW - tr, tty)
                    ctx.quadraticCurveTo(ttx + ttW, tty, ttx + ttW, tty + tr)
                    ctx.lineTo(ttx + ttW, tty + ttH - tr)
                    ctx.quadraticCurveTo(ttx + ttW, tty + ttH, ttx + ttW - tr, tty + ttH)
                    ctx.lineTo(ttx + tr, tty + ttH)
                    ctx.quadraticCurveTo(ttx, tty + ttH, ttx, tty + ttH - tr)
                    ctx.lineTo(ttx, tty + tr)
                    ctx.quadraticCurveTo(ttx, tty, ttx + tr, tty)
                    ctx.closePath()
                    ctx.fill()

                    ctx.strokeStyle = ttColor
                    ctx.lineWidth = 1.2 * uiScale
                    ctx.stroke()
                    ctx.restore()

                    ctx.save()
                    ctx.fillStyle = "rgba(255, 255, 255, 0.9)"
                    ctx.font = "bold " + Math.round(9 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                    ctx.textAlign = "left"
                    ctx.fillText("[TELEMETRY SCAN]", ttx + 10 * uiScale, tty + 15 * uiScale)

                    ctx.fillStyle = "rgba(255, 255, 255, 0.5)"
                    ctx.font = Math.round(8 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                    var specTpd = (hg.type === "BUF") ? "680ps" : ((hg.type === "NOT") ? "710ps" : ((hg.type === "AND") ? "780ps" : ((hg.type === "NAND") ? "740ps" : ((hg.type === "OR") ? "810ps" : ((hg.type === "NOR") ? "790ps" : "890ps")))))
                    var specFan = (hg.type === "BUF" || hg.type === "NOT") ? "4" : "3"
                    var specTemp = (32.0 + 8.0 * root.cpuLoad).toFixed(1) + "°C"
                    ctx.fillText("tpd: " + specTpd + " | Fan: " + specFan + " | Temp: " + specTemp, ttx + 10 * uiScale, tty + 32 * uiScale)
                    ctx.restore()
                }
            }

            // --- SUCCESS WAVE SWEEP ---
            if (root.isSuccessWaveActive && root.successWaveProgress > 0) {
                ctx.save()
                var centerX = width / 2
                var centerY = height / 2
                var maxRadius = Math.sqrt(centerX * centerX + centerY * centerY)
                var currentRadius = maxRadius * root.successWaveProgress

                // Primary glowing wave circle
                ctx.beginPath()
                ctx.arc(centerX, centerY, currentRadius, 0, Math.PI * 2)
                ctx.lineWidth = 15 * uiScale
                ctx.strokeStyle = "rgba(57, 255, 20, " + (0.8 * (1.0 - root.successWaveProgress)) + ")"
                ctx.shadowBlur = 30 * uiScale
                ctx.shadowColor = "#39FF14"
                ctx.stroke()

                // Secondary particle flash ring
                ctx.beginPath()
                ctx.arc(centerX, centerY, currentRadius - 30 * uiScale, 0, Math.PI * 2)
                ctx.lineWidth = 2 * uiScale
                ctx.strokeStyle = "rgba(0, 240, 255, " + (0.4 * (1.0 - root.successWaveProgress)) + ")"
                ctx.stroke()

                ctx.restore()
            }
        }

        Timer {
            interval: 33 // Stable 30fps - much better for SDDM performance
            running: root.visible
            repeat: true
            onTriggered: {
                if (root.isIdle) {
                    if (++root.frameCount % 5 !== 0) return;
                }
                
                // Update simulated CPU load and system telemetry noise
                root.telemetryNoiseAccumulator += 0.02
                // If not currently in a manual overclock surge, update base telemetry from simulated CPU load
                if (root.telemetrySpeedMultiplier <= 2.8) {
                    root.cpuLoad = Math.max(0.12, Math.min(0.88, 0.45 + 0.25 * Math.sin(root.telemetryNoiseAccumulator) + 0.15 * Math.sin(root.telemetryNoiseAccumulator * 2.3) + 0.05 * Math.cos(root.telemetryNoiseAccumulator * 4.7)))
                    root.telemetrySpeedMultiplier = 0.5 + 1.8 * root.cpuLoad
                }
                
                root.telemetryJitter = root.isGlitchActive ? 0.85 : (root.cpuLoad > 0.7 ? 0.06 : 0.01)

                // Typing overclocking: uses the telemetry multiplier (which surges on keystrokes)
                var speedStep = 0.008 * root.telemetrySpeedMultiplier
                bgCanvas.simulationProgress = (bgCanvas.simulationProgress + speedStep) % 1.0

                // Success Wave progress step
                if (root.isSuccessWaveActive) {
                    root.successWaveProgress = Math.min(1.0, root.successWaveProgress + 0.045)
                }

                bgCanvas.requestPaint()
                timingCanvas.requestPaint()
            }
        }
    }

    MouseArea {
        id: bgMouseArea
        anchors.fill: bgCanvas
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: {
            bgCanvas.checkHover(mouseX, mouseY)
        }
        onExited: {
            root.hoveredGateIndex = -1
            root.hoveredTableIndex = -1
            bgCanvas.requestPaint()
        }
    }

    Rectangle {
        id: laserScanline
        width: parent.width
        height: 4
        color: neonGreen
        opacity: 0.12
        z: 1

        NumberAnimation on y {
            from: 0
            to: root.height
            duration: 10000
            loops: Animation.Infinite
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width * 0.42
        height: parent.height * 0.5
        radius: width / 2
        color: "#00000000"
        z: 1
        opacity: 0.42
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#2839FF14" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: parent.width * 0.5
        height: parent.height * 0.55
        radius: width / 2
        color: "#00000000"
        z: 1
        opacity: 0.34
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#22A80800" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#00000000"
        border.width: 1
        border.color: subtleLine
        anchors.margins: 18
        radius: 22
        z: 1
    }

    RowLayout {
        id: shell
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.virtualKeyboardActive ? -Math.round(parent.height * 0.22) : 0
        width: Math.min(parent.width - Math.round(80 * uiScale), 1420)
        height: Math.min(parent.height - Math.round(40 * uiScale), 860)
        spacing: Math.round(28 * uiScale)
        z: 2

        Behavior on anchors.verticalCenterOffset {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
        }

        Rectangle {
            id: leftPanel
            Layout.fillHeight: true
            Layout.preferredWidth: 470
            radius: 28
            color: "#00000000"
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: leftPanelTop }
                GradientStop { position: 1.0; color: leftPanelBottom }
            }
            border.width: 1
            border.color: stroke
            layer.enabled: true
            layer.samples: 4

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "#00000000"
                border.width: 1
                border.color: maroonGlow
                opacity: 0.5
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Math.round(18 * uiScale)
                spacing: Math.round(8 * uiScale)

                Item {
                    id: logoFrame
                    Layout.alignment: Qt.AlignHCenter
                    width: Math.round(180 * uiScale)
                    height: Math.round(180 * uiScale)

                    Rectangle {
                        id: logoOuterRect
                        anchors.fill: parent
                        radius: 36
                        color: "#06020C" // Deepest black-charcoal for maximum contrast
                        border.width: 2
                        border.color: spectrumColor
                        clip: true

                        // Subtle breathing backlight (Not too bright)
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: parent.radius - 2
                            color: spectrumColor
                            opacity: 0.05
                            z: 0

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.02; to: 0.08; duration: 3000; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 0.08; to: 0.02; duration: 3000; easing.type: Easing.InOutQuad }
                            }
                        }

                        // Logo Image with sharp enhancement
                        Image {
                            id: baseLogo
                            anchors.fill: parent
                            anchors.margins: Math.round(22 * uiScale)
                            fillMode: Image.PreserveAspectFit
                            source: "logo.png"
                            smooth: true
                            antialiasing: true
                            z: 2
                            
                            layer.enabled: true
                            layer.effect: Glow {
                                id: logoGlowEffect
                                radius: 12
                                samples: 16
                                spread: 0.45
                                color: spectrumColor
                                transparentBorder: true
                                
                                SequentialAnimation on radius {
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 8; to: 16; duration: 4500; easing.type: Easing.InOutQuad }
                                    NumberAnimation { from: 16; to: 8; duration: 4500; easing.type: Easing.InOutQuad }
                                }
                            }
                        }

                        // Internal highlight (Light reflecting off the silicon)
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.width: 1
                            border.color: "white"
                            opacity: 0.08
                            z: 3
                        }
                    }

                    // High-quality outer aura
                    RectangularGlow {
                        anchors.fill: logoOuterRect
                        glowRadius: 28
                        spread: 0.1
                        color: spectrumColor
                        cornerRadius: logoOuterRect.radius
                        opacity: 0.35
                        z: -1
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "VLSI WORKSTATION"
                    font: titleFont
                    color: neonGreen
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: "◈  DESIGN VERIFICATION & DIGITAL VLSI  ◈"
                    font: sectionFont
                    color: neonGreen
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: subtleLine
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Item {
                        id: clockContainer
                        Layout.fillWidth: true
                        implicitHeight: Math.round(62 * uiScale)

                        Text {
                            id: greenAberration
                            text: timeString
                            font.family: "Orbitron"
                            font.pixelSize: Math.round(52 * uiScale)
                            font.bold: true
                            color: "#B839FF14"
                            x: 0
                            opacity: 0.0
                        }

                        Text {
                            id: redAberration
                            text: timeString
                            font.family: "Orbitron"
                            font.pixelSize: Math.round(52 * uiScale)
                            font.bold: true
                            color: "#A6FF1133"
                            x: 0
                            opacity: 0.0
                        }

                        Text {
                            id: timeText
                            text: timeString
                            font.family: "Orbitron"
                            font.pixelSize: Math.round(52 * uiScale)
                            font.bold: true
                            color: textPrimary
                        }

                        Timer {
                            id: glitchTimer
                            interval: 5500
                            running: true
                            repeat: true
                            onTriggered: glitchAnimation.start()
                        }

                        SequentialAnimation {
                            id: glitchAnimation

                            ParallelAnimation {
                                PropertyAction { target: greenAberration; property: "x"; value: -6 }
                                PropertyAction { target: redAberration; property: "x"; value: 5 }
                                PropertyAction { target: greenAberration; property: "opacity"; value: 0.8 }
                                PropertyAction { target: redAberration; property: "opacity"; value: 0.8 }
                            }

                            PauseAnimation { duration: 120 }

                            ParallelAnimation {
                                PropertyAction { target: greenAberration; property: "x"; value: 0 }
                                PropertyAction { target: redAberration; property: "x"; value: 0 }
                                PropertyAction { target: greenAberration; property: "opacity"; value: 0.0 }
                                PropertyAction { target: redAberration; property: "opacity"; value: 0.0 }
                            }
                        }
                    }

                    Text {
                        text: dateString
                        font: bodyFont
                        color: textMuted
                    }

                    Text {
                        text: binarySeconds
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.max(9, Math.round(11 * uiScale))
                        font.bold: true
                        font.letterSpacing: 1
                        color: neonGreen
                        opacity: 0.82
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: Math.round(12 * uiScale)
                    Layout.rightMargin: Math.round(12 * uiScale)
                    radius: 20
                    color: "#16000000"
                    border.width: 1
                    border.color: strokeSoft
                    implicitHeight: systemStatusColumn.implicitHeight + Math.round(28 * uiScale)

                    ColumnLayout {
                        id: systemStatusColumn
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: Math.round(14 * uiScale)
                        anchors.leftMargin: Math.round(16 * uiScale)
                        anchors.rightMargin: Math.round(16 * uiScale)
                        spacing: 12

                        Text {
                            text: "SYSTEM STATUS"
                            font: sectionFont
                            color: neonGreen
                        }

                        GridLayout {
                            columns: 2
                            columnSpacing: 16
                            rowSpacing: 12
                            Layout.fillWidth: true

                            Text { text: "Host"; color: textMuted; font: bodyFont }
                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: chipFill
                                border.width: 1
                                border.color: chipBorder
                                implicitHeight: Math.round(28 * uiScale)
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    text: (typeof sddm !== "undefined" && sddm !== null && sddm.hostname) ? sddm.hostname : "MANX"
                                    color: textPrimary
                                    font: bodyFont
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            Text { text: "User"; color: textMuted; font: bodyFont }
                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: chipFill
                                border.width: 1
                                border.color: chipBorder
                                implicitHeight: Math.round(28 * uiScale)
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    text: selectedUserDisplayName !== "" ? selectedUserDisplayName : "Awaiting selection"
                                    color: (selectedUserName !== "undefined" && selectedUserName !== "") ? rainbowColor : textPrimary
                                    font {
                                        family: bodyFont.family
                                        bold: true
                                        pixelSize: bodyFont.pixelSize
                                    }
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    Behavior on color { ColorAnimation { duration: 1000 } }
                                }
                            }

                            Text { text: "Session"; color: textMuted; font: bodyFont }
                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: chipFill
                                border.width: 1
                                border.color: chipBorder
                                implicitHeight: Math.round(28 * uiScale)
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    text: sessionSelector.currentText !== "" ? sessionSelector.currentText : "Unavailable"
                                    color: textPrimary
                                    font: bodyFont
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            Text { text: "Power"; color: textMuted; font: bodyFont }
                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: chipFill
                                border.width: 1
                                border.color: chipBorder
                                implicitHeight: Math.round(28 * uiScale)
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    text: "Suspend • Hibernate • Reboot • Shutdown"
                                    color: textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.bold: bodyFont.bold
                                    font.pixelSize: bodyFont.pixelSize
                                    fontSizeMode: Text.Fit
                                    minimumPixelSize: 8
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: timingSection
                    Layout.fillWidth: true
                    Layout.leftMargin: Math.round(12 * uiScale)
                    Layout.rightMargin: Math.round(12 * uiScale)
                    spacing: 4
                    Layout.topMargin: Math.round(12 * uiScale)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: "TIMING DIAGRAM"
                            font: sectionFont
                            color: neonGreen
                        }
                        Text {
                            text: "CLK · A · B · Y"
                            font: bodyFont
                            color: textMuted
                            opacity: 0.8
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                        Rectangle {
                            width: 6; height: 6; radius: 3; color: neonGreen
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.2; to: 1.0; duration: 500 }
                                NumberAnimation { from: 1.0; to: 0.2; duration: 500 }
                            }
                        }
                        Text {
                            text: "LIVE"
                            font: bodyFont
                            color: neonGreen
                        }
                    }

                    Canvas {
                        id: timingCanvas
                        Layout.fillWidth: true
                        implicitHeight: Math.round(84 * uiScale)
                        renderTarget: Canvas.FramebufferObject
                        renderStrategy: Canvas.Immediate

                        Component.onCompleted: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.clearRect(0, 0, width, height)
                            var sigNames = ["CLK", "A", "B", "Y"]
                            var sigColors = [root.neonGreen, "#00E5FF", "#FF1133", "#FF9900"]
                            var sigH = height / 4
                            var sp = bgCanvas.simulationProgress
                            for (var i = 0; i < 4; i++) {
                                var baseY = i * sigH + sigH / 2
                                var col = sigColors[i]
                                ctx.strokeStyle = "rgba(255,255,255,0.06)"
                                ctx.lineWidth = 1
                                ctx.beginPath()
                                ctx.moveTo(0, baseY)
                                ctx.lineTo(width, baseY)
                                ctx.stroke()
                                ctx.fillStyle = col
                                ctx.font = "bold " + Math.round(8 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                                ctx.textAlign = "left"
                                ctx.fillText(sigNames[i], 2, baseY + 3)
                                ctx.strokeStyle = col
                                ctx.lineWidth = 2
                                ctx.beginPath()
                                var prevVal = -1
                                var startX = 28
                                for (var x = startX; x < width; x += 2) {
                                    var t = ((x-startX) / (width-startX) + sp) % 1.0
                                    var val = 0
                                    if (i === 0) val = (Math.floor(t * 16) % 2)
                                    else if (i === 1) val = (Math.floor(t * 8) % 2)
                                    else if (i === 2) val = (Math.floor(t * 4) % 2)
                                    else {
                                        var vA = (Math.floor(t * 8) % 2)
                                        var vB = (Math.floor(t * 4) % 2)
                                        val = vA & vB
                                    }
                                    var py = baseY + (val === 0 ? 8 : -8)
                                    if (x === startX) ctx.moveTo(x, py)
                                    else if (val !== prevVal) {
                                        ctx.lineTo(x, baseY + (prevVal === 0 ? 8 : -8))
                                        ctx.lineTo(x, py)
                                    } else ctx.lineTo(x, py)
                                    prevVal = val
                                }
                                ctx.stroke()
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: timingStats
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.max(8, Math.round(9 * uiScale))
                        color: textMuted
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: Math.round(4 * uiScale)
                        Layout.rightMargin: Math.round(4 * uiScale)
                        radius: 12
                        color: "#12000000"
                        border.width: 1
                        border.color: strokeSoft
                        implicitHeight: acceleratorLayout.implicitHeight + Math.round(14 * uiScale)

                        ColumnLayout {
                            id: acceleratorLayout
                            anchors.fill: parent
                            anchors.margins: Math.round(8 * uiScale)
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "MANX AI ACCELERATOR"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.max(9, Math.round(10.5 * uiScale))
                                    font.bold: true
                                    color: "#00F0FF"
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    width: 6; height: 6; radius: 3
                                    color: root.isGlitchActive ? "#FF1133" : ((passwordField.text.length > 0) ? "#FFD700" : "#39FF14")
                                    border.width: 1
                                    border.color: "white"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: subtleLine
                                opacity: 0.2
                            }

                            GridLayout {
                                columns: 2
                                columnSpacing: 8
                                rowSpacing: 1
                                Layout.fillWidth: true

                                property font tinyFont: Qt.font({ family: "JetBrainsMono Nerd Font", pixelSize: Math.max(8, Math.round(9.5 * uiScale)), bold: true })

                                Text { text: "Engine"; color: textMuted; font: parent.tinyFont }
                                Text { text: "NIX-VLSI WORKSTATION ENGINE"; color: textPrimary; font: parent.tinyFont }

                                Text { text: "Load"; color: textMuted; font: parent.tinyFont }
                                Text {
                                    text: (48.4 + 48.0 * root.cpuLoad).toFixed(1) + " TFLOPs"
                                    color: root.isGlitchActive ? "#FF1133" : ((passwordField.text.length > 0) ? "#00F0FF" : "#39FF14")
                                    font: parent.tinyFont
                                }

                                Text { text: "Temp"; color: textMuted; font: parent.tinyFont }
                                Text {
                                    text: (34.2 + 12.0 * root.cpuLoad).toFixed(1) + " °C"
                                    color: root.isGlitchActive ? "#FF1133" : ((root.cpuLoad > 0.72) ? "#FF1133" : "#39FF14")
                                    font: parent.tinyFont
                                }

                                Text { text: "State"; color: textMuted; font: parent.tinyFont }
                                Text {
                                    text: root.isGlitchActive ? "FAULT (0x8F9C)" : (passwordField.text.length > 0 ? "CRYPT_OP (0x21A0)" : "RUNNING (0x90A1)")
                                    color: root.isGlitchActive ? "#FF1133" : (passwordField.text.length > 0 ? "#FFD700" : "#39FF14")
                                    font: parent.tinyFont
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rightPanel
            Layout.fillHeight: true
            Layout.fillWidth: true
            radius: 28
            color: "#00000000"
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: rightPanelTop }
                GradientStop { position: 1.0; color: rightPanelBottom }
            }
            border.width: 1
            border.color: stroke
            layer.enabled: true
            layer.samples: 4

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "#00000000"
                border.width: 1
                border.color: maroonGlow
                opacity: 0.45
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Math.round(16 * uiScale)
                spacing: Math.round(5 * uiScale)

                                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Math.round(6 * uiScale)
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: false
                        Layout.preferredWidth: Math.round(360 * uiScale)
                        spacing: 8

                        Text {
                            text: root.verilogLines1[root.verilogIndex]
                            opacity: root.verilogOpacity
                            font {
                                family: titleFont.family
                                bold: true
                                pixelSize: Math.max(16, Math.round(30 * uiScale))
                                letterSpacing: 1.2
                            }
                            color: maroonBright
                        }

                        RowLayout {
                            opacity: root.verilogOpacity
                            spacing: 0
                            Text {
                                text: root.verilogIndex === 0 ? "assign active_operator = \"" : root.verilogLines2[root.verilogIndex]
                                font {
                                    family: bodyFont.family
                                    pixelSize: Math.max(12, Math.round(16 * uiScale))
                                    bold: root.verilogIndex !== 0
                                }
                                color: root.verilogIndex === 0 ? neonGreen : rainbowColor
                            }
                            Text {
                                text: (typeof selectedUserName !== "undefined" && selectedUserName !== "") ? selectedUserName : "root"
                                visible: root.verilogIndex === 0
                                font {
                                    family: bodyFont.family
                                    bold: true
                                    pixelSize: Math.max(12, Math.round(16 * uiScale))
                                }
                                color: rainbowColor
                                Behavior on color { ColorAnimation { duration: 1000 } }
                            }
                            Text {
                                text: "\";"
                                visible: root.verilogIndex === 0
                                font {
                                    family: bodyFont.family
                                    pixelSize: Math.max(12, Math.round(16 * uiScale))
                                }
                                color: neonGreen
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }

                    Item {
                        id: particleField
                        Layout.fillWidth: true
                        Layout.minimumWidth: Math.round(100 * uiScale)
                        Layout.preferredHeight: Math.round(48 * uiScale)
                        Layout.alignment: Qt.AlignVCenter
                        clip: true
                        
                        Timer {
                            interval: 50
                            running: true
                            repeat: true
                            onTriggered: {
                                for(var i=0; i<particleRepeater.count; i++) {
                                    var item = particleRepeater.itemAt(i);
                                    if(item) {
                                        if (Math.random() > 0.94) {
                                            item.tx = Math.random() * (particleField.width - item.width);
                                            item.ty = Math.random() * (particleField.height - item.height);
                                        }
                                    }
                                }
                            }
                        }

                        Repeater {
                            id: particleRepeater
                            model: 12
                            delegate: Rectangle {
                                id: particle
                                width: Math.round(2 * uiScale); height: width; radius: width/2
                                color: index % 3 === 0 ? neonGreen : (index % 3 === 1 ? rainbowColor : "#00E5FF")
                                opacity: 0.8
                                z: 10
                                
                                property real tx: Math.random() * 80
                                property real ty: Math.random() * 30

                                Behavior on x { NumberAnimation { duration: 2200 + Math.random() * 1000; easing.type: Easing.InOutQuad } }
                                Behavior on y { NumberAnimation { duration: 2200 + Math.random() * 1000; easing.type: Easing.InOutQuad } }
                                
                                x: tx
                                y: ty

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.2; to: 0.9; duration: 1000 + Math.random() * 1000; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 0.9; to: 0.2; duration: 1000 + Math.random() * 1000; easing.type: Easing.InOutSine }
                                }
                                
                                // High-performance subtle glow
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width * 4
                                    height: width
                                    radius: width / 2
                                    color: parent.color
                                    opacity: parent.opacity * 0.4
                                    z: -1
                                }
                            }
                        }
                    }

                    Item {
                        width: Math.round(42 * uiScale)
                        height: Math.round(42 * uiScale)

                        Text {
                            anchors.centerIn: parent
                            text: "◈"
                            font.family: "Orbitron"
                            font.pixelSize: Math.round(28 * uiScale)
                            font.bold: true
                            color: neonGreen
                            opacity: 0.9

                            SequentialAnimation on rotation {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0; to: 360; duration: 4000; easing.type: Easing.Linear }
                            }
                        }
                    }

                    Item {
                        width: Math.round(130 * uiScale)
                        height: Math.round(130 * uiScale)

                        RectangularGlow {
                            id: avatarOuterGlow
                            anchors.fill: avatarBorderRect
                            glowRadius: 18
                            spread: 0.2
                            color: spectrumColor
                            cornerRadius: avatarBorderRect.radius
                            opacity: authenticating ? 0.95 : 0.65

                            SequentialAnimation on scale {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.96; to: 1.03; duration: 1800; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 1.03; to: 0.96; duration: 1800; easing.type: Easing.InOutQuad }
                            }
                        }

                        Rectangle {
                            id: avatarBorderRect
                            width: Math.round(112 * uiScale)
                            height: Math.round(112 * uiScale)
                            anchors.centerIn: parent
                            radius: Math.round(56 * uiScale)
                            color: "#12000000"
                            border.width: 3
                            border.color: spectrumColor

                            Image {
                                id: avatarImage
                                anchors.fill: parent
                                anchors.margins: 3
                                fillMode: Image.PreserveAspectCrop
                                source: selectedUserIcon !== "" ? selectedUserIcon : "logo.png"
                                smooth: true
                                antialiasing: true
                                visible: false

                                onStatusChanged: {
                                    if (status === Image.Error && source != "logo.png")
                                        source = "logo.png"
                                }
                            }

                            Rectangle {
                                id: avatarMask
                                anchors.fill: avatarImage
                                radius: width / 2
                                visible: false
                            }

                            OpacityMask {
                                anchors.fill: avatarImage
                                source: avatarImage
                                maskSource: avatarMask
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: subtleLine
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 3
                        radius: 2
                        color: neonGreen
                    }

                    Text {
                        text: "USER PROFILES"
                        font: sectionFont
                        color: neonGreen
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: subtleLine
                        opacity: 0.5
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(225 * uiScale)
                    color: "transparent"

                    ListView {
                        id: userList
                        width: Math.min(parent.width, count * Math.round(210 * uiScale))
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        orientation: ListView.Horizontal
                        model: userModel
                        currentIndex: -1
                        focus: true
                        KeyNavigation.tab: sessionSelector
                        highlightMoveDuration: 180
                        cacheBuffer: 512

                        Keys.onLeftPressed: currentIndex = Math.max(0, currentIndex - 1)
                        Keys.onRightPressed: currentIndex = Math.min(count - 1, currentIndex + 1)

                        Timer {
                            id: startupTimer
                            interval: 100
                            running: true
                            repeat: true
                            onTriggered: {
                                if (typeof userModel !== "undefined" && userModel && userModel.count > 0) {
                                    userList.currentIndex = (userModel.lastIndex >= 0 && userModel.lastIndex < userModel.count) ? userModel.lastIndex : 0
                                    userList.positionViewAtIndex(userList.currentIndex, ListView.Contain)
                                    syncSelectedUser()
                                    startupTimer.stop()
                                }
                            }
                        }

                        Component.onCompleted: {
                            startupTimer.start()
                        }

                        onCurrentItemChanged: syncSelectedUser()

                        delegate: Rectangle {
                            id: userCard
                            property string userName: name
                            property string displayName: realName !== "" ? realName : name
                            property string iconSource: icon !== "" ? icon : "logo.png"
                            property bool isActive: ListView.isCurrentItem

                            width: Math.round(200 * uiScale)
                            height: Math.round(225 * uiScale)
                            color: "transparent"
                            scale: userMouse.pressed ? 0.96 : (userMouse.containsMouse || userCard.isActive ? 1.05 : 1.0)

                            Behavior on scale { NumberAnimation { duration: 120 } }

                            MouseArea {
                                id: userMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    userList.currentIndex = index
                                    userList.positionViewAtIndex(index, ListView.Contain)
                                    passwordField.forceActiveFocus()
                                }
                            }

                            Column {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: Math.round(10 * uiScale)
                                spacing: Math.round(6 * uiScale)
                                width: parent.width

                                Item {
                                    id: avatarContainer
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Math.round(160 * uiScale)
                                    height: Math.round(160 * uiScale)

                                    RectangularGlow {
                                        id: avatarGlow
                                        anchors.fill: cardAvatarRect
                                        glowRadius: userCard.isActive ? (userMouse.containsMouse ? 36 : 8) : (userMouse.containsMouse ? 20 : 0)
                                        spread: userCard.isActive ? (userMouse.containsMouse ? 0.25 : 0.05) : (userMouse.containsMouse ? 0.15 : 0.0)
                                        color: spectrumColor
                                        cornerRadius: cardAvatarRect.radius
                                        opacity: userCard.isActive ? (authenticating ? 0.95 : 0.65) : (userMouse.containsMouse ? 0.8 : 0.0)

                                        Behavior on glowRadius { NumberAnimation { duration: 180 } }
                                        Behavior on spread { NumberAnimation { duration: 180 } }
                                        Behavior on opacity { NumberAnimation { duration: 120 } }
                                    }

                                    Rectangle {
                                        id: cardAvatarRect
                                        anchors.fill: parent
                                        radius: Math.round(80 * uiScale)
                                        color: "#16000000"
                                        border.width: userCard.isActive ? 2 : 1
                                        border.color: userCard.isActive ? spectrumColor : strokeSoft

                                        Image {
                                            id: cardAvatarImage
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            fillMode: Image.PreserveAspectCrop
                                            source: userCard.iconSource
                                            smooth: true
                                            antialiasing: true
                                            visible: false

                                            onStatusChanged: {
                                                if (status === Image.Error && source != "logo.png")
                                                    source = "logo.png"
                                            }
                                        }

                                        Rectangle {
                                            id: cardAvatarMask
                                            anchors.fill: cardAvatarImage
                                            radius: width / 2
                                            visible: false
                                        }

                                        OpacityMask {
                                            anchors.fill: cardAvatarImage
                                            source: cardAvatarImage
                                            maskSource: cardAvatarMask
                                        }
                                    }
                                }

                                Text {
                                    id: nameText
                                    width: parent.width
                                    text: userCard.displayName.toUpperCase()
                                    color: userCard.isActive ? textPrimary : textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.bold: true
                                    font.pixelSize: userCard.isActive ? Math.round(18 * uiScale) : Math.round(14 * uiScale)
                                    font.letterSpacing: userCard.isActive ? 3 : 1
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight

                                    scale: userCard.isActive ? 1.08 : 1.0

                                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                                    Behavior on font.letterSpacing { NumberAnimation { duration: 250 } }
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    layer.enabled: false // Disabling expensive shadow layer for performance
                                }

                                Text {
                                    width: parent.width
                                    text: userCard.isActive ? "ACTIVE" : ""
                                    color: neonGreen
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(11 * uiScale)
                                    font.bold: true
                                    font.letterSpacing: 1
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: userCard.isActive
                                }
                            }
                        }

                        QQC2.ScrollIndicator.horizontal: QQC2.ScrollIndicator {}
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 3
                        radius: 2
                        color: neonGreen
                    }

                    Text {
                        text: "SESSION TARGET"
                        font: sectionFont
                        color: neonGreen
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: subtleLine
                        opacity: 0.5
                    }
                }



                QQC2.ComboBox {
                    id: sessionSelector
                    Layout.fillWidth: true
                    implicitHeight: Math.round(44 * uiScale)
                    model: sessionModel
                    textRole: "name"
                    currentIndex: (typeof sessionModel !== "undefined" && sessionModel && sessionModel.count > 0) ? Math.max(0, sessionModel.lastIndex) : -1
                    font: actionFont
                    KeyNavigation.tab: passwordField
                    KeyNavigation.backtab: userList

                    onCurrentTextChanged: selectedSessionName = currentText

                    contentItem: Text {
                        leftPadding: 16
                        rightPadding: 16
                        text: sessionSelector.displayText !== "" ? ("SESSION // " + sessionSelector.displayText.toUpperCase()) : "SESSION // UNAVAILABLE"
                        font: sessionSelector.font
                        color: textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    indicator: Text {
                        x: sessionSelector.width - width - 16
                        y: sessionSelector.topPadding + (sessionSelector.availableHeight - height) / 2
                        text: "▼"
                        font: bodyFont
                        color: sessionSelector.popup.visible ? maroonBright : (sessionSelector.hovered ? neonGreen : textMuted)
                        rotation: sessionSelector.popup.visible ? 180 : (sessionSelector.hovered ? 15 : 0)

                        Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    background: Item {
                        RectangularGlow {
                            id: selectorGlow
                            anchors.fill: selectorBg
                            glowRadius: sessionSelector.hovered || sessionSelector.popup.visible ? 8 : 0
                            spread: 0.1
                            color: sessionSelector.popup.visible ? "#66FF1133" : "#4439FF14"
                            cornerRadius: selectorBg.radius

                            Behavior on glowRadius { NumberAnimation { duration: 200 } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Rectangle {
                            id: selectorBg
                            anchors.fill: parent
                            radius: 16
                            color: inputFill
                            border.width: sessionSelector.visualFocus || sessionSelector.popup.visible ? 2 : 1
                            border.color: sessionSelector.popup.visible ? maroonBright : (sessionSelector.visualFocus || sessionSelector.hovered ? selectedBorder : inputBorder)

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: inputFill }
                                GradientStop { position: 1.0; color: sessionSelector.popup.visible ? "#22FF1133" : (sessionSelector.hovered ? "#1139FF14" : "#00000000") }
                            }

                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }
                    }

                    popup: QQC2.Popup {
                        y: sessionSelector.height + 6
                        width: sessionSelector.width
                        padding: 8
                        modal: true
                        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside

                        enter: Transition {
                            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250; easing.type: Easing.OutQuad }
                            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 250; easing.type: Easing.OutBack }
                        }
                        exit: Transition {
                            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.InQuad }
                            NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 150; easing.type: Easing.InQuad }
                        }

                        contentItem: ListView {
                            clip: true
                            implicitHeight: Math.min(contentHeight, 250)
                            model: sessionSelector.popup.visible ? sessionSelector.delegateModel : null
                            currentIndex: sessionSelector.highlightedIndex
                            QQC2.ScrollIndicator.vertical: QQC2.ScrollIndicator {}
                        }

                        background: Item {
                            RectangularGlow {
                                id: popupGlow
                                anchors.fill: popupBg
                                glowRadius: 16
                                spread: 0.15
                                color: "#CCFF1133"
                                cornerRadius: popupBg.radius
                            }

                            Rectangle {
                                id: popupBg
                                anchors.fill: parent
                                radius: 18
                                color: "#ED0F020E"
                                border.width: 2
                                border.color: maroonBright

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: parent.radius - 1
                                    color: "transparent"
                                    border.width: 1
                                    border.color: "#3FFF1133"
                                }
                            }
                        }
                    }

                    delegate: QQC2.ItemDelegate {
                        id: delegateItem
                        width: sessionSelector.width - 16
                        implicitHeight: 48

                        contentItem: RowLayout {
                            anchors.fill: parent
                            spacing: 12

                            Rectangle {
                                id: highlightBar
                                Layout.preferredWidth: highlighted ? 6 : 0
                                Layout.preferredHeight: 24
                                radius: 3
                                color: maroonBright
                                Behavior on Layout.preferredWidth { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (typeof modelData !== "undefined" && modelData && modelData.name) ? modelData.name : (model && model.name ? model.name : "")
                                font: bodyFont
                                color: highlighted ? textPrimary : textMuted
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight

                                scale: highlighted ? 1.04 : 1.0

                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            Item {
                                Layout.preferredWidth: highlightBar.Layout.preferredWidth
                                Layout.preferredHeight: 24
                            }
                        }

                        background: Rectangle {
                            radius: 12
                            color: highlighted ? "#2AEE1133" : "transparent"
                            border.width: highlighted ? 1 : 0
                            border.color: "#80FF1133"

                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 3
                        radius: 2
                        color: neonGreen
                    }

                    Text {
                        text: "PASSWORD"
                        font: sectionFont
                        color: neonGreen
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: subtleLine
                        opacity: 0.5
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: passwordField.activeFocus ? 10 : 4
                    radius: 6
                    color: passwordGlow
                    opacity: passwordField.activeFocus ? 0.95 : 0.35

                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 120 } }

                    SequentialAnimation on opacity {
                        running: passwordField.activeFocus
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.35; to: 0.95; duration: 1100; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.95; to: 0.35; duration: 1100; easing.type: Easing.InOutQuad }
                    }
                }

                QQC2.TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    property bool showPassword: false
                    echoMode: showPassword ? TextInput.Normal : TextInput.Password
                    placeholderText: "ENTER AUTHENTICATION KEY"
                    font: actionFont
                    color: showPassword ? maroonBright : "transparent"
                    selectedTextColor: showPassword ? maroonBright : "transparent"
                    horizontalAlignment: TextInput.AlignLeft
                    selectByMouse: true
                    focus: true
                    clip: true // Ensure content stays inside
                    KeyNavigation.tab: loginButton
                    KeyNavigation.backtab: sessionSelector
                    
                    // --- VIRTUAL KEYBOARD INPUT FIX ---
                    inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                    passwordCharacter: "●"
                    
                    onActiveFocusChanged: {
                        if (activeFocus && root.virtualKeyboardActive && typeof Qt !== "undefined" && typeof Qt.inputMethod !== "undefined") {
                            Qt.inputMethod.show()
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_CapsLock) {
                            root.isCapsActiveHeuristic = !root.isCapsActiveHeuristic;
                        } else if (event.text.length === 1) {
                            var char = event.text;
                            var isUpper = (char >= 'A' && char <= 'Z');
                            var isLower = (char >= 'a' && char <= 'z');
                            var shiftPressed = (event.modifiers & Qt.ShiftModifier) !== 0;

                            if ((isUpper && !shiftPressed) || (isLower && shiftPressed)) {
                                root.isCapsActiveHeuristic = true;
                            } else if ((isLower && !shiftPressed) || (isUpper && shiftPressed)) {
                                root.isCapsActiveHeuristic = false;
                            }
                        }
                    }

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        clip: true // Ensure dots stay inside the margins

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6
                            visible: passwordField.text !== "" && !passwordField.showPassword

                            Repeater {
                                model: passwordField.text.length
                                delegate: Text {
                                    text: "◈"
                                    font: passwordField.font
                                    color: index % 2 === 0 ? maroonBright : neonGreen
                                    scale: 1.0

                                    Component.onCompleted: bounceAnim.start()

                                    SequentialAnimation {
                                        id: bounceAnim
                                        NumberAnimation { target: parent; property: "scale"; from: 0.0; to: 1.4; duration: 120; easing.type: Easing.OutBack }
                                        NumberAnimation { target: parent; property: "scale"; from: 1.4; to: 1.0; duration: 100; easing.type: Easing.OutQuad }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        id: eyeButton
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        visible: passwordField.text !== ""
                        opacity: (mouseArea.hovered || passwordField.showPassword) ? 1.0 : 0.4

                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        property real eyeOpenness: passwordField.showPassword ? 1.0 : 0.0
                        property real scanRotation: 0.0

                        Behavior on eyeOpenness { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

                        RotationAnimation on scanRotation {
                            from: 0
                            to: 360
                            duration: 4000
                            loops: Animation.Infinite
                            running: passwordField.showPassword
                        }

                        Canvas {
                            id: eyeCanvas
                            anchors.fill: parent

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.clearRect(0, 0, width, height)

                                var w = width
                                var h = height
                                var cx = w / 2
                                var cy = h / 2
                                var scale = uiScale

                                var activeColor = neonGreen
                                var inactiveColor = maroonBright
                                var warningColor = maroonBright

                                var currentColor = passwordField.showPassword ? activeColor : inactiveColor

                                // 1. Concentric digital scan arcs (active state only)
                                if (passwordField.showPassword) {
                                    ctx.save()
                                    ctx.strokeStyle = "rgba(57, 255, 20, 0.2)"
                                    ctx.lineWidth = 1 * scale
                                    ctx.beginPath()
                                    ctx.arc(cx, cy, 12 * scale, eyeButton.scanRotation * Math.PI / 180, (eyeButton.scanRotation + 100) * Math.PI / 180)
                                    ctx.stroke()
                                    ctx.beginPath()
                                    ctx.arc(cx, cy, 12 * scale, (eyeButton.scanRotation + 180) * Math.PI / 180, (eyeButton.scanRotation + 280) * Math.PI / 180)
                                    ctx.stroke()
                                    ctx.restore()
                                }

                                // 2. Cybernetic Iris / Pupil (fades as eye closes)
                                if (eyeButton.eyeOpenness > 0.05) {
                                    ctx.save()
                                    var pupilColor = passwordField.showPassword ? activeColor : inactiveColor
                                    ctx.fillStyle = pupilColor
                                    ctx.globalAlpha = eyeButton.eyeOpenness
                                    ctx.shadowBlur = passwordField.showPassword ? (10 * scale) : 0
                                    ctx.shadowColor = pupilColor

                                    ctx.beginPath()
                                    ctx.arc(cx, cy, 3.5 * scale, 0, 2 * Math.PI)
                                    ctx.fill()

                                    ctx.strokeStyle = currentColor
                                    ctx.lineWidth = 0.8 * scale
                                    ctx.beginPath()
                                    ctx.arc(cx, cy, 6 * scale, 0, 2 * Math.PI)
                                    ctx.stroke()
                                    ctx.restore()
                                }

                                // 3. Eyelids (Upper/Lower morphing human arcs)
                                ctx.save()
                                ctx.strokeStyle = currentColor
                                ctx.lineWidth = 1.8 * scale
                                ctx.lineCap = "round"

                                if (passwordField.showPassword) {
                                    ctx.shadowBlur = 8 * scale
                                    ctx.shadowColor = activeColor
                                } else {
                                    ctx.shadowBlur = 8 * scale
                                    ctx.shadowColor = maroonBright
                                }

                                var upperYOffset = 6.5 * scale * eyeButton.eyeOpenness
                                var lowerYOffset = 6.5 * scale * eyeButton.eyeOpenness

                                ctx.beginPath()
                                if (eyeButton.eyeOpenness > 0.01) {
                                    ctx.moveTo(3 * scale, cy)
                                    ctx.quadraticCurveTo(cx, cy - upperYOffset, w - 3 * scale, cy)
                                    ctx.quadraticCurveTo(cx, cy + lowerYOffset, 3 * scale, cy)
                                } else {
                                    // Closed lid (slight curve down)
                                    ctx.moveTo(3 * scale, cy - 1 * scale)
                                    ctx.quadraticCurveTo(cx, cy + 2 * scale, w - 3 * scale, cy - 1 * scale)
                                }
                                ctx.stroke()
                                ctx.restore()

                                // 4. Eyelashes (emerge smoothly as the eye closes)
                                var lashFactor = 1.0 - eyeButton.eyeOpenness
                                if (lashFactor > 0.05) {
                                    ctx.save()
                                    ctx.strokeStyle = currentColor
                                    ctx.lineWidth = 1.5 * scale
                                    ctx.lineCap = "round"
                                    ctx.globalAlpha = lashFactor

                                    var maxLashLen = 4.5 * scale
                                    var lashLen = maxLashLen * lashFactor

                                    // Left eyelash (angles down-left)
                                    ctx.beginPath()
                                    var lx = cx - 5 * scale
                                    var ly = cy + 1 * scale
                                    ctx.moveTo(lx, ly)
                                    ctx.lineTo(lx - 2 * scale * lashFactor, ly + lashLen)
                                    ctx.stroke()

                                    // Middle eyelash (goes straight down)
                                    ctx.beginPath()
                                    var mx = cx
                                    var my = cy + 2 * scale
                                    ctx.moveTo(mx, my)
                                    ctx.lineTo(mx, my + lashLen * 1.1)
                                    ctx.stroke()

                                    // Right eyelash (angles down-right)
                                    ctx.beginPath()
                                    var rx = cx + 5 * scale
                                    var ry = cy + 1 * scale
                                    ctx.moveTo(rx, ry)
                                    ctx.lineTo(rx + 2 * scale * lashFactor, ry + lashLen)
                                    ctx.stroke()

                                    ctx.restore()
                                }
                            }

                            Connections {
                                target: eyeButton
                                function onEyeOpennessChanged() { eyeCanvas.requestPaint() }
                                function onScanRotationChanged() { eyeCanvas.requestPaint() }
                            }

                            Connections {
                                target: passwordField
                                function onShowPasswordChanged() { eyeCanvas.requestPaint() }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                passwordField.showPassword = !passwordField.showPassword
                                root.isGlitchActive = true
                                glitchCoolDown.restart()
                            }
                        }
                    }

                    // --- VLSI VIRTUAL KEYBOARD TOGGLE (NEW) ---
                    Item {
                        id: vkbToggle
                        anchors.right: (typeof eyeButton !== "undefined" && eyeButton.visible) ? eyeButton.left : parent.right
                        anchors.rightMargin: (typeof eyeButton !== "undefined" && eyeButton.visible) ? 8 : 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        visible: true
                        
                        property bool isActive: root.virtualKeyboardActive

                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.round(24 * uiScale)
                            height: Math.round(18 * uiScale)
                            radius: 3
                            color: vkbToggle.isActive ? "#1A39FF14" : "#1A000000"
                            border.color: vkbToggle.isActive ? neonGreen : (vkbMouse.containsMouse ? maroonBright : strokeSoft)
                            border.width: vkbToggle.isActive ? 1.5 : 1

                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }

                            Text {
                                anchors.centerIn: parent
                                text: "⌨"
                                font.pixelSize: Math.round(12 * uiScale)
                                color: vkbToggle.isActive ? neonGreen : (vkbMouse.containsMouse ? maroonBright : textMuted)
                                
                                SequentialAnimation on opacity {
                                    running: vkbToggle.isActive
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 0.4; duration: 800; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 0.4; to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                                }
                            }
                        }

                        MouseArea {
                            id: vkbMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.virtualKeyboardActive = !root.virtualKeyboardActive
                                if (root.virtualKeyboardActive) {
                                    passwordField.forceActiveFocus()
                                    if (typeof Qt !== "undefined" && typeof Qt.inputMethod !== "undefined") {
                                        Qt.inputMethod.show()
                                    }
                                } else {
                                    if (typeof Qt !== "undefined" && typeof Qt.inputMethod !== "undefined") {
                                        Qt.inputMethod.hide()
                                    }
                                }
                                root.isGlitchActive = true
                                glitchCoolDown.restart()
                            }
                        }
                    }

                    property real shakeOffset: 0
                    transform: Translate { x: passwordField.shakeOffset }

                    SequentialAnimation {
                        id: shakeAnim
                        NumberAnimation { target: passwordField; property: "shakeOffset"; to: -10; duration: 50; easing.type: Easing.OutQuad }
                        NumberAnimation { target: passwordField; property: "shakeOffset"; to: 10; duration: 100; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: passwordField; property: "shakeOffset"; to: -6; duration: 80; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: passwordField; property: "shakeOffset"; to: 6; duration: 80; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: passwordField; property: "shakeOffset"; to: 0; duration: 50; easing.type: Easing.InQuad }
                    }

                    onTextChanged: {
                        root.resetIdle()
                        if (!authenticating) {
                            messageColor = textMuted
                            messageText = "Awaiting secure authentication"
                        }
                        typePulse.restart()
                        // Trigger Overclock surge
                        root.telemetrySpeedMultiplier = 4.0
                        overclockCoolDown.restart()
                        root.isGlitchActive = true
                        glitchCoolDown.restart()
                    }

                    Timer {
                        id: overclockCoolDown
                        interval: 400
                        onTriggered: root.telemetrySpeedMultiplier = 1.0
                    }
                    
                    Timer {
                        id: glitchCoolDown
                        interval: 150
                        onTriggered: root.isGlitchActive = false
                    }

                    SequentialAnimation {
                        id: typePulse
                        PropertyAnimation { target: passwordBorderRect; property: "border.color"; to: neonGreen; duration: 60 }
                        PropertyAnimation { target: passwordBorderRect; property: "border.color"; to: passwordField.activeFocus ? selectedBorder : (messageColor === textDanger ? textDanger : inputBorder); duration: 200 }
                    }

                    onAccepted: attemptLogin()

                    background: Rectangle {
                        id: passwordBorderRect
                        radius: 16
                        color: inputFill
                        border.width: passwordField.activeFocus ? 2 : 1
                        border.color: passwordField.activeFocus ? selectedBorder : (messageColor === textDanger ? textDanger : inputBorder)

                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        SequentialAnimation {
                            id: failedStrobe
                            loops: 4
                            PropertyAnimation { target: passwordBorderRect; property: "border.color"; to: maroonBright; duration: 120 }
                            PropertyAnimation { target: passwordBorderRect; property: "border.color"; to: "transparent"; duration: 120 }
                            PropertyAnimation { target: passwordBorderRect; property: "border.color"; to: passwordField.activeFocus ? selectedBorder : inputBorder; duration: 120 }
                        }

                        function triggerFailGlow() {
                            failedStrobe.start()
                        }
                    }

                    placeholderTextColor: textMuted
                    leftPadding: 16
                    rightPadding: passwordField.text !== "" ? 54 : 16
                    topPadding: 12
                    bottomPadding: 12
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    QQC2.Button {
                        id: loginButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(54 * uiScale)
                        font: actionFont
                        enabled: !authenticating
                        KeyNavigation.tab: clearButton
                        KeyNavigation.backtab: passwordField

                        onClicked: {
                            root.resetIdle()
                            attemptLogin()
                        }

                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            spacing: 12

                            QQC2.BusyIndicator {
                                running: authenticating
                                visible: authenticating
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 18
                            }

                            Text {
                                Layout.fillWidth: true
                                text: authenticating ? "AUTHENTICATING..." : "DECRYPT & ENTER"
                                font: loginButton.font
                                color: loginButton.down || loginButton.hovered ? buttonTextDark : neonGreen
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        background: Rectangle {
                            radius: 16
                            color: loginButton.down || loginButton.hovered ? neonGreen : buttonFill
                            border.width: 1
                            border.color: selectedBorder
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }

                    QQC2.Button {
                        id: clearButton
                        Layout.preferredWidth: Math.round(150 * uiScale)
                        Layout.preferredHeight: Math.round(54 * uiScale)
                        font: actionFont
                        onClicked: passwordField.text = ""
                        KeyNavigation.tab: userList
                        KeyNavigation.backtab: loginButton

                        contentItem: Text {
                            text: "CLEAR"
                            font: clearButton.font
                            color: clearButton.hovered ? buttonTextDark : textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 16
                            color: clearButton.hovered ? maroonBright : "#18FF1133"
                            border.width: 1
                            border.color: maroonBright
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 38
                    radius: 12
                    color: "#16000000"
                    border.width: 1
                    border.color: root.isCapsActive ? textWarning : messageColor

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        // Caps Lock Indicator
                        Rectangle {
                            Layout.preferredWidth: 10
                            Layout.preferredHeight: 10
                            radius: 5
                            color: textWarning
                            visible: root.isCapsActive
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.3; to: 1.0; duration: 450 }
                                NumberAnimation { from: 1.0; to: 0.3; duration: 450 }
                            }
                        }

                        Text {
                            id: messageTextItem
                            Layout.fillWidth: true
                            text: root.isCapsActive ? "WARNING // wire caps_lock = 1'b1; // DECRYPTION_FAULT_RISK" : messageText
                            color: root.isCapsActive ? textWarning : messageColor
                            font {
                                family: bodyFont.family
                                bold: true
                                pixelSize: bodyFont.pixelSize
                            }
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        Item {
                            Layout.preferredWidth: 10
                            Layout.preferredHeight: 10
                            visible: root.isCapsActive
                        }
                    }
                }

                // Dynamic VLSI Logic Flow Particle Emitter (Gap Animation)
                Item {
                    id: logicFlowEmitter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: Math.round(60 * uiScale)
                    clip: true

                    // Background signal bus trace (Lightning / Electrical logic pulse effect)
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: Math.round(1 * uiScale)
                        color: spectrumColor
                        opacity: 0.16

                        // Glowing backlight
                        RectangularGlow {
                            anchors.fill: parent
                            glowRadius: Math.round(8 * uiScale)
                            spread: 0.2
                            color: parent.color
                            opacity: 0.7
                        }

                        // Lightning electrical pulse dot
                        Rectangle {
                            id: pulseDot
                            width: Math.round(35 * uiScale)
                            height: Math.round(2 * uiScale)
                            radius: 1
                            color: "#FFFFFF"

                            layer.enabled: true
                            layer.effect: Glow {
                                radius: Math.round(6 * uiScale)
                                samples: 10
                                color: "#00E5FF"
                            }

                            NumberAnimation on x {
                                from: -100
                                to: logicFlowEmitter.width + 100
                                duration: 3200
                                loops: Animation.Infinite
                                easing.type: Easing.InOutQuad
                            }
                        }

                        // Subtle active voltage flicker on the trace
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.16; to: 0.35; duration: 90; easing.type: Easing.Linear }
                            NumberAnimation { from: 0.35; to: 0.10; duration: 60; easing.type: Easing.Linear }
                            NumberAnimation { from: 0.10; to: 0.26; duration: 110; easing.type: Easing.Linear }
                            NumberAnimation { from: 0.26; to: 0.16; duration: 2200; easing.type: Easing.InOutQuad }
                        }
                    }

                    Repeater {
                        model: 12 // Perfectly balanced for speed and visuals

                        delegate: Item {
                            id: particleItem
                            width: Math.round(16 * uiScale)
                            height: Math.round(16 * uiScale)

                            property color particleColor: "#39FF14"
                            property string particleText: "0"

                            // --- LIGHTWEIGHT CYBER PARTICLES ---
                            
                            // 1. Digital '0' or '1'
                            Text {
                                anchors.centerIn: parent
                                text: parent.particleText
                                color: parent.particleColor
                                font { family: "JetBrainsMono Nerd Font"; bold: true; pixelSize: Math.round(13 * uiScale) }
                                visible: parent.particleText !== "•"
                                opacity: 0.9
                            }

                            // 2. Hollow Logic Circle (The "Cool" Part)
                            Rectangle {
                                anchors.centerIn: parent
                                width: Math.round(8 * uiScale)
                                height: Math.round(8 * uiScale)
                                radius: width / 2
                                color: "transparent"
                                border.width: 2
                                border.color: parent.particleColor
                                visible: parent.particleText === "•"
                                
                                // Internal "Core" dot
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 2; height: 2; radius: 1
                                    color: "white"
                                    opacity: 0.8
                                }
                            }

                            // Cyber Flicker Effect (Very Cheap Performance)
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.9; to: 0.4; duration: 800; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 0.4; to: 0.9; duration: 800; easing.type: Easing.InOutSine }
                            }

                            function resetParticle() {
                                if (logicFlowEmitter.width <= 0) return;
                                
                                var startX = Math.random() * (logicFlowEmitter.width - 25)
                                particleItem.x = startX
                                particleItem.particleText = Math.random() < 0.4 ? "•" : (Math.random() < 0.5 ? "0" : "1")
                                particleItem.particleColor = ["#39FF14", "#00E5FF", "#FF9900", "#FF1133", "#FF00FF"][Math.floor(Math.random() * 5)]
                                particleItem.opacity = Math.random() * 0.65 + 0.2
                                
                                // Set float duration on yAnim directly (never fails!)
                                yAnim.duration = Math.random() * 3000 + 2500
                                
                                // Randomize sway range dynamically
                                xAnim1.from = startX
                                xAnim1.to = startX + (Math.random() * 20 + 8) * (Math.random() < 0.5 ? -1 : 1)
                                xAnim1.duration = Math.random() * 1500 + 1000
                                
                                xAnim2.to = startX - (Math.random() * 20 + 8) * (Math.random() < 0.5 ? -1 : 1)
                                xAnim2.duration = Math.random() * 1500 + 1000
                                
                                floatAnim.restart()
                                driftAnim.restart()
                            }

                            SequentialAnimation {
                                id: floatAnim
                                running: false

                                NumberAnimation {
                                    id: yAnim
                                    target: particleItem
                                    property: "y"
                                    from: logicFlowEmitter.height + 15
                                    to: -25
                                    easing.type: Easing.Linear
                                }

                                ScriptAction {
                                    script: particleItem.resetParticle()
                                }
                            }

                            // Drift animation (left and right sway)
                            SequentialAnimation {
                                id: driftAnim
                                loops: Animation.Infinite

                                NumberAnimation {
                                    id: xAnim1
                                    target: particleItem
                                    property: "x"
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    id: xAnim2
                                    target: particleItem
                                    property: "x"
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            // Trigger launch stagger-delay
                            Timer {
                                id: initTimer
                                interval: index * 260
                                repeat: false
                                running: false
                                onTriggered: {
                                    particleItem.resetParticle()
                                    // Distribute them evenly vertically at startup
                                    particleItem.y = Math.random() * logicFlowEmitter.height
                                }
                            }

                            Connections {
                                target: logicFlowEmitter
                                function onWidthChanged() {
                                    if (logicFlowEmitter.width > 0 && !floatAnim.running && !initTimer.running) {
                                        initTimer.start()
                                    }
                                }
                            }
                        }
                    }
                }

                // Pro VLSI Power Modules (High-Fidelity)
                RowLayout {
                    id: powerButtonsRow
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: false
                    Layout.preferredHeight: Math.round(44 * uiScale)
                    Layout.bottomMargin: Math.round(8 * uiScale)
                    spacing: Math.round(20 * uiScale)

                    Repeater {
                        model: [
                            { id: "suspend", icon: "☾", label: "SUSPEND", action: function() { if (typeof sddm !== "undefined" && sddm !== null) sddm.suspend() }, color: textWarning },
                            { id: "hibernate", icon: "⏾", label: "HIBERNATE", action: function() { if (typeof sddm !== "undefined" && sddm !== null) sddm.hibernate() }, color: maroonBright },
                            { id: "reboot", icon: "↻", label: "REBOOT", action: function() { if (typeof sddm !== "undefined" && sddm !== null) sddm.reboot() }, color: neonGreen },
                            { id: "poweroff", icon: "⏻", label: "SHUTDOWN", action: function() { if (typeof sddm !== "undefined" && sddm !== null) sddm.powerOff() }, color: maroonBright }
                        ]

                        delegate: QQC2.Button {
                            id: powerBtn
                            visible: true
                            Layout.preferredHeight: Math.round(44 * uiScale)
                            Layout.preferredWidth: Math.round(142 * uiScale)
                            
                            onClicked: modelData.action()

                            contentItem: RowLayout {
                                spacing: 12
                                anchors.centerIn: parent
                                
                                Text {
                                    text: modelData.icon
                                    font.pixelSize: Math.round(18 * uiScale)
                                    color: powerBtn.hovered ? modelData.color : textMuted
                                    opacity: powerBtn.hovered ? 1.0 : 0.7
                                    Behavior on color { ColorAnimation { duration: 180 } }
                                    Behavior on opacity { NumberAnimation { duration: 180 } }
                                }
                                
                                Text {
                                    text: modelData.label
                                    font {
                                        family: "Orbitron"
                                        pixelSize: Math.round(10.5 * uiScale)
                                        bold: true
                                        letterSpacing: 1.5
                                    }
                                    color: powerBtn.hovered ? textPrimary : textMuted
                                    Behavior on color { ColorAnimation { duration: 180 } }
                                }
                            }

                            background: Rectangle {
                                id: powerBtnBg
                                radius: 12
                                color: powerBtn.hovered ? "#1CFFFFFF" : "#0D000000"
                                border.width: powerBtn.hovered ? 2 : 1
                                border.color: powerBtn.hovered ? modelData.color : strokeSoft
                                opacity: powerBtn.hovered ? 1.0 : 0.6
                                
                                Behavior on border.color { ColorAnimation { duration: 180 } }
                                Behavior on border.width { NumberAnimation { duration: 180 } }
                                Behavior on color { ColorAnimation { duration: 180 } }
                                Behavior on opacity { NumberAnimation { duration: 180 } }

                                // --- LOGIC SCANLINE CONTAINER (WITH PERFECT ROUNDED CLIPPING) ---
                                Item {
                                    id: maskContainer
                                    anchors.fill: parent
                                    visible: powerBtn.hovered
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: Rectangle {
                                            width: powerBtnBg.width
                                            height: powerBtnBg.height
                                            radius: powerBtnBg.radius
                                        }
                                    }

                                    // Glowing Aura (Contained)
                                    RectangularGlow {
                                        anchors.fill: parent
                                        glowRadius: 16
                                        spread: 0.3
                                        color: modelData.color
                                        cornerRadius: powerBtnBg.radius
                                        opacity: 0.6
                                        
                                        SequentialAnimation on opacity {
                                            running: !isIdle
                                            loops: Animation.Infinite
                                            NumberAnimation { from: 0.4; to: 0.8; duration: 1200; easing.type: Easing.InOutQuad }
                                            NumberAnimation { from: 0.8; to: 0.4; duration: 1200; easing.type: Easing.InOutQuad }
                                        }
                                    }

                                    // High-Speed Logic Scanline (Perfectly Clipped)
                                    Rectangle {
                                        id: logicScan
                                        width: Math.round(4 * uiScale)
                                        height: parent.height
                                        color: "white"
                                        opacity: 0.9
                                        z: 5
                                        
                                        SequentialAnimation on x {
                                            running: !isIdle
                                            loops: Animation.Infinite
                                            NumberAnimation { from: -20; to: powerBtnBg.width + 20; duration: 950; easing.type: Easing.Linear }
                                            PauseAnimation { duration: 150 }
                                        }

                                        RectangularGlow {
                                            anchors.fill: parent
                                            glowRadius: 10
                                            spread: 0.4
                                            color: modelData.color
                                            cornerRadius: 1
                                        }
                                    }
                                }
                                
                                // Internal silicon highlight (Top Edge Rim)
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1.5
                                    radius: parent.radius - 1
                                    color: "transparent"
                                    border.width: 1
                                    border.color: "white"
                                    opacity: powerBtn.hovered ? 0.15 : 0.05
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: (typeof sddm !== "undefined" && sddm !== null) ? sddm : null

        function onLoginFailed() {
            authenticating = false
            passwordField.text = ""
            passwordField.forceActiveFocus()
            messageColor = maroonBright
            messageText = "Decryption Core Error: Cryptographic Key Signature Invalid"
            shakeAnim.start()
            passwordBorderRect.triggerFailGlow()
            resetMessageTimer.start()

            // Trigger simulated parity error glitch
            root.isGlitchActive = true
            authGlitchTimer.start()
        }

        function onLoginSucceeded() {
            authenticating = false
            messageColor = neonGreen
            messageText = "Access Granted! Loading Manx VLSI Environment..."

            // Trigger green logic reset wave
            root.isSuccessWaveActive = true
            root.successWaveProgress = 0.0
        }

        function onInformationMessage(message) {
            authenticating = false
            messageColor = textWarning
            messageText = message
        }
    }

    // --- VIRTUAL KEYBOARD PANEL (Slide-up Animation) ---
    // We use a direct component for better input method integration.
    // To prevent the startup crash, it remains disabled/hidden for 2 seconds.
    InputPanel {
        id: inputPanel
        z: 99
        width: parent.width
        visible: vkbInitTimer.triggeredOnce
        enabled: visible
        focus: false

        onVisibleChanged: {
            if (visible) {
                passwordField.forceActiveFocus()
            }
        }

        y: root.virtualKeyboardActive ? (parent.height - height) : parent.height

        Behavior on y {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }

    Timer {
        id: vkbInitTimer
        property bool triggeredOnce: false
        interval: 2000
        running: true
        repeat: false
        onTriggered: triggeredOnce = true
    }
}