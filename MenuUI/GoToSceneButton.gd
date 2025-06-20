extends Button

@export var audio = "Sounds/ButtonClick"
@export var scenePath = "res://MenuUI/main_menu.tscn"
@export var fade = false

var SceneFadeHelper = preload("res://SceneFadeHelper.gd").new()

# Options Button
func _ready():
	connect("pressed", openScene.bind())
	pass
	
func openScene():
	var sceneRoot = get_tree().current_scene
	
	
	
	if(fade):
		AudioManager.get_node("Sounds/GameStart").play()
		SceneFadeHelper.fadeScene(self, null, scenePath, 1)
	else:
		for child in sceneRoot.get_children():
			child.queue_free()
		sceneRoot.add_child(load(scenePath).instantiate())
		AudioManager.get_node(audio).play()
