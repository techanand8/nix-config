import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import SddmComponents 2.0

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

    readonly property real scaleFactor: Screen.devicePixelRatio || 1.0
    readonly property real uiScale: Math.max(0.85, Math.min(width / 1920, height / 1080) * scaleFactor)

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

    readonly property font titleFont: Qt.font({ family: "Orbitron", pixelSize: Math.max(16, Math.round(30 * uiScale)), bold: true, letterSpacing: 5 })
    readonly property font sectionFont: Qt.font({ family: "JetBrains Mono", pixelSize: Math.max(10, Math.round(13 * uiScale)), bold: true, letterSpacing: 2 })
    readonly property font bodyFont: Qt.font({ family: "JetBrains Mono", pixelSize: Math.max(9, Math.round(12 * uiScale)), bold: true })
    readonly property font actionFont: Qt.font({ family: "JetBrains Mono", pixelSize: Math.max(11, Math.round(14 * uiScale)), bold: true, letterSpacing: 1 })
    readonly property font capsWarningFont: Qt.font({ family: "JetBrains Mono", pixelSize: Math.max(9, Math.round(10 * uiScale)), bold: true, letterSpacing: 2 })

    property bool authenticating: false
    property string messageText: "Awaiting secure authentication"
    property color messageColor: textMuted
    property string selectedUserName: ""
    property string selectedUserDisplayName: ""
    property string selectedUserIcon: ""
    property string selectedSessionName: ""
    property string timeString: Qt.formatTime(new Date(), "hh:mm")
    property string dateString: Qt.formatDate(new Date(), "dddd, dd MMM yyyy")

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

        property var particles: []
        property int numParticles: 32
        property real pulse: 0

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
                    vx: (Math.random() - 0.5) * 0.9,
                    vy: (Math.random() - 0.5) * 0.9,
                    r: Math.random() * 2.6 + 0.8,
                    a: Math.random() * 0.35 + 0.12
                })
            }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            var bg = ctx.createLinearGradient(0, 0, width, height)
            bg.addColorStop(0.0, "#040107")
            bg.addColorStop(0.4, "#0B0210")
            bg.addColorStop(0.7, "#09040C")
            bg.addColorStop(1.0, "#020203")
            ctx.fillStyle = bg
            ctx.fillRect(0, 0, width, height)

            var vignette = ctx.createRadialGradient(width * 0.5, height * 0.5, Math.min(width, height) * 0.1,
                                                    width * 0.5, height * 0.5, Math.max(width, height) * 0.7)
            vignette.addColorStop(0.0, "rgba(168, 8, 0, 0.18)")
            vignette.addColorStop(0.45, "rgba(57, 255, 20, 0.04)")
            vignette.addColorStop(1.0, "rgba(0, 0, 0, 0.92)")
            ctx.fillStyle = vignette
            ctx.fillRect(0, 0, width, height)

            pulse += authenticating ? 0.030 : 0.012

            ctx.strokeStyle = "rgba(57, 255, 20, 0.06)"
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
            var scanY = (Math.sin(pulse) * 0.5 + 0.5) * height
            var scan = ctx.createLinearGradient(0, scanY - 80, 0, scanY + 80)
            scan.addColorStop(0.0, "rgba(0, 0, 0, 0)")
            scan.addColorStop(0.5, "rgba(57, 255, 20, 0.11)")
            scan.addColorStop(1.0, "rgba(0, 0, 0, 0)")
            ctx.fillStyle = scan
            ctx.fillRect(0, scanY - 80, width, 160)

            for (var i = 0; i < particles.length; ++i) {
                var p = particles[i]
                p.x += p.vx
                p.y += p.vy

                if (p.x < -10) p.x = width + 10
                if (p.x > width + 10) p.x = -10
                if (p.y < -10) p.y = height + 10
                if (p.y > height + 10) p.y = -10

                ctx.beginPath()
                ctx.arc(p.x, p.y, p.r * 2.8, 0, Math.PI * 2)
                ctx.fillStyle = "rgba(57, 255, 20, " + (p.a * 0.25) + ")"
                ctx.fill()

                ctx.beginPath()
                ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
                ctx.fillStyle = "rgba(57, 255, 20, " + p.a + ")"
                ctx.fill()

                for (var j = i + 1; j < particles.length; ++j) {
                    var p2 = particles[j]
                    var dx = p.x - p2.x
                    var dy = p.y - p2.y
                    var distSq = dx * dx + dy * dy
                    if (distSq < 8100) {
                        var dist = Math.sqrt(distSq)
                        var alpha = (1.0 - dist / 90.0) * 0.08
                        ctx.beginPath()
                        ctx.moveTo(p.x, p.y)
                        ctx.lineTo(p2.x, p2.y)
                        ctx.strokeStyle = "rgba(168, 8, 0, " + alpha + ")"
                        ctx.lineWidth = 1
                        ctx.stroke()
                    }
                }
            }
        }

        Timer {
            interval: authenticating ? 33 : 90
            running: root.visible
            repeat: true
            onTriggered: bgCanvas.requestPaint()
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
                anchors.margins: 34
                spacing: 18

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    width: 210
                    height: 210

                    Rectangle {
                        anchors.centerIn: parent
                        width: 206
                        height: 206
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
                        width: 180
                        height: 180
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

                    Text {
                        text: timeString
                        font.family: "Orbitron"
                        font.pixelSize: Math.round(52 * uiScale)
                        font.bold: true
                        color: textPrimary
                    }

                    Text {
                        text: dateString
                        font: bodyFont
                        color: textMuted
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 20
                    color: "#12000000"
                    border.width: 1
                    border.color: strokeSoft
                    implicitHeight: systemStatusColumn.implicitHeight + 36

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
                                implicitHeight: 32
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
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
                                implicitHeight: 32
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
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
                                implicitHeight: 32
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
                                implicitHeight: 32
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    text: "Shutdown • Reboot • Suspend"
                                    color: textPrimary
                                    font: bodyFont
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
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

                        Rectangle {
                            anchors.centerIn: parent
                            width: 126
                            height: 126
                            radius: 63
                            color: "#00000000"
                            border.width: 1
                            border.color: "#3039FF14"
                            opacity: authenticating ? 0.92 : 0.48

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
                            border.color: authenticating ? maroonBright : selectedBorder
                            clip: true

                            SequentialAnimation {
                                loops: Animation.Infinite
                                running: !authenticating

                                ColorAnimation {
                                    target: avatarBorderRect.border
                                    property: "color"
                                    from: selectedBorder
                                    to: maroonBright
                                    duration: 2500
                                    easing.type: Easing.InOutQuad
                                }

                                ColorAnimation {
                                    target: avatarBorderRect.border
                                    property: "color"
                                    from: maroonBright
                                    to: selectedBorder
                                    duration: 2500
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            Image {
                                anchors.fill: parent
                                anchors.margins: 8
                                fillMode: Image.PreserveAspectCrop
                                source: selectedUserIcon !== "" ? selectedUserIcon : "logo.png"
                                smooth: true
                                antialiasing: true

                                onStatusChanged: {
                                    if (status === Image.Error && source != "logo.png")
                                        source = "logo.png"
                                }
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

                        Component.onCompleted: {
                            currentIndex = (typeof userModel !== "undefined" && userModel && userModel.count > 0) ? Math.max(0, userModel.lastIndex) : -1
                            positionViewAtIndex(currentIndex, ListView.Contain)
                            syncSelectedUser()
                        }

                        onCurrentItemChanged: syncSelectedUser()

                        delegate: Rectangle {
                            id: userCard
                            property string userName: name
                            property string displayName: realName !== "" ? realName : name
                            property string iconSource: icon !== "" ? icon : "logo.png"

                            width: 170
                            height: 180
                            color: "transparent"
                            scale: userMouse.containsMouse || ListView.isCurrentItem ? 1.05 : 1.0

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

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 116
                                    height: 116
                                    radius: 58
                                    color: "#16000000"
                                    border.width: ListView.isCurrentItem ? 2 : 1
                                    border.color: ListView.isCurrentItem ? selectedBorder : strokeSoft
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        fillMode: Image.PreserveAspectCrop
                                        source: userCard.iconSource
                                        smooth: true
                                        antialiasing: true

                                        onStatusChanged: {
                                            if (status === Image.Error && source != "logo.png")
                                                source = "logo.png"
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: userCard.displayName
                                    color: textPrimary
                                    font: actionFont
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: ListView.isCurrentItem ? "ACTIVE" : ""
                                    color: neonGreen
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: Math.round(11 * uiScale)
                                    font.bold: true
                                    font.letterSpacing: 1
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: ListView.isCurrentItem
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

                    indicator: Canvas {
                        x: sessionSelector.width - width - 16
                        y: sessionSelector.topPadding + (sessionSelector.availableHeight - height) / 2
                        width: 14
                        height: 8
                        contextType: "2d"
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.moveTo(0, 0)
                            ctx.lineTo(width, 0)
                            ctx.lineTo(width / 2, height)
                            ctx.closePath()
                            ctx.fillStyle = "#39FF14"
                            ctx.fill()
                        }
                    }

                    background: Rectangle {
                        radius: 16
                        color: inputFill
                        border.width: sessionSelector.visualFocus ? 2 : 1
                        border.color: sessionSelector.visualFocus ? selectedBorder : inputBorder
                    }

                    popup: QQC2.Popup {
                        y: sessionSelector.height + 6
                        width: sessionSelector.width
                        padding: 8
                        modal: true
                        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: sessionSelector.popup.visible ? sessionSelector.delegateModel : null
                            currentIndex: sessionSelector.highlightedIndex
                            QQC2.ScrollIndicator.vertical: QQC2.ScrollIndicator {}
                        }

                        background: Rectangle {
                            radius: 18
                            color: panelAlt
                            border.width: 1
                            border.color: selectedBorder
                        }
                    }

                    delegate: QQC2.ItemDelegate {
                        width: sessionSelector.width - 16
                        contentItem: Text {
                            text: (typeof modelData !== "undefined" && modelData && modelData.name) ? modelData.name : (model && model.name ? model.name : "")
                            font: bodyFont
                            color: highlighted ? neonGreen : textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        background: Rectangle {
                            radius: 12
                            color: highlighted ? hoverFill : "transparent"
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
                    passwordCharacter: "◈"
                    placeholderText: "ENTER AUTHENTICATION KEY"
                    font: actionFont
                    color: passwordField.text !== "" ? maroonBright : textPrimary
                    horizontalAlignment: TextInput.AlignLeft
                    selectByMouse: true
                    focus: true
                    KeyNavigation.tab: loginButton
                    KeyNavigation.backtab: sessionSelector

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
                        id: rebootButton
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 38
                        visible: true
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
                            border.width: 1
                            border.color: selectedBorder
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }

                    QQC2.Button {
                        id: shutdownButton
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 38
                        visible: true
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
