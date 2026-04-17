import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15

Item {
    id: root
    anchors.fill: parent

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
            GradientStop { position: 0.25; color: "#80ffffff" }
            GradientStop { position: 0.35; color: '#ffffff' }
            GradientStop { position: 0.8; color: '#ffffff' }
        }
    }

    Shape {
        id: outerRingContainer
        width: 1400 
        height: 1400
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

        NumberAnimation on rotation {
            from: 360
            to: 0
            duration: 30000
            loops: Animation.Infinite
        }

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
        width: 1200
        height: 1200
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
        width: 1000 
        height: 1000
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

        NumberAnimation on rotation {
            from: 0
            to: 360
            duration: 25000
            loops: Animation.Infinite
        }

        ShapePath {
            id: ringPath
            fillColor: "transparent"
            strokeColor: "#c28710" // Gold
            strokeWidth: 70 // Matches the thickness of image_1.png

            // Define the dash pattern and spacing
            strokeStyle: ShapePath.DashLine
            dashPattern: [1, 0.5] // Long dash, medium gap
            capStyle: ShapePath.FlatCap // Sharp edges as requested
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
