extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
	self.scale = Vector2(1, 1)
	self.position = Vector2(32, get_viewport_rect().size.y - self.size.y - 32)
	self.connect("pressed", openMapWindow.bind())


func openMapWindow():
	
	StoredDungeon.removeNullBoards()
	
	if(StoredDungeon.dungeonMapNodes.size() < 6):
		get_parent().openMapWindow(true)
	else:
		show_popup_message("Ahhhhh :(", "Too many maps generated!")
	return

func show_popup_message(title: String, message: String):
	var popup = AcceptDialog.new()
	popup.title = title
	popup.dialog_text = message
	popup.size = Vector2(300, 75)  # Optional: Set size
	get_tree().root.add_child(popup)  # Add to scene tree
	popup.popup_centered()  # Show the popup in the center
