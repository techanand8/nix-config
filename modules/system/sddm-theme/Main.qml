import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import SddmComponents 2.0
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
    property string timingStats: "tpd 1.4ns  |  f = 60Hz  |  VDD = 1.8V"

    property color spectrumColor: neonGreen

    SequentialAnimation {
        id: spectrumAnimation
        running: true
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "spectrumColor"; from: "#39FF14"; to: "#99FF11"; duration: 600; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#99FF11"; to: "#FF9900"; duration: 600; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#FF9900"; to: "#FF1133"; duration: 600; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#FF1133"; to: "#FF9900"; duration: 600; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#FF9900"; to: "#99FF11"; duration: 600; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "spectrumColor"; from: "#99FF11"; to: "#39FF14"; duration: 600; easing.type: Easing.InOutQuad }
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
        sddm.login(selectedUserName, passwordField.text, sessionSelector.currentIndex)
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

    Canvas {
        id: bgCanvas
        anchors.fill: parent
        z: 0
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        property var particles: []
        property int numParticles: 30
        property real pulse: 0
        property real simulationProgress: 0

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
                    vx: (Math.random() - 0.5) * 0.7,
                    vy: (Math.random() - 0.5) * 0.7,
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

        function drawGateWaveform(ctx, wx, wy, ww, wh, gateType, rows, gateColor, isActive, sp) {
            var isSingle = (gateType === "BUF" || gateType === "NOT")
            var numSigs = isSingle ? 2 : 3
            var sigNames  = isSingle ? ["IN", "Y"] : ["A", "B", "Y"]
            var sigColors = isSingle ? ["#00E5FF", gateColor] : ["#00E5FF", gateColor, "#FFFFFF"]
            var numPoints = 50
            var rowCount  = rows.length
            var labelW    = 14 * uiScale
            var sigH      = wh / numSigs

            // Card background
            ctx.save()
            var rr = 4 * uiScale
            ctx.fillStyle = "rgba(4, 1, 8, 0.90)"
            ctx.shadowBlur = isActive ? 8 * uiScale : 3 * uiScale
            ctx.shadowColor = isActive ? gateColor : "rgba(0,0,0,0.5)"
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
            ctx.shadowBlur = 0
            ctx.strokeStyle = isActive ? gateColor : "rgba(255,255,255,0.12)"
            ctx.lineWidth = 0.8 * uiScale
            ctx.stroke()
            ctx.restore()

            // Divider lines between signal rows
            ctx.save()
            ctx.strokeStyle = "rgba(255,255,255,0.06)"
            ctx.lineWidth = 0.7
            for (var di = 1; di < numSigs; di++) {
                var dyy = wy + di * sigH
                ctx.beginPath()
                ctx.moveTo(wx + labelW, dyy)
                ctx.lineTo(wx + ww - 2, dyy)
                ctx.stroke()
            }
            ctx.restore()

            // Grid verticals (4 divisions)
            ctx.save()
            ctx.strokeStyle = "rgba(255,255,255,0.04)"
            ctx.lineWidth = 0.7
            for (var gvi = 1; gvi < 4; gvi++) {
                var gvx = wx + labelW + (gvi / 4) * (ww - labelW - 2)
                ctx.beginPath()
                ctx.moveTo(gvx, wy)
                ctx.lineTo(gvx, wy + wh)
                ctx.stroke()
            }
            ctx.restore()

            // Draw each signal trace
            for (var si = 0; si < numSigs; si++) {
                var baseY  = wy + si * sigH + sigH * 0.5
                var amp    = sigH * 0.36
                var col    = sigColors[si]
                var sName  = sigNames[si]
                var colIdx = (isSingle ? [0, 2] : [0, 1, 2])[si]

                // Signal label
                ctx.save()
                ctx.fillStyle = col
                ctx.font = "bold " + Math.max(6, Math.round(7 * uiScale)) + "px 'JetBrainsMono Nerd Font'"
                ctx.textAlign = "left"
                ctx.textBaseline = "middle"
                ctx.fillText(sName, wx + 2, baseY)
                ctx.restore()

                // Waveform trace
                ctx.save()
                ctx.strokeStyle = col
                ctx.lineWidth = 1.3
                ctx.shadowBlur = 4
                ctx.shadowColor = col
                ctx.setLineDash([])
                ctx.beginPath()

                var prevVal = -1
                for (var pi = 0; pi <= numPoints; pi++) {
                    var t = (pi / numPoints + sp) % 1.0
                    var rowIdx = Math.floor(t * rowCount) % rowCount
                    var row = rows[rowIdx]
                    var val = parseInt(row[colIdx])
                    if (isNaN(val)) val = 0

                    var px2 = wx + labelW + (pi / numPoints) * (ww - labelW - 3)
                    var py2 = baseY + (val === 0 ? amp : -amp)

                    if (pi === 0) {
                        ctx.moveTo(px2, py2)
                        prevVal = val
                    } else if (val !== prevVal) {
                        ctx.lineTo(px2, prevVal === 0 ? baseY + amp : baseY - amp)
                        ctx.lineTo(px2, py2)
                    } else {
                        ctx.lineTo(px2, py2)
                    }
                    prevVal = val
                }
                ctx.stroke()
                ctx.shadowBlur = 0
                ctx.restore()
            }

            // "NOW" marker at right edge
            ctx.save()
            ctx.strokeStyle = "rgba(255,255,255,0.18)"
            ctx.lineWidth = 0.8
            ctx.setLineDash([2, 3])
            ctx.beginPath()
            ctx.moveTo(wx + ww - 2, wy)
            ctx.lineTo(wx + ww - 2, wy + wh)
            ctx.stroke()
            ctx.setLineDash([])
            ctx.restore()
        }

        function easeInOut(t) {
            var c = t < 0.0 ? 0.0 : (t > 1.0 ? 1.0 : t)
            return c < 0.5 ? 2.0 * c * c : -1.0 + (4.0 - 2.0 * c) * c
        }

        function drawWireLabel(ctx, x, y, label, val, alignRight) {
            ctx.save()
            var isHigh = (val === "1")
            var valColor = isHigh ? "#39FF14" : "#FF1133"

            ctx.font = "bold " + Math.round(9 * uiScale) + "px 'JetBrainsMono Nerd Font'"
            ctx.fillStyle = "rgba(255, 255, 255, 0.75)"
            ctx.textAlign = alignRight ? "right" : "left"
            ctx.textBaseline = "middle"

            if (alignRight) {
                var valW = ctx.measureText(val).width
                ctx.fillText(label + "=", x - valW - 1 * uiScale, y)

                ctx.font = "bold " + Math.round(10 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                ctx.fillStyle = valColor
                ctx.shadowBlur = 6 * uiScale
                ctx.shadowColor = valColor
                ctx.fillText(val, x, y)
            } else {
                ctx.fillText(label + "=", x, y)
                var labelW = ctx.measureText(label + "=").width

                ctx.font = "bold " + Math.round(10 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                ctx.fillStyle = valColor
                ctx.shadowBlur = 6 * uiScale
                ctx.shadowColor = valColor
                ctx.fillText(val, x + labelW, y)
            }
            ctx.restore()
        }

        function drawWaveguide(ctx, xStart, yStart, xEnd, yEnd, logicVal, gateColor, progress, phase, isInput, dir) {
            ctx.save()
            var isHigh = (logicVal === "1")
            var baseColor = isHigh ? "#39FF14" : "#FF1133"
            var dimColor = isHigh ? "rgba(57, 255, 20, 0.4)" : "rgba(255, 17, 51, 0.35)"

            // PCB Microstrip Channel Backing
            ctx.strokeStyle = "rgba(10, 2, 18, 0.55)"
            ctx.lineWidth = 4 * uiScale
            ctx.beginPath()
            ctx.moveTo(xStart, yStart)
            ctx.lineTo(xEnd, yEnd)
            ctx.stroke()

            // Waveguide path
            ctx.strokeStyle = dimColor
            ctx.lineWidth = 1.5 * uiScale
            ctx.stroke()

            // Dash signal flow
            ctx.strokeStyle = baseColor
            ctx.setLineDash([6 * uiScale, 8 * uiScale])
            ctx.lineDashOffset = dir * simulationProgress * 90 * uiScale
            ctx.stroke()
            ctx.restore()

            // Electron pulse drawing
            ctx.save()
            var curX = xStart
            var curY = yStart

            if (isInput) {
                if (phase === 1) { // Phase 1: Input Setup (traveling)
                    curX = xStart + (xEnd - xStart) * progress
                    curY = yStart + (yEnd - yStart) * progress
                } else { // Phase 2 & 3: Resting at terminal
                    curX = xEnd
                    curY = yEnd
                }
            } else { // Output trace (traveling or resting)
                if (phase === 3) { // Phase 3: Output Resolution (traveling)
                    curX = xStart + (xEnd - xStart) * progress
                    curY = yStart + (yEnd - yStart) * progress
                } else { // Phase 1 & 2: Resting at destination (previous state)
                    curX = xEnd
                    curY = yEnd
                }
            }

            // Draw glowing electron wave vector
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

            // Dynamic logic gate coordinate engine - avoids central shell overlap
            var shellWidth = Math.max(200, Math.min(width - 120, 1420))
            var shellHeight = Math.max(150, Math.min(height - 120, 820))
            var shellX = Math.max(10, (width - shellWidth) / 2)
            var shellY = Math.max(10, (height - shellHeight) / 2)

            var stubLen = 60 * uiScale
            var gateMargin = stubLen + 100 * uiScale

            var leftX = Math.max(gateMargin, shellX * 0.65)
            var rightX = Math.min(width - gateMargin, width - shellX * 0.65)

            var leftY1 = shellY + shellHeight * 0.14
            var leftY2 = shellY + shellHeight * 0.46
            var leftY3 = shellY + shellHeight * 0.78

            var topY = Math.max(55 * uiScale, shellY * 0.52)
            var bottomY = height - Math.max(55 * uiScale, shellY * 0.52)

            // Multicolored premium VLSI verification channels color-mapped (swapped to match 2nd image)
            var gates = [
                { type: "BUF", x: width * 0.5, y: topY, name: "BUFFER GATE", color: "#00E5FF", dimColor: "#003A40" },
                { type: "AND", x: leftX, y: leftY1, name: "AND GATE", color: "#00F5FF", dimColor: "#003E40" },
                { type: "OR", x: leftX, y: leftY2, name: "OR GATE", color: "#FF007F", dimColor: "#400020" },
                { type: "XOR", x: leftX, y: leftY3, name: "XOR GATE", color: "#39FF14", dimColor: "#0E4005" },
                { type: "NOT", x: width * 0.5, y: bottomY, name: "NOT GATE", color: "#FF1133", dimColor: "#40040C" },
                { type: "NAND", x: rightX, y: leftY1, name: "NAND GATE", color: "#FF6C00", dimColor: "#401B00" },
                { type: "NOR", x: rightX, y: leftY2, name: "NOR GATE", color: "#B026FF", dimColor: "#2C0940" },
                { type: "XNOR", x: rightX, y: leftY3, name: "XNOR GATE", color: "#FFD700", dimColor: "#403600" }
            ]

            var gw = 36 * uiScale
            var gh = 36 * uiScale

            for (var gi = 0; gi < gates.length; ++gi) {
                var gate = gates[gi]
                var gx = gate.x
                var gy = gate.y
                var isLeft = (gx < width * 0.4)
                var isRight = (gx > width * 0.6)
                var isTop = (gy < height * 0.25)
                var isBottom = (gy > height * 0.75)

                var rows = []
                if (gate.type === "BUF") { rows = [["0", " ", "0"], ["1", " ", "1"]] }
                else if (gate.type === "NOT") { rows = [["0", " ", "1"], ["1", " ", "0"]] }
                else if (gate.type === "AND") { rows = [["0", "0", "0"], ["0", "1", "0"], ["1", "0", "0"], ["1", "1", "1"]] }
                else if (gate.type === "NAND") { rows = [["0", "0", "1"], ["0", "1", "1"], ["1", "0", "1"], ["1", "1", "0"]] }
                else if (gate.type === "OR") { rows = [["0", "0", "0"], ["0", "1", "1"], ["1", "0", "1"], ["1", "1", "1"]] }
                else if (gate.type === "NOR") { rows = [["0", "0", "1"], ["0", "1", "0"], ["1", "0", "0"], ["1", "1", "0"]] }
                else if (gate.type === "XOR") { rows = [["0", "0", "0"], ["0", "1", "1"], ["1", "0", "1"], ["1", "1", "0"]] }
                else if (gate.type === "XNOR") { rows = [["0", "0", "1"], ["0", "1", "0"], ["1", "0", "0"], ["1", "1", "1"]] }

                // Dynamic visual tpd propagation delay 3-phase engine
                var activeRowIndex = Math.floor(((simulationProgress + gi * 0.125) % 1.0) * rows.length)
                var prevRowIndex = (activeRowIndex - 1 + rows.length) % rows.length

                var activeRow = rows[activeRowIndex]
                var prevRow = rows[prevRowIndex]

                var valA = activeRow[0]
                var valB = activeRow[1]
                var valY = activeRow[2]
                var prevValY = prevRow[2]

                // Split progress inside the active truth table row into 3 distinct phases
                var frac = ((simulationProgress + gi * 0.125) * rows.length) % 1.0
                var phase = 1
                var inputProgress = 0
                var processProgress = 0
                var outputProgress = 0

                if (frac < 0.32) {
                    phase = 1
                    inputProgress = easeInOut(frac / 0.32)
                } else if (frac < 0.62) {
                    phase = 2
                    processProgress = easeInOut((frac - 0.32) / 0.30)
                } else {
                    phase = 3
                    outputProgress = easeInOut((frac - 0.62) / 0.38)
                }

                // Resolves which logic values are active inside gate/out during early phases
                var isGateActive = (phase === 3) ? (valY === "1") : (prevValY === "1")
                var currentOutVal = (phase === 3) ? valY : prevValY

                // Draw Input/Output waveguide traces dynamically mapped by column
                if (isLeft || isRight) {
                    drawWaveguide(ctx, gx - stubLen, gy - 6 * uiScale, gx - gw/2, gy - 6 * uiScale, valA, gate.color, inputProgress, phase, true, -1)
                    drawWaveguide(ctx, gx - stubLen, gy + 6 * uiScale, gx - gw/2, gy + 6 * uiScale, valB, gate.color, inputProgress, phase, true, -1)
                    drawWaveguide(ctx, gx + gw/2, gy, gx + stubLen, gy, currentOutVal, gate.color, outputProgress, phase, false, -1)

                    // Symmetrical glowing logic node pads at the tips of stubs
                    ctx.save()
                    var colA = (valA === "1") ? "#39FF14" : "#FF1133"
                    ctx.fillStyle = colA
                    ctx.shadowBlur = 5 * uiScale
                    ctx.shadowColor = colA
                    ctx.beginPath()
                    ctx.arc(gx - stubLen, gy - 6 * uiScale, 3.2 * uiScale, 0, Math.PI * 2)
                    ctx.fill()

                    var colB = (valB === "1") ? "#39FF14" : "#FF1133"
                    ctx.fillStyle = colB
                    ctx.shadowBlur = 5 * uiScale
                    ctx.shadowColor = colB
                    ctx.beginPath()
                    ctx.arc(gx - stubLen, gy + 6 * uiScale, 3.2 * uiScale, 0, Math.PI * 2)
                    ctx.fill()

                    var colY = (currentOutVal === "1") ? "#39FF14" : "#FF1133"
                    ctx.fillStyle = colY
                    ctx.shadowBlur = 5 * uiScale
                    ctx.shadowColor = colY
                    ctx.beginPath()
                    ctx.arc(gx + stubLen, gy, 3.2 * uiScale, 0, Math.PI * 2)
                    ctx.fill()
                    ctx.restore()

                    drawWireLabel(ctx, gx - stubLen - 8 * uiScale, gy - 6 * uiScale, "A", valA, true)
                    drawWireLabel(ctx, gx - stubLen - 8 * uiScale, gy + 6 * uiScale, "B", valB, true)
                    drawWireLabel(ctx, gx + stubLen + 8 * uiScale, gy, "Y", currentOutVal, false)

                } else if (isTop || isBottom) {
                    drawWaveguide(ctx, gx - stubLen, gy, gx - gw/2, gy, valA, gate.color, inputProgress, phase, true, -1)
                    drawWaveguide(ctx, gx + gw/2, gy, gx + stubLen, gy, currentOutVal, gate.color, outputProgress, phase, false, -1)

                    ctx.save()
                    var colIN = (valA === "1") ? "#39FF14" : "#FF1133"
                    ctx.fillStyle = colIN
                    ctx.shadowBlur = 5 * uiScale
                    ctx.shadowColor = colIN
                    ctx.beginPath()
                    ctx.arc(gx - stubLen, gy, 3.2 * uiScale, 0, Math.PI * 2)
                    ctx.fill()

                    var colOUT = (currentOutVal === "1") ? "#39FF14" : "#FF1133"
                    ctx.fillStyle = colOUT
                    ctx.shadowBlur = 5 * uiScale
                    ctx.shadowColor = colOUT
                    ctx.beginPath()
                    ctx.arc(gx + stubLen, gy, 3.2 * uiScale, 0, Math.PI * 2)
                    ctx.fill()
                    ctx.restore()

                    drawWireLabel(ctx, gx - stubLen - 8 * uiScale, gy, "IN", valA, true)
                    drawWireLabel(ctx, gx + stubLen + 8 * uiScale, gy, "OUT", currentOutVal, false)
                }

                // Draw high-fidelity logic gate cell bodies
                ctx.save()
                ctx.lineWidth = 1.8 * uiScale
                ctx.strokeStyle = isGateActive ? "#39FF14" : "#FF1133"

                var gateGrad = ctx.createLinearGradient(gx - gw/2, gy - gh/2, gx + gw/2, gy + gh/2)
                gateGrad.addColorStop(0.0, "rgba(8, 2, 12, 0.94)")
                gateGrad.addColorStop(1.0, isGateActive ? "rgba(57, 255, 20, 0.16)" : "rgba(255, 17, 51, 0.1)")
                ctx.fillStyle = gateGrad

                var cellGlow = isGateActive ? 10 * uiScale : 3 * uiScale
                if (phase === 2) {
                    cellGlow = (13 + 7 * Math.sin(simulationProgress * Math.PI * 24)) * uiScale
                }
                ctx.shadowBlur = cellGlow
                ctx.shadowColor = isGateActive ? "#39FF14" : "#FF1133"
                ctx.beginPath()

                if (gate.type === "BUF") {
                    ctx.moveTo(gx - gw/2, gy - gh/2)
                    ctx.lineTo(gx + gw/2, gy)
                    ctx.lineTo(gx - gw/2, gy + gh/2)
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke()
                } else if (gate.type === "NOT") {
                    ctx.moveTo(gx - gw/2, gy - gh/2)
                    ctx.lineTo(gx + gw/4, gy)
                    ctx.lineTo(gx - gw/2, gy + gh/2)
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(gx + gw/2 - 2 * uiScale, gy, 2.5 * uiScale, 0, Math.PI * 2)
                    ctx.fillStyle = isGateActive ? gate.color : "#FF1133"
                    ctx.fill()
                    ctx.stroke()
                } else if (gate.type === "AND" || gate.type === "NAND") {
                    ctx.moveTo(gx - gw/2, gy - gh/2)
                    ctx.lineTo(gx, gy - gh/2)
                    ctx.arc(gx, gy, gh/2, -Math.PI/2, Math.PI/2, false)
                    ctx.lineTo(gx - gw/2, gy + gh/2)
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke()
                    if (gate.type === "NAND") {
                        ctx.beginPath()
                        ctx.arc(gx + gw/2 + 2 * uiScale, gy, 2.5 * uiScale, 0, Math.PI * 2)
                        ctx.fillStyle = isGateActive ? gate.color : "#FF1133"
                        ctx.fill()
                        ctx.stroke()
                    }
                } else if (gate.type === "OR" || gate.type === "NOR") {
                    ctx.moveTo(gx - gw/2, gy - gh/2)
                    ctx.quadraticCurveTo(gx - gw/4, gy, gx - gw/2, gy + gh/2)
                    ctx.quadraticCurveTo(gx, gy + gh/2, gx + gw/2, gy)
                    ctx.quadraticCurveTo(gx, gy - gh/2, gx - gw/2, gy - gh/2)
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke()
                    if (gate.type === "NOR") {
                        ctx.beginPath()
                        ctx.arc(gx + gw/2 + 2 * uiScale, gy, 2.5 * uiScale, 0, Math.PI * 2)
                        ctx.fillStyle = isGateActive ? gate.color : "#FF1133"
                        ctx.fill()
                        ctx.stroke()
                    }
                } else if (gate.type === "XOR" || gate.type === "XNOR") {
                    ctx.moveTo(gx - gw/2 - 3 * uiScale, gy - gh/2)
                    ctx.quadraticCurveTo(gx - gw/4 - 3 * uiScale, gy, gx - gw/2 - 3 * uiScale, gy + gh/2)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(gx - gw/2, gy - gh/2)
                    ctx.quadraticCurveTo(gx - gw/4, gy, gx - gw/2, gy + gh/2)
                    ctx.quadraticCurveTo(gx, gy + gh/2, gx + gw/2, gy)
                    ctx.quadraticCurveTo(gx, gy - gh/2, gx - gw/2, gy - gh/2)
                    ctx.closePath()
                    ctx.fill()
                    ctx.stroke()
                    if (gate.type === "XNOR") {
                        ctx.beginPath()
                        ctx.arc(gx + gw/2 + 2 * uiScale, gy, 2.5 * uiScale, 0, Math.PI * 2)
                        ctx.fillStyle = isGateActive ? gate.color : "#FF1133"
                        ctx.fill()
                        ctx.stroke()
                    }
                }
                ctx.restore()

                // Phase 2: Draw amber rotating calculation sweep ring representing propagation delay (tpd)
                if (phase === 2) {
                    ctx.save()
                    ctx.beginPath()
                    ctx.arc(gx, gy, gw * 0.38, 0, 2 * Math.PI)
                    ctx.strokeStyle = "rgba(255, 108, 0, 0.25)"
                    ctx.lineWidth = 1 * uiScale
                    ctx.stroke()

                    var sweepAng = processProgress * 2 * Math.PI
                    ctx.beginPath()
                    ctx.arc(gx, gy, gw * 0.38, sweepAng - 0.5, sweepAng + 0.5)
                    ctx.strokeStyle = "#FF6C00"
                    ctx.lineWidth = 2 * uiScale
                    ctx.stroke()
                    ctx.restore()
                }

                // Micro terminal connectivity pads (small circular rings at connection pins)
                ctx.save()
                ctx.fillStyle = isGateActive ? gate.color : "#FF1133"
                ctx.beginPath()
                if (gate.type === "BUF" || gate.type === "NOT") {
                    ctx.arc(gx - gw/2, gy, 2 * uiScale, 0, Math.PI * 2)
                    ctx.fill()
                } else {
                    ctx.arc(gx - gw/2, gy - 6 * uiScale, 2 * uiScale, 0, Math.PI * 2)
                    ctx.arc(gx - gw/2, gy + 6 * uiScale, 2 * uiScale, 0, Math.PI * 2)
                    ctx.fill()
                }
                ctx.restore()

                // Render interior logic code labels and parameters inside the gates
                ctx.save()
                ctx.fillStyle = isGateActive ? "rgba(" + hexToRgb(gate.color) + ", 0.9)" : "rgba(255, 17, 51, 0.7)"
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                var innerSym = ""
                var descriptor = ""
                if (gate.type === "BUF") { innerSym = "1"; descriptor = "tpd 1.0ns" }
                else if (gate.type === "NOT") { innerSym = "1"; descriptor = "tpd 1.2ns" }
                else if (gate.type === "AND" || gate.type === "NAND") { innerSym = "&"; descriptor = gate.type === "AND" ? "tpd 1.4ns" : "tpd 1.7ns" }
                else if (gate.type === "OR" || gate.type === "NOR") { innerSym = "≥1"; descriptor = gate.type === "OR" ? "tpd 1.5ns" : "tpd 1.8ns" }
                else if (gate.type === "XOR" || gate.type === "XNOR") { innerSym = "=1"; descriptor = gate.type === "XOR" ? "tpd 1.8ns" : "tpd 2.1ns" }

                ctx.font = "bold " + Math.round(9 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                ctx.fillText(innerSym, gx - (gate.type === "NOT" ? 2 * uiScale : 0), gy - 2 * uiScale)

                ctx.fillStyle = "rgba(255, 255, 255, 0.22)"
                ctx.font = "bold " + Math.round(5.5 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                ctx.fillText(descriptor, gx - (gate.type === "NOT" ? 2 * uiScale : 0), gy + 6 * uiScale)
                ctx.restore()

                // Render holographic Glassmorphic Truth Table HUD Diagnostic overlays
                var hudW = 114 * uiScale
                var hudHeight = (gate.type === "BUF" || gate.type === "NOT") ? 62 * uiScale : 84 * uiScale
                var hx = gx - hudW / 2
                var hy = gy - hudHeight / 2

                if (gate.type === "BUF") {
                    // Buffer gate (top center): HUD below gate, offset left
                    hx = gx - hudW - 28 * uiScale
                    hy = gy + gw + 8 * uiScale
                } else if (gate.type === "NOT") {
                    // NOT gate (bottom center): HUD above gate, offset left
                    hx = gx - hudW - 28 * uiScale
                    hy = gy - hudHeight - gw - 8 * uiScale
                } else if (isLeft) {
                    // Left gates: HUD to the LEFT of the gate body (between screen edge and gate)
                    hx = gx - gw / 2 - hudW - 14 * uiScale
                    hy = gy - hudHeight / 2
                } else if (isRight) {
                    // Right gates: HUD to the RIGHT of the gate body (between gate and screen edge)
                    hx = gx + gw / 2 + 14 * uiScale
                    hy = gy - hudHeight / 2
                }

                // Hard-clamp HUD card to always stay fully within canvas bounds
                hx = Math.max(4, Math.min(hx, width - hudW - 4))
                hy = Math.max(4, Math.min(hy, height - hudHeight - 4))

                ctx.save()
                // Glassmorphism HUD Substrate with dynamic logical glow borders
                ctx.fillStyle = "rgba(7, 2, 11, 0.94)"
                ctx.shadowBlur = isGateActive ? 12 * uiScale : 5 * uiScale
                ctx.shadowColor = isGateActive ? "rgba(57, 255, 20, 0.35)" : "rgba(255, 17, 51, 0.18)"

                // Draw rounded card
                var hRad = 8 * uiScale
                ctx.beginPath()
                ctx.moveTo(hx + hRad, hy)
                ctx.lineTo(hx + hudW - hRad, hy)
                ctx.quadraticCurveTo(hx + hudW, hy, hx + hudW, hy + hRad)
                ctx.lineTo(hx + hudW, hy + hudHeight - hRad)
                ctx.quadraticCurveTo(hx + hudW, hy + hudHeight, hx + hudW - hRad, hy + hudHeight)
                ctx.lineTo(hx + hRad, hy + hudHeight)
                ctx.quadraticCurveTo(hx, hy + hudHeight, hx, hy + hudHeight - hRad)
                ctx.lineTo(hx, hy + hRad)
                ctx.quadraticCurveTo(hx, hy, hx + hRad, hy)
                ctx.closePath()
                ctx.fill()

                ctx.strokeStyle = isGateActive ? "rgba(57, 255, 20, 0.45)" : "rgba(255, 17, 51, 0.35)"
                ctx.lineWidth = 1 * uiScale
                ctx.stroke()
                ctx.restore()

                // HUD Diagnostics Contents
                ctx.save()
                ctx.textAlign = "left"
                ctx.textBaseline = "middle"
                ctx.fillStyle = isGateActive ? "#39FF14" : "#FF1133"
                ctx.font = "bold " + Math.round(9.5 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                ctx.fillText(gate.name, hx + 12 * uiScale, hy + 12 * uiScale)

                // Truth table column headers
                ctx.textAlign = "center"
                ctx.font = "bold " + Math.round(9.5 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                ctx.fillStyle = "rgba(255, 255, 255, 0.45)"
                if (gate.type === "BUF" || gate.type === "NOT") {
                    ctx.fillText("IN", hx + 36 * uiScale, hy + 23 * uiScale)
                    ctx.fillText("OUT", hx + 78 * uiScale, hy + 23 * uiScale)
                } else {
                    ctx.fillText("A", hx + 24 * uiScale, hy + 23 * uiScale)
                    ctx.fillText("B", hx + 57 * uiScale, hy + 23 * uiScale)
                    ctx.fillText("Y", hx + 90 * uiScale, hy + 23 * uiScale)
                }

                // Divider line
                ctx.strokeStyle = "rgba(255, 255, 255, 0.12)"
                ctx.lineWidth = 0.8 * uiScale
                ctx.beginPath()
                ctx.moveTo(hx + 12 * uiScale, hy + 28 * uiScale)
                ctx.lineTo(hx + hudW - 12 * uiScale, hy + 28 * uiScale)
                ctx.stroke()

                // Symmetrical Logic Analyzer Row highlight & text rendering
                for (var ri = 0; ri < rows.length; ++ri) {
                    var isRowActive = (ri === activeRowIndex)
                    var ry = hy + 38 * uiScale + ri * 10 * uiScale

                    if (isRowActive) {
                        ctx.save()
                        // Sleek highlighted row pill mapping accent colors
                        ctx.fillStyle = isGateActive ? "rgba(57, 255, 20, 0.18)" : "rgba(255, 17, 51, 0.12)"
                        var pH = 9.5 * uiScale
                        var pY = ry - 7 * uiScale
                        ctx.fillRect(hx + 2 * uiScale, pY, hudW - 4 * uiScale, pH)

                        // Active logic analyzer left border pin bar
                        ctx.fillStyle = isGateActive ? "#39FF14" : "#FF1133"
                        ctx.fillRect(hx + 2 * uiScale, pY, 2 * uiScale, pH)
                        ctx.restore()

                        ctx.fillStyle = isGateActive ? "#39FF14" : "#FF1133"
                        ctx.font = "bold " + Math.round(9.5 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                    } else {
                        ctx.fillStyle = "rgba(255, 255, 255, 0.35)"
                        ctx.font = Math.round(9.5 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                    }

                    ctx.textAlign = "center"
                    if (gate.type === "BUF" || gate.type === "NOT") {
                        ctx.fillText(rows[ri][0], hx + 36 * uiScale, ry)
                        ctx.fillText(rows[ri][2], hx + 78 * uiScale, ry)
                    } else {
                        ctx.fillText(rows[ri][0], hx + 24 * uiScale, ry)
                        ctx.fillText(rows[ri][1], hx + 57 * uiScale, ry)
                        ctx.fillText(rows[ri][2], hx + 90 * uiScale, ry)
                    }
                }

                // Render dynamic visual phase sub-labels on HUD bottom-right
                var phaseLabel = ""
                if (phase === 1) phaseLabel = "INPUT PROPAGATING"
                else if (phase === 2) phaseLabel = "PROPAGATION DELAY"
                else phaseLabel = "OUTPUT STABILIZED"

                ctx.font = "bold " + Math.round(6.8 * uiScale) + "px 'JetBrainsMono Nerd Font'"
                ctx.fillStyle = (phase === 2) ? "#FF6C00" : (isGateActive ? "#39FF14" : "#FF1133")
                ctx.textAlign = "right"
                ctx.fillText(phaseLabel, hx + hudW - 12 * uiScale, hy + hudHeight - 8 * uiScale)

                // Draw a timeline progress bar representing phase propagation dynamically mapped
                var pBarY = hy + hudHeight - 4 * uiScale
                ctx.fillStyle = "rgba(255, 255, 255, 0.08)"
                ctx.fillRect(hx + 12 * uiScale, pBarY, hudW - 24 * uiScale, 2 * uiScale)

                ctx.fillStyle = (phase === 2) ? "#FF6C00" : (isGateActive ? "#39FF14" : "#FF1133")
                var phaseProgress = (phase === 1) ? inputProgress : ((phase === 2) ? processProgress : outputProgress)
                ctx.fillRect(hx + 12 * uiScale, pBarY, (hudW - 24 * uiScale) * phaseProgress, 2 * uiScale)
                ctx.restore()

                // --- PER-GATE LIVE WAVEFORM below the truth table HUD ---
                var wfH = (gate.type === "BUF" || gate.type === "NOT") ? 36 * uiScale : 52 * uiScale
                var wfY = hy + hudHeight + 4 * uiScale

                // Clamp waveform to screen bounds
                var wfX = hx
                if (wfY + wfH > height - 4) wfY = hy - wfH - 4 * uiScale
                wfX = Math.max(4, Math.min(wfX, width - hudW - 4))
                wfY = Math.max(4, Math.min(wfY, height - wfH - 4))

                drawGateWaveform(ctx, wfX, wfY, hudW, wfH, gate.type, rows, gate.color, isGateActive, simulationProgress + gi * 0.125)
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
        }

        Timer {
            interval: authenticating ? 33 : 16
            running: root.visible
            repeat: true
            onTriggered: {
                bgCanvas.simulationProgress = (bgCanvas.simulationProgress + 0.0035) % 1.0
                bgCanvas.requestPaint()
            }
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
        anchors.centerIn: parent
        width: Math.min(parent.width - 120, 1420)
        height: Math.min(parent.height - 120, 820)
        spacing: 28
        z: 2

        Rectangle {
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
                    Layout.alignment: Qt.AlignHCenter
                    width: Math.round(158 * uiScale)
                    height: Math.round(158 * uiScale)

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: 34
                        color: "#00000000"
                        border.width: 1
                        border.color: "#3A39FF14"

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.30; to: 0.72; duration: 2200; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 0.72; to: 0.30; duration: 2200; easing.type: Easing.InOutQuad }
                        }

                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.98; to: 1.03; duration: 2200; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.03; to: 0.98; duration: 2200; easing.type: Easing.InOutQuad }
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.parent.width - 12 * uiScale
                        height: parent.parent.height - 12 * uiScale
                        radius: 28
                        color: "#14000000"
                        border.width: 1
                        border.color: selectedBorder

                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 1.03; duration: 2200; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.03; to: 1.0; duration: 2200; easing.type: Easing.InOutQuad }
                        }

                        Image {
                            anchors.fill: parent
                            anchors.margins: 18
                            fillMode: Image.PreserveAspectFit
                            source: "logo.png"
                            smooth: true
                            antialiasing: true
                        }
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
                    radius: 20
                    color: "#12000000"
                    border.width: 1
                    border.color: strokeSoft
                    implicitHeight: systemStatusColumn.implicitHeight + Math.round(20 * uiScale)

                    ColumnLayout {
                        id: systemStatusColumn
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 18
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        spacing: 12

                        Text {
                            text: "SYSTEM STATUS"
                            font: sectionFont
                            color: neonGreen
                        }

                        GridLayout {
                            columns: 2
                            columnSpacing: 16
                            rowSpacing: 10
                            Layout.fillWidth: true

                            Text { text: "Host"; color: textMuted; font: bodyFont }
                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: chipFill
                                border.width: 1
                                border.color: chipBorder
                                implicitHeight: Math.round(26 * uiScale)
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    text: sddm.hostname ? sddm.hostname : "MANX"
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
                                implicitHeight: Math.round(26 * uiScale)
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    text: selectedUserDisplayName !== "" ? selectedUserDisplayName : "Awaiting selection"
                                    color: textPrimary
                                    font: bodyFont
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            Text { text: "Session"; color: textMuted; font: bodyFont }
                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: chipFill
                                border.width: 1
                                border.color: chipBorder
                                implicitHeight: Math.round(26 * uiScale)
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
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
                                implicitHeight: Math.round(26 * uiScale)
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


            }
        }

        Rectangle {
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
                anchors.margins: 24
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "module secure_auth_core;"
                            font: titleFont
                            color: maroonBright
                        }

                        Text {
                            text: selectedUserName !== "" ? ("assign active_user = \"" + selectedUserName + "\";") : "assign active_user = 8'h00;"
                            font: bodyFont
                            color: neonGreen
                        }
                    }

                    Item {
                        width: 42
                        height: 42

                        Text {
                            anchors.centerIn: parent
                            text: "◈"
                            font.family: "Orbitron"
                            font.pixelSize: Math.round(28 * uiScale)
                            font.bold: true
                            color: neonGreen
                            opacity: 0.82

                            SequentialAnimation on rotation {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0; to: 180; duration: 2600; easing.type: Easing.Linear }
                                NumberAnimation { from: 180; to: 360; duration: 2600; easing.type: Easing.Linear }
                            }
                        }
                    }

                    Item {
                        width: 126
                        height: 126

                        RectangularGlow {
                            id: avatarOuterGlow
                            anchors.fill: avatarBorderRect
                            glowRadius: 16
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
                            width: 110
                            height: 110
                            anchors.centerIn: parent
                            radius: 55
                            color: "#12000000"
                            border.width: 2
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
                    Layout.preferredHeight: 180
                    color: "transparent"

                    ListView {
                        id: userList
                        width: Math.min(parent.width, count * 180)
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

                            width: 170
                            height: 180
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

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10

                                Item {
                                    id: avatarContainer
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 116
                                    height: 116

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
                                        radius: 58
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
                                    Layout.fillWidth: true
                                    text: userCard.displayName.toUpperCase()
                                    color: userCard.isActive ? textPrimary : textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.bold: true
                                    font.pixelSize: userCard.isActive ? Math.round(16 * uiScale) : Math.round(13 * uiScale)
                                    font.letterSpacing: userCard.isActive ? 3 : 1
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight

                                    scale: userCard.isActive ? 1.08 : 1.0

                                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                                    Behavior on font.letterSpacing { NumberAnimation { duration: 250 } }
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    layer.enabled: userCard.isActive
                                    layer.effect: DropShadow {
                                        horizontalOffset: 0
                                        verticalOffset: 0
                                        radius: 6
                                        color: spectrumColor
                                        fast: true
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
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
                    implicitHeight: 52
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
                    echoMode: TextInput.Password
                    passwordCharacter: "\u0000"
                    placeholderText: "ENTER AUTHENTICATION KEY"
                    font: actionFont
                    color: "transparent"
                    selectedTextColor: "transparent"
                    horizontalAlignment: TextInput.AlignLeft
                    selectByMouse: true
                    focus: true
                    KeyNavigation.tab: loginButton
                    KeyNavigation.backtab: sessionSelector

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        visible: passwordField.text !== ""

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
                        if (!authenticating) {
                            messageColor = textMuted
                            messageText = "Awaiting secure authentication"
                        }
                        typePulse.restart()
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
                    rightPadding: 16
                    topPadding: 16
                    bottomPadding: 16
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    QQC2.Button {
                        id: loginButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(56 * uiScale)
                        font: actionFont
                        enabled: !authenticating
                        KeyNavigation.tab: clearButton
                        KeyNavigation.backtab: passwordField

                        onClicked: attemptLogin()

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
                            radius: 18
                            color: loginButton.down || loginButton.hovered ? neonGreen : buttonFill
                            border.width: 1
                            border.color: selectedBorder
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }

                    QQC2.Button {
                        id: clearButton
                        Layout.preferredWidth: Math.round(160 * uiScale)
                        Layout.preferredHeight: Math.round(56 * uiScale)
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
                            radius: 18
                            color: clearButton.hovered ? maroonBright : "#18FF1133"
                            border.width: 1
                            border.color: maroonBright
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: typeof keyboard !== "undefined" && keyboard.capsLock
                    spacing: 8
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4

                    Rectangle {
                        Layout.preferredWidth: 6
                        Layout.preferredHeight: 6
                        radius: 3
                        color: textWarning

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.3; to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.0; to: 0.3; duration: 600; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        text: "CAPS LOCK WARNING // REVERSE ENTRY HAZARD DETECTED"
                        font: capsWarningFont
                        color: textWarning
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: 16
                    color: "#12000000"
                    border.width: 1
                    border.color: messageColor

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Text {
                        id: messageTextItem
                        anchors.fill: parent
                        anchors.margins: 8
                        text: messageText
                        color: messageColor
                        font: bodyFont
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16

                    QQC2.Button {
                        id: suspendButton
                        Layout.preferredWidth: 145
                        Layout.preferredHeight: 38
                        visible: sddm.canSuspend
                        onClicked: sddm.suspend()

                        contentItem: Text {
                            text: "☾  SUSPEND"
                            font: actionFont
                            color: suspendButton.hovered ? buttonTextDark : textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 19
                            color: suspendButton.hovered ? textWarning : "#12000000"
                            border.width: suspendButton.hovered ? 2 : 1
                            border.color: textWarning

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "#00000000"
                                border.width: 1
                                border.color: suspendGlow
                                opacity: suspendButton.hovered ? 0.85 : 0.25

                                SequentialAnimation on opacity {
                                    running: suspendButton.hovered
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.30; to: 0.90; duration: 700; easing.type: Easing.InOutQuad }
                                    NumberAnimation { from: 0.90; to: 0.30; duration: 700; easing.type: Easing.InOutQuad }
                                }
                            }

                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.width { NumberAnimation { duration: 120 } }
                        }
                    }

                    QQC2.Button {
                        id: hibernateButton
                        Layout.preferredWidth: 145
                        Layout.preferredHeight: 38
                        visible: sddm.canHibernate
                        onClicked: sddm.hibernate()

                        contentItem: Text {
                            text: "⏾  HIBERNATE"
                            font: actionFont
                            color: hibernateButton.hovered ? buttonTextDark : textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 19
                            color: hibernateButton.hovered ? hibernateBorder : "#12000000"
                            border.width: hibernateButton.hovered ? 2 : 1
                            border.color: hibernateBorder

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "#00000000"
                                border.width: 1
                                border.color: hibernateGlow
                                opacity: hibernateButton.hovered ? 0.85 : 0.25

                                SequentialAnimation on opacity {
                                    running: hibernateButton.hovered
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.30; to: 0.90; duration: 700; easing.type: Easing.InOutQuad }
                                    NumberAnimation { from: 0.90; to: 0.30; duration: 700; easing.type: Easing.InOutQuad }
                                }
                            }

                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.width { NumberAnimation { duration: 120 } }
                        }
                    }

                    QQC2.Button {
                        id: rebootButton
                        Layout.preferredWidth: 145
                        Layout.preferredHeight: 38
                        visible: sddm.canReboot
                        onClicked: sddm.reboot()

                        contentItem: Text {
                            text: "↻  REBOOT"
                            font: actionFont
                            color: rebootButton.hovered ? buttonTextDark : textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 19
                            color: rebootButton.hovered ? neonGreen : "#12000000"
                            border.width: rebootButton.hovered ? 2 : 1
                            border.color: selectedBorder

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "#00000000"
                                border.width: 1
                                border.color: passwordGlow
                                opacity: rebootButton.hovered ? 0.85 : 0.25

                                SequentialAnimation on opacity {
                                    running: rebootButton.hovered
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.30; to: 0.90; duration: 700; easing.type: Easing.InOutQuad }
                                    NumberAnimation { from: 0.90; to: 0.30; duration: 700; easing.type: Easing.InOutQuad }
                                }
                            }

                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.width { NumberAnimation { duration: 120 } }
                        }
                    }

                    QQC2.Button {
                        id: shutdownButton
                        Layout.preferredWidth: 145
                        Layout.preferredHeight: 38
                        visible: sddm.canPowerOff
                        onClicked: sddm.powerOff()

                        contentItem: Text {
                            text: "⏻  SHUTDOWN"
                            font: actionFont
                            color: shutdownButton.hovered ? buttonTextDark : textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 19
                            color: shutdownButton.hovered ? maroonBright : "#12000000"
                            border.width: shutdownButton.hovered ? 2 : 1
                            border.color: maroonBright

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "#00000000"
                                border.width: 1
                                border.color: shutdownGlow
                                opacity: shutdownButton.hovered ? 0.85 : 0.25

                                SequentialAnimation on opacity {
                                    running: shutdownButton.hovered
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.30; to: 0.90; duration: 700; easing.type: Easing.InOutQuad }
                                    NumberAnimation { from: 0.90; to: 0.30; duration: 700; easing.type: Easing.InOutQuad }
                                }
                            }

                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.width { NumberAnimation { duration: 120 } }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            authenticating = false
            passwordField.text = ""
            passwordField.forceActiveFocus()
            messageColor = maroonBright
            messageText = "Decryption Core Error: Cryptographic Key Signature Invalid"
            shakeAnim.start()
            passwordField.background.triggerFailGlow()
            resetMessageTimer.start()
        }

        function onLoginSucceeded() {
            authenticating = false
            messageColor = neonGreen
            messageText = "Access Granted! Loading Manx VLSI Environment..."
        }

        function onInformationMessage(message) {
            authenticating = false
            messageColor = textWarning
            messageText = message
        }
    }
}
