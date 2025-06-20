extends Button

@export var difficulty = 0
@export var difficultyKey = "NONE"

@onready var locationInfoBox = $"../../../../../../../MarginContainer2/LocationBox"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", changeLocation.bind())
	if(StoredElements.difficulty == difficulty):
		button_pressed = true
		
	if(difficultyKey in StoredElements.difficulties):
		if(StoredElements.difficulties[difficultyKey]):
			pass
		else:
			disabled = true
			text = "[LOCKED]"
	else:
		disabled = true
		text = "Location Missing"


func changeLocation():
	StoredElements.difficulty = difficulty
	AudioManager.get_node("Sounds/ButtonClick").play()
	locationInfoBox.updateLocationInfo()
