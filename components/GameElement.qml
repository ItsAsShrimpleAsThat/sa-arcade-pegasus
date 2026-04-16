import QtQuick 2.15

FocusScope {
    id: root
    width: 1920
    height: 1080
    focus: true

    // Pick your collection here
    property int currentCollectionIndex: 0
    property var currentCollection: api.collections.get(currentCollectionIndex)
    property var gamesModel: currentCollection.games

    property int currentIndex: 0

    // Radial layout settings
    property real radius: 320
    property real itemSize: 170
    property real selectedScale: 1.25
    property real centerX: width / 2
    property real centerY: height / 2

    // Optional: remember last selected game
    Component.onCompleted: {
        currentIndex = api.memory.get("radialGameIndex") || 0
    }

    function saveIndex() {
        api.memory.set("radialGameIndex", currentIndex)
    }

    function wrapIndex(i) {
        var count = gamesModel.count
        if (count <= 0)
            return 0
        return (i % count + count) % count
    }

    function nextGame() {
        currentIndex = wrapIndex(currentIndex + 1)
        saveIndex()
    }

    function previousGame() {
        currentIndex = wrapIndex(currentIndex - 1)
        saveIndex()
    }

    function launchCurrentGame() {
        if (gamesModel.count > 0)
            gamesModel.get(currentIndex).launch()
    }

    // Simple 4-direction input version
    Keys.onPressed: {
        if (event.isAutoRepeat)
            return

        if (api.keys.isAccept(event)) {
            event.accepted = true
            launchCurrentGame()
            return
        }

        // Right/up = clockwise
        if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            event.accepted = true
            nextGame()
            return
        }

        // Left/down = counterclockwise
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
            event.accepted = true
            previousGame()
            return
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#101014"
    }

    // Center info
    Item {
        anchors.centerIn: parent
        width: 500
        height: 500

        Rectangle {
            anchors.centerIn: parent
            width: 220
            height: 220
            radius: 20
            color: "#1b1b22"
            border.width: 3
            border.color: "white"
        }

        Image {
            anchors.centerIn: parent
            width: 180
            height: 180
            fillMode: Image.PreserveAspectFit

            source: {
                if (gamesModel.count <= 0)
                    return ""
                var game = gamesModel.get(currentIndex)
                return game.assets.logo || game.assets.boxFront || game.assets.tile || game.assets.poster
            }
        }
    }

    Repeater {
        model: gamesModel

        delegate: Item {
            property int indexInModel: index
            property int count: gamesModel.count

            // Put selected game at top, others arranged around it
            property real step: (2 * Math.PI) / Math.max(count, 1)
            property real angle: -Math.PI / 2 + (indexInModel - root.currentIndex) * step

            property bool selected: indexInModel === root.currentIndex
            property real iconScale: selected ? root.selectedScale : 1.0

            width: root.itemSize
            height: root.itemSize

            x: root.centerX + Math.cos(angle) * root.radius - width / 2
            y: root.centerY + Math.sin(angle) * root.radius - height / 2

            scale: iconScale
            z: selected ? 10 : 1
            opacity: selected ? 1.0 : 0.72

            Behavior on x { NumberAnimation { duration: 180 } }
            Behavior on y { NumberAnimation { duration: 180 } }
            Behavior on scale { NumberAnimation { duration: 180 } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: selected ? "#2a2a38" : "#181820"
                border.width: selected ? 4 : 0
                border.color: "white"
            }

            Image {
                anchors.fill: parent
                anchors.margins: 12
                fillMode: Image.PreserveAspectFit
                source: modelData.assets.boxFront
                        || modelData.assets.logo
                        || modelData.assets.tile
                        || modelData.assets.poster
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.currentIndex = indexInModel
                onDoubleClicked: modelData.launch()
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            font.pixelSize: 34
            text: gamesModel.count > 0 ? gamesModel.get(root.currentIndex).title : ""
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#b8b8c8"
            font.pixelSize: 22
            text: gamesModel.count > 0 ? (gamesModel.get(root.currentIndex).developer || "") : ""
        }
    }
}