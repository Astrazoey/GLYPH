extends Button


# Options Button
func _ready():
	connect("pressed", openOptionsMenu.bind())

func openOptionsMenu():
	for child in get_parent().get_children():
		child.queue_free()
	
	get_parent().get_parent().add_child(load("res://MenuUI/options_buttons.tscn").instantiate())
	get_parent().queue_free()

	AudioManager.get_node("Sounds/ButtonClick").play()
