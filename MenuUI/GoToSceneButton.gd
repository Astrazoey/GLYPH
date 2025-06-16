extends Button

@export var audio = "Sounds/ButtonClick"
@export var scenePath = "res://MenuUI/main_menu.tscn"

# Options Button
func _ready():
	connect("pressed", openScene.bind())
	pass
	
func openScene():
	var sceneRoot = get_tree().current_scene
	
	for child in sceneRoot.get_children():
		child.queue_free()
	
	sceneRoot.add_child(load(scenePath).instantiate())
	AudioManager.get_node(audio).play()
