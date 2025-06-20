extends Control

var Room = preload("res://Room.gd")
var WindowHelper = preload("res://WindowHelper.gd").new()
var SceneFadeHelper = preload("res://SceneFadeHelper.gd").new()

#var glossaryScene = preload("res://Glossary.tscn").instantiate()
#var dungeonScene = preload("res://Generation Logic.tscn").instantiate()
var visualizerScene = preload("res://DungeonVisualizer.tscn").instantiate()
#var mapScene = preload("res://InteractiveMap.tscn").instantiate()
#var abacusScene = preload("res://Abacus.tscn").instantiate()
#var masterScene = preload("res://Master.tscn").instantiate()
var miniMapScenes = []

var viewportSize
var midPointX
var midPointY

var midPointX2
var midPointY2

var offset = 128

# Called when the node enters the scene tree for the first time.
func _ready():
	
	SceneFadeHelper.fade_in(self, 3)
	
	StoredElements.setWindowManager(self)
	
	viewportSize = get_viewport_rect().size
	midPointY = viewportSize.y / 2
	midPointX = (viewportSize.x - 300) / 2
	
	@warning_ignore("integer_division")
	midPointX2 = 1120 / 2
	@warning_ignore("integer_division")
	midPointY2 = 720 / 2

	openVisualizerWindow()

func _input(event):
	WindowHelper.allowCheatInputs(event)

func createWindow(title, size, borderless, scene, pos, show, alwaysOnTop):
	var new_window = Window.new()
	new_window.title = title
	new_window.mode = Window.MODE_WINDOWED
	new_window.size = size
	new_window.unresizable = true
	new_window.borderless = borderless
	new_window.close_requested.connect(func():new_window.queue_free())
	new_window.add_child(scene)
	get_tree().root.add_child.call_deferred(new_window)
	new_window.position = pos
	
	if(show):
		new_window.show()
	else:
		new_window.hide()
		
	if(alwaysOnTop):
		new_window.always_on_top = true
		
	return new_window

#func openGlossary():
#	createWindow("GLOSSARY", Vector2i(791, 1024), true, glossaryScene, Vector2i(16, 64), true, true)
	

func openVisualizerWindow():
	createWindow("CHEATY VISUALIZER", Vector2i(400, 500), false, visualizerScene, Vector2i(midPointX, midPointY), false, true)


func openMapWindow(newMap):
	var miniMapScene = preload("res://InteractiveMap.tscn").instantiate()
	var new_window = Window.new()  # Create a new window
	new_window.title = "MINI MAP"
	new_window.mode = Window.MODE_WINDOWED

	new_window.size = Vector2i(650, 600)  # Set window size
	new_window.borderless = false
	new_window.always_on_top = true
	new_window.unresizable = true

	new_window.add_child(miniMapScene)
	miniMapScenes.append(miniMapScene)
	new_window.close_requested.connect(func():new_window.queue_free())
	
	new_window.process_mode = Node.PROCESS_MODE_ALWAYS  # Ensure it receives input even when unfocused
	new_window.set_process_unhandled_input(true)
	
	get_tree().root.add_child.call_deferred(new_window)  # Attach to the root so it renders
	
	var positionX = 420
	var positionY = viewportSize.y - 320 - 400
	
	positionY += midPointY2 - midPointY
	positionX += midPointX - midPointX2
	
	new_window.position = Vector2i(positionX, positionY)  # Set position on screen
	new_window.show()



func openSeverenceWindows():
	await get_tree().process_frame
	if(StoredElements.enableCheats) and (StoredDungeon.getDungeonVisualizer() != null):
		visualizerScene.get_parent().show()
	
func closeSeverenceWindows():
	if(StoredDungeon.getDungeonVisualizer() != null):
		visualizerScene.get_parent().hide()
	for entry in miniMapScenes:
		if(entry != null):
			entry.get_parent().queue_free()
	miniMapScenes = []
