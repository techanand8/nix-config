import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#020000"

    // Custom properties
    readonly property color neonGreen: "#39FF14"
    readonly property color deepMaroon: "#A80800"
    readonly property color bgDark: "#0c0002"
    readonly property color borderDark: "#300005"
    readonly property font cyberFont: Qt.font({ family: "JetBrains Mono", pixelSize: 14, bold: true })

    // --- REALTIME DYNAMIC CANVAS GHOST ANIMATION ---
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        z: 1

        property var particles: []
        property int numParticles: 50

        onWidthChanged: reinitParticles()
        onHeightChanged: reinitParticles()

        function reinitParticles() {
            if (width <= 0 || height <= 0) return;
            particles = [];
            for (var i = 0; i < numParticles; i++) {
                particles.push({
                    x: Math.random() * width,
                    y: Math.random() * height,
                    vx: (Math.random() - 0.5) * 1.5,
                    vy: (Math.random() - 0.5) * 1.5,
                    r: Math.random() * 2 + 1,
                    alpha: Math.random() * 0.4 + 0.2
                });
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            // 1. Draw Deep Maroon Vignette Gradient
            var grad = ctx.createRadialGradient(width / 2, height / 2, 50, width / 2, height / 2, Math.max(width, height) * 0.85);
            grad.addColorStop(0, "#180004"); // Dark Maroon center
            grad.addColorStop(0.7, "#040001");
            grad.addColorStop(1, "#000000"); // Pure Black vignette edges
            ctx.fillStyle = grad;
            ctx.fillRect(0, 0, width, height);

            // 2. Update and draw neon green particles & connections
            for (var i = 0; i < particles.length; i++) {
                var p = particles[i];
                p.x += p.vx;
                p.y += p.vy;

                // Wrap around edges
                if (p.x < 0) p.x = width;
                if (p.x > width) p.x = 0;
                if (p.y < 0) p.y = height;
                if (p.y > height) p.y = 0;

                // Draw Particle Glow
                ctx.beginPath();
                ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
                ctx.fillStyle = "rgba(57, 255, 20, " + p.alpha + ")";
                ctx.shadowColor = neonGreen;
                ctx.shadowBlur = 10;
                ctx.fill();

                // Connections
                for (var j = i + 1; j < particles.length; j++) {
                    var p2 = particles[j];
                    var dist = Math.hypot(p.x - p2.x, p.y - p2.y);
                    if (dist < 130) {
                        var alpha = (1.0 - (dist / 130)) * 0.12;
                        ctx.beginPath();
                        ctx.moveTo(p.x, p.y);
                        ctx.lineTo(p2.x, p2.y);
                        ctx.strokeStyle = "rgba(168, 8, 0, " + alpha + ")"; // Maroon glow connections
                        ctx.lineWidth = 1;
                        ctx.shadowBlur = 0;
                        ctx.stroke();
                    }
                }
            }
        }

        Timer {
            id: animTimer
            interval: 16 // 60 FPS
            running: true
            repeat: true
            onTriggered: bgCanvas.requestPaint()
        }
    }

    // --- CENTRAL GLASSMORPHIC CARD ---
    Rectangle {
        id: loginCard
        width: 450
        height: 600
        anchors.centerIn: parent
        color: Qt.rgba(12/255.0, 0.0, 2/255.0, 0.65) // Translucent deep maroon-black
        border.color: neonGreen
        border.width: 1.5
        radius: 20
        z: 2
        opacity: 0

        // Subtle glow effect
        layer.enabled: true

        // Slide-in / Fade-in animation on load
        Component.onCompleted: {
            fadeInAnimation.start();
        }

        SequentialAnimation {
            id: fadeInAnimation
            NumberAnimation { target: loginCard; property: "opacity"; from: 0; to: 1; duration: 800; easing.type: Easing.OutQuad }
        }

        // --- GLOWING GHOST BORDER PULSING ANIMATION ---
        SequentialAnimation on border.color {
            loops: Animation.Infinite
            ColorAnimation { from: neonGreen; to: deepMaroon; duration: 2500; easing.type: Easing.InOutQuad }
            ColorAnimation { from: deepMaroon; to: neonGreen; duration: 2500; easing.type: Easing.InOutQuad }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20

            // 1. HEADER (Logo)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "MAYANK"
                    font.family: "Orbitron"
                    font.pixelSize: 32
                    font.bold: true
                    font.letterSpacing: 6
                    color: neonGreen
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    
                    style: Text.Outline
                    styleColor: deepMaroon
                }

                Text {
                    text: "SECURE DECRYPTION TERMINAL"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 2
                    color: Qt.rgba(168/255.0, 8/255.0, 0.0, 0.8) // Translucent maroon
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }

            Item { Layout.fillHeight: true }

            // 2. USER PROFILE IMAGE WITH PULSING RING
            Item {
                width: 130
                height: 130
                Layout.alignment: Qt.AlignHCenter

                // Outer pulsing border
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: neonGreen
                    border.width: 2

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 1.08; duration: 1800; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.08; to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
                    }

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.8; to: 0.2; duration: 1800; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.2; to: 0.8; duration: 1800; easing.type: Easing.InOutSine }
                    }
                }

                // Inner avatar ring
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: width / 2
                    color: bgDark
                    border.color: deepMaroon
                    border.width: 2
                    clip: true

                    Image {
                        id: avatarImage
                        anchors.fill: parent
                        anchors.margins: 2
                        fillMode: Image.PreserveAspectCrop
                        source: userSelector.currentText !== "" ? "image://face/" + userSelector.currentText : ""
                        
                        onStatusChanged: {
                            if (status == Image.Error || source == "") {
                                fallbackIcon.visible = true;
                                avatarImage.visible = false;
                            } else {
                                fallbackIcon.visible = false;
                                avatarImage.visible = true;
                            }
                        }
                    }

                    // Fallback Ghost Icon
                    Text {
                        id: fallbackIcon
                        text: "💀"
                        font.pixelSize: 52
                        anchors.centerIn: parent
                        visible: true
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // 3. USERNAME SELECTOR
            ComboBox {
                id: userSelector
                Layout.fillWidth: true
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
                font: cyberFont
                
                contentItem: Text {
                    text: "USER // " + userSelector.currentText.toUpperCase()
                    font: userSelector.font
                    color: neonGreen
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 12
                }

                background: Rectangle {
                    color: bgDark
                    border.color: borderDark
                    border.width: 1
                    radius: 8
                }

                popup: Popup {
                    width: userSelector.width
                    height: Math.min(200, contentItem.implicitHeight)
                    y: userSelector.height + 4
                    padding: 1
                    
                    contentItem: ListView {
                        model: userSelector.delegateModel
                        clip: true
                    }

                    background: Rectangle {
                        color: bgDark
                        border.color: neonGreen
                        border.width: 1
                        radius: 8
                    }
                }

                delegate: ItemDelegate {
                    width: parent.width
                    height: 40
                    contentItem: Text {
                        text: model.name.toUpperCase()
                        color: hovered ? neonGreen : "white"
                        font: cyberFont
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                    }
                    background: Rectangle {
                        color: hovered ? Qt.rgba(57/255.0, 255/255.0, 20/255.0, 0.15) : "transparent"
                    }
                }
            }

            // 4. PASSWORD FIELD WITH SHADOW
            TextField {
                id: passwordField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                passwordCharacter: "•"
                font: cyberFont
                placeholderText: "ENTER ENCRYPTION KEY"
                color: neonGreen
                horizontalAlignment: TextInput.AlignHCenter
                focus: true
                
                // Clear errors on typing
                onTextChanged: loginErrorMsg.visible = false

                placeholderTextColor: "rgba(168, 8, 0, 0.5)"

                background: Rectangle {
                    color: "#050001"
                    border.color: passwordField.activeFocus ? neonGreen : borderDark
                    border.width: passwordField.activeFocus ? 2 : 1
                    radius: 8
                    
                    layer.enabled: passwordField.activeFocus
                }

                onAccepted: loginButton.clicked()
            }

            // 5. SESSION SELECTOR
            ComboBox {
                id: sessionSelector
                Layout.fillWidth: true
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
                font: cyberFont

                contentItem: Text {
                    text: "SESSION // " + sessionSelector.currentText.toUpperCase()
                    font: sessionSelector.font
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 12
                }

                background: Rectangle {
                    color: bgDark
                    border.color: borderDark
                    border.width: 1
                    radius: 8
                }

                popup: Popup {
                    width: sessionSelector.width
                    height: Math.min(200, contentItem.implicitHeight)
                    y: sessionSelector.height + 4
                    padding: 1

                    contentItem: ListView {
                        model: sessionSelector.delegateModel
                        clip: true
                    }

                    background: Rectangle {
                        color: bgDark
                        border.color: neonGreen
                        border.width: 1
                        radius: 8
                    }
                }

                delegate: ItemDelegate {
                    width: parent.width
                    height: 40
                    contentItem: Text {
                        text: model.name.toUpperCase()
                        color: hovered ? neonGreen : "white"
                        font: cyberFont
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                    }
                    background: Rectangle {
                        color: hovered ? Qt.rgba(57/255.0, 255/255.0, 20/255.0, 0.15) : "transparent"
                    }
                }
            }

            // 6. LOGIN BUTTON
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                text: "DECRYPT & ACCESS"
                font: cyberFont
                
                contentItem: Text {
                    text: loginButton.text
                    font: loginButton.font
                    color: loginButton.hovered ? "#000000" : neonGreen
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: loginButton.hovered ? neonGreen : Qt.rgba(57/255.0, 255/255.0, 20/255.0, 0.08)
                    border.color: neonGreen
                    border.width: 1
                    radius: 8
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                onClicked: {
                    sddm.login(userSelector.currentText, passwordField.text, sessionSelector.currentIndex)
                }
            }

            // 7. ERROR MESSAGE
            Text {
                id: loginErrorMsg
                text: "ACCESS RESTRICTED: INVALID DECRYPTION KEY"
                font.family: "JetBrains Mono"
                font.pixelSize: 10
                font.bold: true
                color: "#FF1133"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                visible: false

                SequentialAnimation on opacity {
                    running: loginErrorMsg.visible
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.3; duration: 500 }
                    NumberAnimation { to: 1.0; duration: 500 }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // --- SDDM LOGIN EVENTS INTERCEPTOR ---
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.text = ""
            passwordField.forceActiveFocus()
            loginErrorMsg.visible = true
        }
    }

    // --- SYSTEM POWER MANAGEMENT SYSTEM ---
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30
        spacing: 40
        z: 3

        Button {
            id: suspendBtn
            text: "SUSPEND"
            font: cyberFont
            visible: sddm.canSuspend
            
            contentItem: Text {
                text: "💤 " + suspendBtn.text
                font: suspendBtn.font
                color: suspendBtn.hovered ? neonGreen : Qt.rgba(1.0, 1.0, 1.0, 0.6)
            }
            background: Item {}
            onClicked: sddm.suspend()
        }

        Button {
            id: rebootBtn
            text: "REBOOT"
            font: cyberFont
            visible: sddm.canReboot

            contentItem: Text {
                text: "🌀 " + rebootBtn.text
                font: rebootBtn.font
                color: rebootBtn.hovered ? neonGreen : Qt.rgba(1.0, 1.0, 1.0, 0.6)
            }
            background: Item {}
            onClicked: sddm.reboot()
        }

        Button {
            id: shutdownBtn
            text: "SHUTDOWN"
            font: cyberFont
            visible: sddm.canPowerOff

            contentItem: Text {
                text: "⚡ " + shutdownBtn.text
                font: shutdownBtn.font
                color: shutdownBtn.hovered ? neonGreen : Qt.rgba(1.0, 1.0, 1.0, 0.6)
            }
            background: Item {}
            onClicked: sddm.powerOff()
        }
    }
}
