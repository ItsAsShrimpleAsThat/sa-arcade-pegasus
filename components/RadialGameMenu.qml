import QtQuick 2.15

FocusScope {
    id: root
    focus: true

    property var model: null

    property int currentIndex: 0
    property real visualIndex: currentIndex

    property real selectedAngleDegrees: 270

    property real centerXRatio: 0.5
    property real centerYRatio: 0.5

    // 0.5 = circle diameter is half the screen width
    property real radiusRatio: 0.5

    property real baseItemSizeRatio: 0.12
    readonly property real baseItemSize: width * baseItemSizeRatio

    property real selectedScale: 1.0
    property real unselectedScale: 0.72

    property real selectedOpacity: 1.0
    property real unselectedOpacity: 0.45

    property int visibleCount: -1

    property bool launchOnAccept: true
    property bool useLogoFirst: true

    signal currentIndexChangedByUser(int index)
    signal gameActivated(var game)

    readonly property real centerX: width * centerXRatio
    readonly property real centerY: height * centerYRatio
    readonly property real radius: (width * radiusRatio) / 2

    Behavior on visualIndex {
        NumberAnimation {
            duration: 180
            easing.type: Easing.InOutQuad
        }
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
        return (i % count + count) % count;
    }

    function setCurrentIndex(i) {
        var count = modelCount();
        if (count <= 0)
            return;

        var wrapped = wrapIndex(i);
        var diff = shortestSignedDistance(currentIndex, wrapped, count);

        currentIndex = wrapped;
        visualIndex = visualIndex + diff;
    }

    function nextGame() {
        var count = modelCount();
        if (count <= 0)
            return;

        currentIndex = wrapIndex(currentIndex + 1);
        visualIndex = visualIndex + 1;
        currentIndexChangedByUser(currentIndex);
    }

    function previousGame() {
        var count = modelCount();
        if (count <= 0)
            return;

        currentIndex = wrapIndex(currentIndex - 1);
        visualIndex = visualIndex - 1;
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
        var diff = toIndex - fromIndex;
        if (diff > count / 2)
            diff -= count;
        if (diff < -count / 2)
            diff += count;
        return diff;
    }

    function shortestSignedDistanceReal(fromIndex, toIndex, count) {
        if (count <= 0)
            return 0;

        var diff = toIndex - fromIndex;
        diff = ((diff % count) + count) % count;   // wrap to [0, count)

        if (diff >= count / 2)
            diff -= count;                         // shift to [-count/2, count/2)

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
            property int total: root.modelCount()
            property bool selected: index === root.currentIndex

            property real relativeIndex: root.shortestSignedDistanceReal(root.visualIndex, index, total)

            property bool withinVisibleRange: root.visibleCount < 0
                                              || Math.abs(relativeIndex) <= Math.floor(root.visibleCount / 2)

            property real angleStep: total > 0 ? (2 * Math.PI / total) : 0
            property real baseAngle: root.degToRad(root.selectedAngleDegrees)
            property real angle: baseAngle + relativeIndex * angleStep

            width: root.baseItemSize
            height: root.baseItemSize

            x: root.centerX + Math.cos(angle) * root.radius - width / 2
            y: root.centerY + Math.sin(angle) * root.radius - height / 2

            scale: selected ? root.selectedScale : root.unselectedScale
            opacity: selected ? root.selectedOpacity : root.unselectedOpacity
            visible: withinVisibleRange
            z: selected ? 1000 : (1000 - Math.abs(relativeIndex))

            Behavior on scale {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.InOutQuad
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width * 0.12
                color: selected ? "#2b2f3a" : "#171a22"
                border.width: selected ? Math.max(2, root.width * 0.0015) : 0
                border.color: "white"
            }

            Image {
                anchors.fill: parent
                anchors.margins: width * 0.07
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
                source: root.gameImage(modelData)
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
        }
    }
}