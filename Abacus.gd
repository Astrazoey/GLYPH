
extends Control

var WindowHelper = preload("res://WindowHelper.gd").new()
var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()

@export var columnCount = 11
@export var lowerBeads = 5
@export var upperBeads = 2
var beadSize = Vector2(32, 32)
@export var beadSz = 32


@onready var frame = $Frame
@onready var middleBar = $MiddleBar
@onready var marginContainer = $Frame/MarginContainer
@onready var resetButton = $ResetButton

var tweens = []
var beadPositions = []
var upperColumnBeads = []
var lowerColumnBeads = []

var resetTexture = preload("res://TemporaryMapPieces/clear_paths.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		
		call_deferred("free")
		
		if get_child_count() == 0:
			generateAbacus()
	else:
		await get_tree().process_frame
		generateAbacus()

	
func generateAbacus():
	beadSize = Vector2(beadSz, beadSz)
	
	print(self.size.x)
	print(self.size.y)
	
	var beadWidth = self.size.x / columnCount+2
	var beadHeight = self.size.y / (upperBeads + lowerBeads + 3)
	
	print(beadWidth, beadHeight)
	beadSz = min(beadWidth, beadHeight)
	
	# Create Frame
	#frame.size = Vector2(((beadSz * (columnCount+1))), beadSz*(lowerBeads+upperBeads+3))
	
	# Create Columns
	for i in range(columnCount):
		upperColumnBeads.append([])
		lowerColumnBeads.append([])
		createColumn(Vector2(beadSz + i * beadSz, 0), i)
	
	# Create Middle Bar
	middleBar.size = Vector2(((beadSz * (columnCount+1))), beadSz)
	middleBar.position = Vector2(0, beadSz*(upperBeads+1))

	resetButton.connect("pressed", resetAbacus.bind())
	resetButton.size = Vector2(beadSz, beadSz)
	resetButton.position = Vector2(0, beadSz * (upperBeads+1))
	#MenuMakerHelper.addTextureButton(
		#resetTexture,
		#null,
		#resetAbacus.bind(),
		#Vector2(beadSz / 128.0, beadSz / 128.0),
		#Vector2(0, beadSz * (upperBeads+1)),
		#self
	#)	

func _input(event):
	if(StoredElements.windowManager != null):
		#WindowHelper.allowMapInput(event)
		WindowHelper.allowCheatInputs(event)

func resetAbacus():
	AudioManager.get_node("Sounds/ButtonClick").play()
	
	for i in range(upperColumnBeads.size()):
		for bead in upperColumnBeads[i]:
			bead.position = bead.get_meta("originalPosition")
			
	for i in range(lowerColumnBeads.size()):
		for bead in lowerColumnBeads[i]:
			bead.position = bead.get_meta("originalPosition")

func createRod(position):
	var rod = ColorRect.new()
	rod.color = Color(0, 0, 0)
	rod.size = Vector2(5 * (beadSz / 32.0), beadSz * (upperBeads + lowerBeads + 3))
	rod.position = Vector2(position.x - (beadSz / 8), position.y)
	add_child(rod)

func createColumn(position, columnIndex):
	createRod(position)
	
	for i in range(lowerBeads):
		var bead = createBead(position + Vector2(beadSz/-2, (beadSz*(upperBeads+3)) + i * beadSz), true, columnIndex, i)
		lowerColumnBeads[columnIndex].append(bead)

	for i in range(upperBeads):
		var bead = createBead(position + Vector2(beadSz/-2, 0 + i * beadSz), false, columnIndex, i)
		upperColumnBeads[columnIndex].append(bead)
		
func createBead(position, isLower, columnIndex, beadIndex):
	var bead = TextureButton.new()
	bead.texture_normal = preload("res://TemporaryIcons/bead.png")
	bead.texture_hover = preload("res://TemporaryIcons/bead_selected.png")
	bead.scale = Vector2(beadSz / 32.0, beadSz / 32.0)
	#print("created bead with scale", beadSz / 32.0)
	#bead.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	#bead.custom_minimum_size = beadSize
	bead.position = position
	bead.set_meta("originalPosition", position)
	bead.set_meta("beadIndex", beadIndex)
	bead.connect("pressed", moveBead.bind(bead, isLower, columnIndex))
	add_child(bead)
	return bead

func moveBead(bead, isLower, columnIndex):
	AudioManager.get_node("Sounds/AbacusBead").set_pitch_scale(randf_range(0.75, 1.25))
	AudioManager.get_node("Sounds/AbacusBead").play()
	
	tweens = []
	
	var originalPosition = bead.get_meta("originalPosition")
	var direction = -1 if isLower else 1
	var targetPosition = bead.position + Vector2(0, -beadSz) if isLower else bead.position + Vector2(0, beadSz)
	var inOriginalPosition = true
	
	if(bead.position != originalPosition):
		targetPosition = originalPosition
		inOriginalPosition = false
		
	if(!inOriginalPosition):
		direction = direction * -1
		

	# Bead collision
	var beadsToMove = []
	if(isLower):
		for otherBead in lowerColumnBeads[columnIndex]:
			if otherBead != bead:
				if(direction == -1 && otherBead.get_meta("originalPosition") == otherBead.position):
					if otherBead.get_meta("beadIndex") < bead.get_meta("beadIndex"):
						beadsToMove.append(otherBead)
				if(direction == 1 && otherBead.get_meta("originalPosition") != otherBead.position):
					if otherBead.get_meta("beadIndex") > bead.get_meta("beadIndex"):
						beadsToMove.append(otherBead)
	else:
		for otherBead in upperColumnBeads[columnIndex]:
			if otherBead != bead:
				if(direction == 1 && otherBead.get_meta("originalPosition") == otherBead.position):
					if otherBead.get_meta("beadIndex") > bead.get_meta("beadIndex"):
						beadsToMove.append(otherBead)
				if(direction == -1 && otherBead.get_meta("originalPosition") != otherBead.position):
					if otherBead.get_meta("beadIndex") < bead.get_meta("beadIndex"):
						beadsToMove.append(otherBead)
	beadsToMove.append(bead)

	var tweenIndex = 0
	for movingBead in beadsToMove:
		movingBead.disabled = true
		var newPosition = movingBead.position + Vector2(0, direction * beadSz)
		var newTween = create_tween()
		newTween.tween_property(movingBead, "position", newPosition, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		newTween.connect("finished", func():
				movingBead.disabled = false  # Re-enable only after the last tween finishes
		)
		
		tweens.append(newTween)
