extends Node

var Room = preload("res://Room.gd")

func focusOnMouseHover(window):
	window.connect("mouse_entered", _on_mouse_entered.bind(window))
	
func _on_mouse_entered(window):
	window.grab_focus()

func allowMapInput(event):
	if event is InputEventKey:
		StoredDungeon.dungeonMapNode._input(event)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			StoredDungeon.dungeonMapNode._input(event)

func allowCheatInputs(event):
	if(StoredElements.master != null):
		if(StoredElements.master.cheats == false):
			return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		StoredElements.windowManager.openMasterWindow()
		
	if(StoredElements.player != null) and (StoredElements.master.isPlaying):
		if event is InputEventKey and event.pressed and event.keycode == KEY_R:
			StoredElements.player.movePlayerToRoom(Room.RoomType.EXIT)
			StoredElements.player.redrawEverything()
			
		if event is InputEventKey and event.pressed and event.keycode == KEY_T:
			StoredElements.master.startGame()
