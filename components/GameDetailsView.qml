import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // --- Dynamic Data Properties ---
    property string text: "Extend Winter"
    property string dateText: "2026"
    
    property int targetYear: parseInt(dateText) || 2026
    property int displayYear: targetYear
    Behavior on displayYear {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutCubic
        }
    }
    
    property var words: text.split(" ").filter(function(w) { return w.length > 0; })
    
    property var authors: ["Alec Singer '26", "Andrew Long '27", "Grant Sanders '28"]
    property string descriptionText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
    property var tags: ["Arcade", "Groundhog (Hedgehog)", "Singleplayer"]

    // --- Styling & Theming ---
    property color textColor: "black"
    property color mainLineColor: "#094020"
    property color accentLineColor: "#A4A4A4"
    property color dateColor: "#c28710"
    property string titleFamily: ""
    property string descriptionFamily: ""
    
    property int fontSize: 110
    property int dateFontSize: 120
    property int creditsFontSize: 24
    property int descriptionFontSize: 20
    
    property int lineSpacing: 12
    property int lineThickness: 22
    property int interWordSpacing: 20

    // Automatically construct formatted rich-text credits
    property string creditsText: {
        var str = "<b>By:</b> ";
        if (!root.authors) return "";
        for (var i = 0; i < root.authors.length; i++) {
            var c = String((i % 2 === 0) ? root.mainLineColor : root.dateColor); 
            str += "<font color='" + c + "'>" + root.authors[i] + "</font>";
            if (i < root.authors.length - 1) str += ", ";
        }
        return str;
    }

    Item {
        id: layoutContent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 40
        anchors.bottomMargin: 40
        anchors.rightMargin: -50
        anchors.leftMargin: 130
        width: 650
        anchors.right: parent.right

        Text {
            id: date
            text: isNaN(parseInt(root.dateText)) ? root.dateText : root.displayYear.toString()
            color: root.dateColor
            font.family: root.titleFamily
            font.weight: Font.Black
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: root.dateFontSize
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: date.bottom
            anchors.topMargin: -20
            spacing: -20

            Repeater {
                model: root.words.length
                RowLayout {
                    id: rowItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: root.interWordSpacing
                    layoutDirection: index % 2 === 0 ? Qt.LeftToRight : Qt.RightToLeft
                    property int wordIndex: index

                    Text {
                        id: wordText
                        text: root.words[wordIndex]
                        color: root.textColor
                        font.family: root.titleFamily
                        font.weight: Font.Black
                        font.pixelSize: root.fontSize
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        verticalAlignment: Text.AlignVCenter
                        Layout.maximumWidth: parent.width * 0.85
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        id: linesWrapper
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        height: 0
                        Column {
                            id: lineColumn
                            width: parent.width
                            spacing: root.lineSpacing
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                width: parent.width * (index % 2 === 0 ? 1.0 : 0.70)
                                height: root.lineThickness
                                radius: root.lineThickness / 2
                                color: root.accentLineColor
                                anchors.right: index % 2 !== 0 ? parent.right : undefined
                            }
                            Rectangle {
                                width: parent.width * 0.85
                                height: root.lineThickness
                                radius: root.lineThickness / 2
                                color: root.mainLineColor
                                anchors.right: index % 2 !== 0 ? parent.right : undefined
                            }
                            Rectangle {
                                width: parent.width * (index % 2 === 0 ? 0.70 : 1.0)
                                height: root.lineThickness
                                radius: root.lineThickness / 2
                                color: root.accentLineColor
                                anchors.right: index % 2 !== 0 ? parent.right : undefined
                            }
                        }
                    }
                }
            }
        }

        Text {
            id: credits
            text: root.creditsText
            font.family: root.titleFamily
            font.weight: Font.Black
            textFormat: Text.StyledText
            anchors.top: contentColumn.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: root.creditsFontSize
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            id: playButton
            width: Math.min(380, parent.width)
            height: 100
            radius: 50
            color: root.dateColor
            border.color: root.mainLineColor
            border.width: 10
            anchors.bottom: parent.bottom // Pin directly to the bottom
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                anchors.centerIn: parent
                text: "Play"
                color: "white"
                font.family: root.descriptionFamily
                font.pixelSize: 60
                font.weight: Font.Black
            }
        }

        Flickable {
            id: descriptionFlickable
            anchors.top: credits.bottom
            anchors.topMargin: 30
            anchors.bottom: playButton.top
            anchors.bottomMargin: 30
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            
            contentWidth: width
            contentHeight: description.height
            clip: true
            
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            Text {
                id: description
                width: parent.width
                text: root.descriptionText
                font.family: root.descriptionFamily
                font.pixelSize: root.descriptionFontSize
                font.weight: Font.Medium
                color: "black"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
            }
        }
    }
    
    // Natively repeating scrolling tag loop, locked exactly to the right of the details block
    Item {
        id: tagsContainer
        anchors.right: layoutContent.left
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 44
        clip: true

        // If the array is an odd length, repeating it once perfectly satisfies alternating logic natively
        property var cycleTags: root.tags.length > 0 && root.tags.length % 2 !== 0 ? root.tags.concat(root.tags) : root.tags
        
        Item {
            id: scrollTarget
            width: parent.width
            
            Column {
                id: masterColumn
                spacing: 20
                width: parent.width
                
                // Core block used for sizing precisely
                Column {
                    id: cycleBlock
                    spacing: 20
                    width: parent.width
                    Repeater {
                        model: tagsContainer.cycleTags
                        Rectangle {
                            width: 44
                            height: Math.max(80, tagText.implicitWidth + 40)
                            radius: 22
                            color: "white"
                            border.color: index % 2 === 0 ? root.mainLineColor : root.dateColor
                            border.width: 5
                            Text {
                                id: tagText
                                anchors.centerIn: parent
                                rotation: -90
                                text: modelData
                                color: "black"
                                font.family: root.descriptionFamily
                                font.weight: Font.Black
                                font.pixelSize: 18
                            }
                        }
                    }
                }

                // Cloned repeating tail seamlessly trails the front exactly
                Repeater {
                    model: 100 * tagsContainer.cycleTags.length
                    delegate: Rectangle {
                        property int tagIndex: index % tagsContainer.cycleTags.length
                        width: 44
                        // Use repTagText as reference to avoid any overlap
                        height: Math.max(80, repTagText.implicitWidth + 40)
                        radius: 22
                        color: "white"
                        // Since cycleTags always has an EVEN length now, `index % 2` perfectly alternates strictly forever
                        border.color: index % 2 === 0 ? root.mainLineColor : root.dateColor
                        border.width: 5
                        Text {
                            id: repTagText
                            anchors.centerIn: parent
                            rotation: -90
                            text: tagsContainer.cycleTags[parent.tagIndex]
                            color: "black"
                            font.family: root.descriptionFamily
                            font.weight: Font.Black
                            font.pixelSize: 18
                        }
                    }
                }
            }

            // --- Normal idle scroll ---
            PropertyAnimation {
                id: scrollAnim
                target: scrollTarget
                property: "y"
                loops: Animation.Infinite
                running: false
                easing.type: Easing.Linear
            }

            // --- Phase 2: fast entry — rockets new tags in from bottom right behind old ones ---
            PropertyAnimation {
                id: entryAnim
                target: scrollTarget
                property: "y"
                easing.type: Easing.OutCubic
                duration: 220
                running: false
                onStopped: {
                    // Hand off to idle scroll, continuing from where entry landed (y=0)
                    var h = cycleBlock.height + 20;
                    if (h <= 20) h = 300;
                    scrollAnim.from = 0;
                    scrollAnim.to = -h;
                    scrollAnim.duration = Math.max(1000, h * 15);
                    scrollAnim.restart();
                }
            }

            // --- Phase 1: burst flush — blasts old tags upward fast ---
            PropertyAnimation {
                id: flushAnim
                target: scrollTarget
                property: "y"
                easing.type: Easing.InCubic
                duration: 220
                running: false
                onStopped: {
                    // Immediately place new tags just below visible area
                    scrollTarget.y = tagsContainer.height;
                    // Fire entry animation — rockets them up to y=0 at the same speed as the flush
                    entryAnim.from = tagsContainer.height;
                    entryAnim.to = 0;
                    entryAnim.start();
                }
            }

            // Start idle scroll on load
            Timer {
                interval: 50
                running: true
                onTriggered: {
                    var h = cycleBlock.height + 20;
                    if (h <= 20) h = 300;
                    scrollAnim.from = 0;
                    scrollAnim.to = -h;
                    scrollAnim.duration = Math.max(1000, h * 15);
                    scrollAnim.start();
                }
            }

            // Watch for tags changing — trigger the push-out burst
            Connections {
                target: root
                function onTagsChanged() {
                    scrollAnim.stop();
                    entryAnim.stop();
                    // Blast current position upward off the top at full speed
                    flushAnim.from = scrollTarget.y;
                    flushAnim.to = -(cycleBlock.height + tagsContainer.height);
                    flushAnim.start();
                }
            }
        }
    }
}
