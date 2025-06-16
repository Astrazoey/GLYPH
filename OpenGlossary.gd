extends Button

var WindowHelper = preload("res://WindowHelper.gd").new()
var window

var glossaryOpen = false

@export_file("*.json") var glossaryFile: String = "res://GlossaryBook/glyph_glossary.json"
@export var glossaryName = "GLOSSARY"
@export var glossarySize = Vector2i(720, 820)

var glossaryScene = preload("res://Glossary.tscn")
var glossaryInstance = glossaryScene.instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", toggleGlossary.bind())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func toggleGlossary():
	if(window == null):
		window = WindowHelper.createWindow(glossaryName, glossarySize, false, load("res://Glossary.tscn").instantiate(), Vector2i(200, 32), true, true, self)
		glossaryOpen = true
		window.get_child(0, false).glossaryFile = glossaryFile
	else:
		if(glossaryOpen):
			window.hide()
			glossaryOpen = false
		else:
			window.show()
			glossaryOpen = true
