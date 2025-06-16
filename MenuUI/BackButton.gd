extends Button

var SaveGameHelper = preload("res://SaveGameHelper.gd").new()

# Options Button
func _ready():
	connect("pressed", openMainMenu.bind())

func openMainMenu():
	var sceneRoot = get_tree().current_scene
	
	for child in sceneRoot.get_children():
		child.queue_free()
	
	sceneRoot.add_child(load("res://MenuUI/main_menu.tscn").instantiate())
	AudioManager.get_node("Sounds/ButtonClick").play()
	print("Saving game at slot", StoredElements.saveSlot)
	SaveGameHelper.saveGame(StoredElements.saveData, StoredElements.saveSlot)
