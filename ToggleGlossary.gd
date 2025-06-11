extends TextureButton

var viewportSize

var midPointY
var midPointY2
var midPointX
var midPointX2


# Called when the node enters the scene tree for the first time.
func _ready():
	viewportSize = get_viewport_rect().size
	midPointY = viewportSize.y / 2
	midPointX = (viewportSize.x - 300) / 2
	
	midPointX2 = 1120 / 2
	midPointY2 = 720 / 2
	
	self.scale = Vector2(1, 1)
	self.position = Vector2(96, get_viewport_rect().size.y - self.size.y - 32)
	self.connect("pressed", toggleGlossary.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func toggleGlossary():
	
	get_node("AudioClick").play()
	
	if get_child_count() > 2:
		for window in get_children():
			if window is Window:
				window.queue_free()
	else:
		var new_window = Window.new()  # Create a new window
		new_window.title = "GLOSSARY"
		new_window.mode = Window.MODE_WINDOWED
		new_window.size = Vector2i(720, 820)  # Set window size
		new_window.unresizable = true
		new_window.borderless = false
		new_window.always_on_top = true
		new_window.close_requested.connect(func():new_window.queue_free())
		new_window.add_child(preload("res://Glossary.tscn").instantiate())
		add_child.call_deferred(new_window)  # Attach to the root so it renders
		
		var positionX = 400
		var positionY = viewportSize.y - 360 - 400
		
		positionY += midPointY2 - midPointY
		positionX += midPointX - midPointX2
		
		new_window.position = Vector2i(positionX, positionY)
		new_window.show()  # Show the window		
		
		#StoredElements.windowManager.createWindow("GLOSSARY", Vector2i(720, 720), false, preload("res://Glossary.tscn").instantiate(), Vector2i(positionX, positionY), true, true)
		#window.close_requested.connect(func():window.queue_free())
