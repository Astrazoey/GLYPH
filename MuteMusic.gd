extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("pressed", mute.bind())

func mute():
	AudioManager.get_node("Music/MainMenu").muteToggle()
