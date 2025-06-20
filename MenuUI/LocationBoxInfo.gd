extends VBoxContainer

@onready var difficultyDisplay = $PanelContainer/MarginContainer/VBoxContainer/DifficultyDisplay
@onready var roomIcons = $PanelContainer/MarginContainer/VBoxContainer/RoomIcons
@onready var locationName = $LocationName

var artifactTexture = preload("res://TemporaryIcons/artifact.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	updateLocationInfo()


func updateLocationInfo():
	
	for child in roomIcons.get_children():
		child.queue_free()
		
	var artifactRect = TextureRect.new()
	artifactRect.texture = artifactTexture
	artifactRect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	artifactRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	roomIcons.add_child(artifactRect)
	
	match StoredElements.difficulty:
		0:
			difficultyDisplay.text = "DIFFICULTY: VERY EASY"
			locationName.text = "OUTSKIRTS"
		1:
			difficultyDisplay.text = "DIFFICULTY: VERY EASY"
			locationName.text = "MILL"
		2:
			difficultyDisplay.text = "DIFFICULTY: EASY"
			locationName.text = "GORGE"
		3:
			difficultyDisplay.text = "DIFFICULTY: MEDIUM"
			locationName.text = "VALLEY"
		4:
			difficultyDisplay.text = "DIFFICULTY: HARD"
			locationName.text = "CAVERNS"
		5:
			difficultyDisplay.text = "DIFFICULTY: VERY HARD"
			locationName.text = "CRATER"
		6:
			difficultyDisplay.text = "DIFFICULTY: EXTREME"
			locationName.text = "COLLAPSED CANYON"
