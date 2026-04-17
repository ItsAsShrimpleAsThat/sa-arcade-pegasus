import QtQuick 2.0
import QtMultimedia 5.9
import "components"

FocusScope {
	id: root
	
	FontLoader { id: regular; source: "assets/fonts/NotoSans-Regular.ttf" }
	FontLoader { id: bold; source: "assets/fonts/NotoSans-Bold.ttf" }

	property real circleDistanceFromCorner: 0.5
	property int maxColumnGame: 4
	property int gridItemRadius: 6
	property int slideDownHeight: 200

	readonly property var settings: {
		return {
			fullScreen:			api.memory.has("fullScreen") ? api.memory.get("fullScreen") : "no",
			homeCollection:		api.memory.has("homeCollection") ? api.memory.get("homeCollection") : "",

			sounds:				api.memory.has("sounds") ? api.memory.get("sounds") : "yes",
			showClock:			api.memory.has("showClock") ? api.memory.get("showClock") : "yes",
			showBattery:		api.memory.has("showBattery") ? api.memory.get("showBattery") : "yes",
			showGameCount:		api.memory.has("showGameCount") ? api.memory.get("showGameCount") : "yes",
			showStatusBar:		api.memory.has("showStatusBar") ? api.memory.get("showStatusBar") : "yes",
			backgroundImage:	api.memory.has("backgroundImage") ? api.memory.get("backgroundImage") : "yes",
			opaquePanel:		api.memory.has("opaquePanel") ? api.memory.get("opaquePanel") : "yes",
			colorScheme:		api.memory.has("colorScheme") ? api.memory.get("colorScheme") : "Gray"
		}
	}

	readonly property var colorSchemes: ["Gray", "Steel", "Graphite", "Fly", "Oliva", "Violet"]
	readonly property var theme: {
		var panels = "";
		var highlight = "";
		var background = "";

		if (settings.colorScheme === "Gray") {
			panels = "#4a4a4a";
			highlight = "#437fc4";
			background = "#363636";
		}
		else if (settings.colorScheme === "Steel") {
			panels = "#5c6c7f";
			highlight = "#b5a27d";
			background = "#444f5c";
		}
		else if (settings.colorScheme === "Graphite") {
			panels = "#363d4b";
			highlight = "#7da3ca";
			background = "#20262d";
		}

		else if (settings.colorScheme === "Fly") {
			panels = "#466870";
			highlight = "#d35b5b";
			background = "#244454";
		}

		else if (settings.colorScheme === "Oliva") {
			panels = "#414f56";
			highlight = "#a0b684";
			background = "#20292a";
		}

		else if (settings.colorScheme === "Violet") {
			panels = "#222738";
			highlight = "#9072ed";
			background = "#151823";
		}

		return {
			panels: panels,
			highlight: highlight,
			background: background
		}
	}
	
	Image {
		id: hello
		source: "assets/images/test.png"
		anchors.fill: parent
		fillMode: Image.PreserveAspectFit
	}

	Image {
		id: vignette
		source: "assets/images/vignette.png"
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
	}
	Text {
		text: "Hello World"
		color: "white"
	}
	RadialGameMenu{
		id: radialMenu
        anchors.fill: parent
        model: api.collections.get(0).games
        currentIndex: api.memory.get("radialIndex") || 0
        visibleCount: 9

		selectedAngleDegrees: 45	

        // Move circle center
        centerXRatio: 0
        centerYRatio: 0

        radiusRatio: 0.75
		selectedScale: 1
		unselectedScale: 0.5
		baseItemSizeRatio: 0.25

        // Opacity tuning
        selectedOpacity: 1.0
        unselectedOpacity: 0.42
		wheelVelocity: 6
		wheelMaxEasingTime: 100

        onCurrentIndexChangedByUser: function(index) {
            api.memory.set("radialIndex", index)
        }

        onGameActivated: function(game) {
            api.memory.set("radialIndex", currentIndex)
        }
	}
}