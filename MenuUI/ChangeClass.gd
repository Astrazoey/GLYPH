extends Button

@export var newClassId = 0
@export var classKey = "NONE"

@onready var classContainer = $"../../../../../../MarginContainer2/PanelContainer/TextureRect/MarginContainer/ClassInformationContainer"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", changeClass.bind())

	if(classKey in StoredElements.classUnlocks):
		if(StoredElements.classUnlocks[classKey]):
			pass
		else:
			disabled = true
			text = "[LOCKED]"
	else:
		disabled = true
		text = "Class Missing"


func changeClass():
	StoredElements.classId = newClassId
	AudioManager.get_node("Sounds/ButtonClick").play()
	classContainer.updateClassDisplay()
