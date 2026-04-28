import QtQuick 2.15
import QtGraphicalEffects 1.15

FocusScope {
    id: root
    focus: true

    property var model: null

    property int currentIndex: 0

    // Unwrapped target position of the wheel (initialized in onCompleted, NOT bound)
    property real targetVisualIndex: 0

    // Actual animated visual position
    property real visualIndex: 0

    Component.onCompleted: {
        targetVisualIndex = currentIndex;
        visualIndex = currentIndex;
    }

    property real selectedAngleDegrees: 270

    property real centerXRatio: 0.5
    property real centerYRatio: 0.5

    // 0.5 = circle diameter is half the screen width
    property real radiusRatio: 0.8

    property real baseItemSizeRatio: 0.12
    readonly property real baseItemSize: width * baseItemSizeRatio

    property real selectedScale: 1.0
    property real unselectedScale: 0.72

    property real selectedOpacity: 1.0
    property real unselectedOpacity: 0.45

    property int visibleCount: -1

    property bool launchOnAccept: true
    property bool useLogoFirst: true

    property real wheelVelocity: 8
    property int wheelDuration: -1
    property int wheelMaxEasingTime: 120
    property int wheelReversingMode: SmoothedAnimation.Immediate

    signal currentIndexChangedByUser(int index)
    signal gameActivated(var game)

    readonly property real centerX: width * centerXRatio
    readonly property real centerY: height * centerYRatio
    readonly property real radius: (width * radiusRatio) / 2

    readonly property int visualSelectedIndex: wrapIndex(Math.round(visualIndex))

    Behavior on visualIndex {
    SmoothedAnimation {
        velocity: root.wheelVelocity
        duration: root.wheelDuration
        maximumEasingTime: root.wheelMaxEasingTime
        reversingMode: root.wheelReversingMode
    }
}

    onTargetVisualIndexChanged: {
        visualIndex = targetVisualIndex;
    }

    function modelCount() {
        return model ? model.count : 0;
    }

    function getGame(index) {
        if (!model || index < 0 || index >= model.count)
            return null;
        return model.get(index);
    }

    function wrapIndex(i) {
        var count = modelCount();
        if (count <= 0)
            return 0;
        return ((i % count) + count) % count;
    }

    function setCurrentIndex(i) {
        var count = modelCount();
        if (count <= 0)
            return;

        var wrapped = wrapIndex(i);
        var diff = shortestSignedDistance(currentIndex, wrapped, count);

        currentIndex = wrapped;
        targetVisualIndex = targetVisualIndex + diff;
    }

    function nextGame() {
        var count = modelCount();
        if (count <= 0)
            return;

        currentIndex = wrapIndex(currentIndex + 1);
        targetVisualIndex = targetVisualIndex + 1;
        currentIndexChangedByUser(currentIndex);
    }

    function previousGame() {
        var count = modelCount();
        if (count <= 0)
            return;

        currentIndex = wrapIndex(currentIndex - 1);
        targetVisualIndex = targetVisualIndex - 1;
        currentIndexChangedByUser(currentIndex);
    }

    function activateCurrentGame() {
        var game = getGame(currentIndex);
        if (!game)
            return;

        gameActivated(game);

        if (launchOnAccept)
            game.launch();
    }

    function gameImage(game) {
        if (!game)
            return "";

        if (useLogoFirst) {
            return game.assets.logo
                || game.assets.boxFront
                || game.assets.tile
                || game.assets.poster
                || game.assets.banner
                || game.assets.screenshot;
        }

        return game.assets.boxFront
            || game.assets.logo
            || game.assets.tile
            || game.assets.poster
            || game.assets.banner
            || game.assets.screenshot;
    }

    function shortestSignedDistance(fromIndex, toIndex, count) {
        if (count <= 0)
            return 0;

        var diff = toIndex - fromIndex;
        diff = ((diff % count) + count) % count;

        if (diff >= count / 2)
            diff -= count;

        return diff;
    }

    function shortestSignedDistanceReal(fromIndex, toIndex, count) {
        if (count <= 0)
            return 0;

        var diff = toIndex - fromIndex;
        diff = ((diff % count) + count) % count;

        if (diff >= count / 2)
            diff -= count;

        return diff;
    }

    function degToRad(deg) {
        return deg * Math.PI / 180.0;
    }

    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            activateCurrentGame();
            return;
        }

        if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            event.accepted = true;
            nextGame();
            return;
        }

        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
            event.accepted = true;
            previousGame();
            return;
        }
    }

    Repeater {
        model: root.model ? root.model : 0

        delegate: Item {
            id: gameItem
            property int total: root.modelCount()
            property bool selected: index === root.visualSelectedIndex

            property real relativeIndex: root.shortestSignedDistanceReal(root.visualIndex, index, total)

            property bool withinVisibleRange: root.visibleCount < 0
                                              || Math.abs(relativeIndex) <= Math.floor(root.visibleCount / 2)

            property real angleStep: total > 0 ? (2 * Math.PI / total) : 0
            property real baseAngle: root.degToRad(root.selectedAngleDegrees)
            property real angle: baseAngle + relativeIndex * angleStep

            width: root.baseItemSize
            height: root.baseItemSize

            property real funWigglesX: 0
            property real funWigglesY: 0
            property real funWigglesRotation: Math.random() * 10 - 5

            x: root.centerX + Math.cos(angle) * root.radius - width / 2 + funWigglesX
            y: root.centerY + Math.sin(angle) * root.radius - height / 2 + funWigglesY
            rotation: funWigglesRotation

            scale: selected ? root.selectedScale : root.unselectedScale
            opacity: selected ? root.selectedOpacity : root.unselectedOpacity
            visible: withinVisibleRange
            z: selected ? 1000 : (1000 - Math.abs(relativeIndex))

            Behavior on scale {
                SmoothedAnimation {
                    velocity: 6
                    maximumEasingTime: 100
                }
            }

            Behavior on opacity {
                SmoothedAnimation {
                    velocity: 6
                    maximumEasingTime: 100
                }
            }

            

            Rectangle {
                anchors.fill: parent
                radius: width * 0.12
                color: selected ? '#000000' : '#000000'
                // border.width: selected ? Math.max(2, root.width * 0.0015) : 0
                // border.color: "white"
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#cc000000"
                    radius: 20
                    samples: 33
                }
            }

            Image {
                id: gameImg
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                smooth: false
                asynchronous: true
                source: root.gameImage(modelData)
                visible: false
                
            }

            OpacityMask {
                anchors.fill: gameImg
                source: gameImg
                maskSource: Rectangle {
                    width: gameImg.width
                    height: gameImg.height
                    radius: gameImg.width * 0.12
                }
            }

            

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.setCurrentIndex(index);
                }

                onDoubleClicked: {
                    root.setCurrentIndex(index);
                    root.activateCurrentGame();
                }
            }

            property real wiggleAmount: 10
            property real wiggleAmountRotation: 2.5
            SequentialAnimation on funWigglesX {
                id: xWiggle
                loops: Animation.Infinite
                running: true

                NumberAnimation {
                    to: wiggleAmount
                    duration: 5400
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: -wiggleAmount
                    duration: 6400
                    easing.type: Easing.InOutSine
                }
            }

            SequentialAnimation on funWigglesY {
                loops: Animation.Infinite
                running: true

                NumberAnimation {
                    to: wiggleAmount
                    duration: 5600
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: -wiggleAmount
                    duration: 6000
                    easing.type: Easing.InOutSine
                }
            }

            SequentialAnimation on funWigglesRotation {
                id: rotationWiggle
                loops: Animation.Infinite
                running: true

                NumberAnimation {
                    to: wiggleAmountRotation
                    duration: 4000
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: -wiggleAmountRotation
                    duration: 4000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}