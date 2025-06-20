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
	if(StoredElements.enableCheats == false):
		return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		StoredElements.windowManager.openMasterWindow()
		
	if(StoredElements.player != null):
		if event is InputEventKey and event.pressed and event.keycode == KEY_R:
			StoredElements.player.movePlayerToRoom(Room.RoomType.EXIT)
			StoredElements.player.redrawEverything()
				
		if event is InputEventKey and event.pressed and event.keycode == KEY_T:
			StoredElements.player.startGame()

func createWindow(title, size, borderless, scene, pos, show, alwaysOnTop, container):
	var new_window = Window.new()
	new_window.title = title
	new_window.mode = Window.MODE_WINDOWED
	new_window.size = size
	new_window.unresizable = true
	new_window.borderless = borderless
	new_window.close_requested.connect(func():new_window.queue_free())
	new_window.add_child(scene)
	container.get_tree().root.add_child.call_deferred(new_window)
	new_window.position = pos
	
	if(show):
		new_window.show()
	else:
		new_window.hide()
		
	if(alwaysOnTop):
		new_window.always_on_top = true
		
	return new_window
