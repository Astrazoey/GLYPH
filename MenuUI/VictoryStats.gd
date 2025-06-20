extends VBoxContainer

@onready var artifactIcon = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ArtifactIcon
@onready var unlocksLabel = $PanelContainer/MarginContainer/VBoxContainer/UnlocksLabel
@onready var goldLabel = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/GoldAmount

var emptySlotTexture = preload("res://TemporaryIcons/empty_slot.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	goldLabel.text = str(StoredElements.winGold)
	
	var unlocksText = ""
	match StoredElements.highestDifficultyWinCount:
		3:
			unlocksText += "UNLOCKED LOCATION: MILL"
			unlocksText += "\n"
			unlocksText += "UNLOCKED CLASS: APPRAISER"
		6:
			unlocksText += "UNLOCKED LOCATION: GORGE"
			unlocksText += "\n"
			unlocksText += "UNLOCKED CLASS: SCOUT"
			unlocksText += "\n"
			unlocksText += "UNLOCKED NEW WEAPON SLOT"
		10:
			unlocksText += "UNLOCKED LOCATION: VALLEY"
			unlocksText += "\n"
			unlocksText += "UNLOCKED NEW WEAPON SLOT"
			unlocksText += "\n"
			unlocksText += "UNLOCKED WAGERING"
		15:
			unlocksText += "UNLOCKED LOCATION: CAVERNS"
			unlocksText += "\n"
			unlocksText += "UNLOCKED CLASS: TRAPPER"
		20:
			unlocksText += "UNLOCKED LOCATION: CRATER"
			unlocksText += "\n"
			unlocksText += "UNLOCKED CLASS: SERFS"
			unlocksText += "\n"
			unlocksText += "UNLOCKED NEW WEAPON SLOT"
			unlocksText += "\n"
			unlocksText += "INCREASED MAXIMUM WAGER"
		30:
			unlocksText += "UNLOCKED LOCATION: COLLAPSED CANYON"
			unlocksText += "\n"
			unlocksText += "UNLOCKED CLASS: FUGITIVE"
			unlocksText += "\n"
			unlocksText += "UNLOCKED NEW WEAPON SLOT"
	
	unlocksLabel.text = unlocksText
	
	if(StoredElements.winArtifact):
		pass
	else:
		artifactIcon.texture = emptySlotTexture
