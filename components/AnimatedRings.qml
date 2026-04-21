import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15

Item {
    id: root
    anchors.fill: parent

    property real wheelVisualIndex: 0
    property int wheelItemCount: 1
    
    property real baseWheelRotation: -(wheelVisualIndex * (360 / Math.max(1, wheelItemCount)))

    property real autoRotationFWD: 0
    property real autoRotationBWD: 360
    
    NumberAnimation on autoRotationFWD {
        from: 0
        to: 360
        duration: 25000
        loops: Animation.Infinite
    }
    
    NumberAnimation on autoRotationBWD {
        from: 360
        to: 0
        duration: 30000
        loops: Animation.Infinite
    }

    RadialGradient {
        id: glowBackground
        width: 3100
        height: 3000
        x: -width / 2
        y: -height / 2
        horizontalOffset: 0
        verticalOffset: 0
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.2; color: '#60ffffff' }
            GradientStop { position: 0.23; color: '#80ffffff' }
            GradientStop { position: 0.3; color: '#d9ffffff' }
            GradientStop { position: 1; color: '#d9ffffff' }
        }
    }

    Rectangle {
        id: glowBackground21
        width: 1000
        height: parent.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: false
        
        gradient: Gradient {

            orientation: Gradient.Horizontal 

            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.2; color: '#08094020' }
            GradientStop { position: 0.23; color: '#16094020' }
            GradientStop { position: 0.3; color: '#23094020' }
            GradientStop { position: 1; color: '#3c094020' }
        }
    }
    Rectangle {
        id: glowBackground22
        width: 1000
        height: parent.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: false
        
        gradient: Gradient {

            orientation: Gradient.Horizontal 

            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.2; color: '#08c28710' }
            GradientStop { position: 0.23; color: '#16c28710' }
            GradientStop { position: 0.3; color: '#23c28710' }
            GradientStop { position: 1; color: '#3cc28710' }
        }
    }
    Rectangle {
        id: glowBackground23
        width: 1000
        height: parent.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: true
        
        gradient: Gradient {

            orientation: Gradient.Horizontal 

            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.2; color: '#30ffffff' }
            GradientStop { position: 0.23; color: '#50ffffff' }
            GradientStop { position: 0.3; color: '#70ffffff' }
            GradientStop { position: 1; color: '#90ffffff' }
        }
    }

    property int gameIndex: 0
    property real seed: 123.456
    onGameIndexChanged: seed = Math.random() * 1000

    Item {
        id: bubblesMaskGreen
        anchors.fill: glowBackground21
        visible: false
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Repeater {
            model: 45
            Rectangle {
                width: (Math.sin(index + root.seed) + 1) * 60 + 20
                height: width
                radius: width / 2
                color: "black"
                x: ((Math.cos(index * 7 + root.seed) + 1) / 2) * parent.width
                y: ((Math.sin(index * 3 + root.seed) + 1) / 2) * parent.height
            }
        }
    }

    Item {
        id: bubblesMaskGold
        anchors.fill: glowBackground22
        visible: false
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Repeater {
            model: 35
            Rectangle {
                width: (Math.cos(index * 5 + root.seed) + 1) * 40 + 15
                height: width
                radius: width / 2
                color: "black"
                x: ((Math.sin(index * 11 + root.seed) + 1) / 2) * parent.width
                y: ((Math.cos(index * 2 + root.seed) + 1) / 2) * parent.height
            }
        }
    }

    OpacityMask {
        anchors.fill: glowBackground21
        source: glowBackground21
        maskSource: bubblesMaskGreen
    }

    OpacityMask {
        anchors.fill: glowBackground22
        source: glowBackground22
        maskSource: bubblesMaskGold
    }

    Shape {
        id: outerRingContainer
        width: parent.width *1.5
        height: parent.height *1.5
        x: -width / 2
        y: -height / 2
        antialiasing: false

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#cc000000"
            radius: 16
            samples: 33
        }

        // Spins structurally opposite to inner ring, combined with reverse idle
        rotation: root.autoRotationBWD - (root.baseWheelRotation * 0.5)

        ShapePath {
            id: outerRingPath
            fillColor: "transparent"
            strokeColor: "#c28710" // Gold
            strokeWidth: 70 // Matches the inner ring

            // Define the dash pattern and spacing
            strokeStyle: ShapePath.DashLine
            dashPattern: [2, 0.5] 
            capStyle: ShapePath.FlatCap 
            joinStyle: ShapePath.BevelJoin

            // 1. Calculate the circle's true center
            property real cx: outerRingContainer.width / 2
            property real cy: outerRingContainer.height / 2

            // 2. Calculate the "usable radius" (radius - half stroke width)
            property real usableR: cy - (strokeWidth / 2)

            // 3. Set the start position at top center
            startX: cx
            startY: cy - usableR

            // 4. Draw the first arc to the bottom center
            PathArc {
                x: outerRingPath.cx 
                y: outerRingPath.cy + outerRingPath.usableR
                radiusX: outerRingPath.usableR
                radiusY: outerRingPath.usableR
                useLargeArc: true
            }

            // 5. Draw the second arc back to the top center
            PathArc {
                x: outerRingPath.cx
                y: outerRingPath.cy - outerRingPath.usableR
                radiusX: outerRingPath.usableR
                radiusY: outerRingPath.usableR
                useLargeArc: true
            }
        }
    }

    Shape {
        id: middleRingContainer
        width: parent.width *0.8
        height: parent.width *0.8
        x: -width / 2
        y: -height / 2
        antialiasing: false

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#cc000000"
            radius: 16
            samples: 33
        }

        ShapePath {
            id: middleRingPath
            fillColor: "transparent"
            strokeColor: "#c28710" // Gold
            strokeWidth: 70 // Matches the others

            // No dash, making it a solid line
            strokeStyle: ShapePath.SolidLine

            // 1. Calculate the circle's true center
            property real cx: middleRingContainer.width / 2
            property real cy: middleRingContainer.height / 2

            // 2. Calculate the "usable radius" (radius - half stroke width)
            property real usableR: cy - (strokeWidth / 2)

            // 3. Set the start position at top center
            startX: cx
            startY: cy - usableR

            // 4. Draw the first arc to the bottom center
            PathArc {
                x: middleRingPath.cx 
                y: middleRingPath.cy + middleRingPath.usableR
                radiusX: middleRingPath.usableR
                radiusY: middleRingPath.usableR
                useLargeArc: true
            }

            // 5. Draw the second arc back to the top center
            PathArc {
                x: middleRingPath.cx
                y: middleRingPath.cy - middleRingPath.usableR
                radiusX: middleRingPath.usableR
                radiusY: middleRingPath.usableR
                useLargeArc: true
            }
        }
    }

    Shape {
        id: ringContainer
        width: parent.width *1.05
        height: parent.height *1.05
        x: -width / 2
        y: -height / 2 // This centers it perfectly
        antialiasing: false

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#cc000000"
            radius: 16
            samples: 33
        }

        // Exact lock with the game wheel so game items physically sit on this dashed track, combined with forward idle drift
        rotation: root.autoRotationFWD + root.baseWheelRotation

        ShapePath {
            id: ringPath
            fillColor: "transparent"
            strokeColor: "#c28710" // Gold
            strokeWidth: 70 // Matches the thickness of image_1.png

            // Define the dash pattern and spacing
            strokeStyle: ShapePath.DashLine
            dashPattern: [1, 0.5] // Long dash, medium gap
            capStyle: ShapePath.FlatCap // Sharp edges as requested
            // radius: 10
            joinStyle: ShapePath.BevelJoin

            // --- MATH-BASED COORDINATES ---
            property real cx: ringContainer.width / 2
            property real cy: ringContainer.height / 2
            property real usableR: cy - (strokeWidth / 2)

            startX: cx
            startY: cy - usableR

            PathArc {
                x: ringPath.cx 
                y: ringPath.cy + ringPath.usableR
                radiusX: ringPath.usableR
                radiusY: ringPath.usableR
                useLargeArc: true
            }

            PathArc {
                x: ringPath.cx
                y: ringPath.cy - ringPath.usableR
                radiusX: ringPath.usableR
                radiusY: ringPath.usableR
                useLargeArc: true
            }
        }
    }
}
