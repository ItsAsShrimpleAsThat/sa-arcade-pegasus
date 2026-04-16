import QtQuick 2.15

FocusScope {
    id: root

    focus: true

    // Public API
    property var model: null
    property int currentIndex: 0

    property real radius: 260
    property real itemSize: 150
    property real selectedScale: 1.2
    property int visibleCount: -1   // -1 = show all

    property bool launchOnAccept: true
    property bool useLogoFirst: true

    signal currentIndexChangedByUser(int index)
    signal gameActivated(var game)

    function modelCount() {
        return model ? model.count : 0
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
        currentIndex = wrapIndex(i);
    }

    function nextGame() {
        if (modelCount() <= 0)
            return;
        currentIndex = wrapIndex(currentIndex + 1);
        currentIndexChangedByUser(currentIndex);
    }

    function previousGame() {
        if (modelCount() <= 0)
            return;
        currentIndex = wrapIndex(currentIndex - 1);
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

    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            activateCurrentGame();
            return;
        }

        // Up/right = clockwise
        if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            event.accepted = true;
            nextGame();
            return;
        }

        // Down/left = counterclockwise
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
            property int relativeIndex: root.shortestSignedDistance(root.currentIndex, index, total)
            property bool selected: index === root.currentIndex
            property bool withinVisibleRange: root.visibleCount < 0
                                              || Math.abs(relativeIndex) <= Math.floor(root.visibleCount / 2)

            property real angleStep: total > 0 ? (2 * Math.PI / total) : 0
            property real angle: -Math.PI / 2 + relativeIndex * angleStep

            width: root.itemSize
            height: root.itemSize

            x: root.width / 2 + Math.cos(angle) * root.radius - width / 2
            y: root.height / 2 + Math.sin(angle) * root.radius - height / 2

            scale: selected ? root.selectedScale : 1.0
            opacity: withinVisibleRange ? (selected ? 1.0 : 0.7) : 0.0
            visible: withinVisibleRange
            z: selected ? 100 : (100 - Math.abs(relativeIndex))

            Behavior on x { NumberAnimation { duration: 180 } }
            Behavior on y { NumberAnimation { duration: 180 } }
            Behavior on scale { NumberAnimation { duration: 180 } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: selected ? "#2b2f3a" : "#171a22"
                border.width: selected ? 3 : 0
                border.color: "white"
            }

            Image {
                anchors.fill: parent
                anchors.margins: 10
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
                source: root.gameImage(modelData)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.setCurrentIndex(index)
                onDoubleClicked: {
                    root.setCurrentIndex(index)
                    root.activateCurrentGame()
                }
            }
        }
    }
}