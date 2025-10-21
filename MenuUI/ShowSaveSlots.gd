extends VBoxContainer

@export var saveSlotCount = 3
var SaveGameHelper = preload("res://SaveGameHelper.gd").new()
var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()
var SceneFadeHelper = preload("res://SceneFadeHelper.gd").new()


func _ready():
	
	await get_tree().process_frame # make sure all save data is handled first
	
	for i in saveSlotCount:
		var path = "user://save_slot_%d.save" % i
		var saveSlot = Button.new()
		saveSlot.custom_minimum_size = Vector2(0, 64)
		saveSlot.theme = load("res://Themes/menu_button_theme.tres")
		if not FileAccess.file_exists(path):
			saveSlot.text = "New Save %d" % (i+1)
			saveSlot.connect("pressed", manageSave.bind(i, true))
		else:
			var metadata = SaveGameHelper.loadAllSlotMetadata()
			if str(i) in metadata:
				saveSlot.text = "Load Slot %d | Artifacts: %d" % [(i+1), metadata.get(str(i), {}).get("artifactCount", 0)]
			else:
				saveSlot.text = "Load Slot %d" % [(i+1)]
			saveSlot.connect("pressed", manageSave.bind(i, false))
		add_child(saveSlot)

func manageSave(slot, isNew):
	var outputVariables = {}
	
	if(isNew):
		SaveGameHelper.startDefaultSave(slot)
	else:
		SaveGameHelper.loadGame(slot)
	
	#print(StoredElements.saveSlot)
	SceneFadeHelper.fadeScene(self, AudioManager.get_node("Sounds/GameStart"), "res://MenuUI/setup_menu.tscn", 1)
