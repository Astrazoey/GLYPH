extends Button

var SaveGameHelper = preload("res://SaveGameHelper.gd").new()
var SceneFadeHelper = preload("res://SceneFadeHelper.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame # make sure all save data is handled first
	connect("pressed", continueLastSave.bind())
	
	if(SaveGameHelper.getLastSaveSlot() < 0):
		disabled = true
	else:
		disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func continueLastSave():
	var lastSave = SaveGameHelper.getLastSaveSlot()
	if(lastSave > -1):
		var outputVariables = {}
		SaveGameHelper.loadGame(lastSave)
		SceneFadeHelper.fadeScene(self, AudioManager.get_node("Sounds/GameStart"), "res://MenuUI/setup_menu.tscn", 1)
		disabled = true
	else:
		disabled = true
