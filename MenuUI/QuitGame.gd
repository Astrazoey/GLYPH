extends Button

var SceneFadeHelper = preload("res://SceneFadeHelper.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", quitGame.bind())


func quitGame():
	AudioManager.get_node("Sounds/ButtonClick").play()
	AudioManager.get_node("Music/MainMenu").fade_out_tween(1.5)
	await SceneFadeHelper.fadeScene(self, null, null, 1)
	get_tree().quit()
