extends Node2D

var Room = preload("res://Room.gd")
var WindowHelper = preload("res://WindowHelper.gd").new()

var gridSize
var cellSize
var optionSize = 24
var mapSize = 690

enum CellOptions {START, END, ITEM, ENEMY, TRAP, TELEPORT, STAR, TAB}
var cellOption = CellOptions.START
var cellOptionButtons = []
var cells = []
var paths = []

var cellTextures = {
	"empty": preload("res://TemporaryMapPieces/empty.png"),
	"start": preload("res://TemporaryMapPieces/start.png"),
	"end": preload("res://TemporaryMapPieces/exit.png"),
	"item": preload("res://TemporaryMapPieces/item.png"),
	"enemy": preload("res://TemporaryMapPieces/enemy.png"),
	"trap": preload("res://TemporaryMapPieces/trap.png"),
	"teleport": preload("res://TemporaryMapPieces/teleport.png"),
	"star": preload("res://TemporaryMapPieces/star.png"),
	"tab": preload("res://TemporaryMapPieces/tab.png"),
	"start_selected": preload("res://TemporaryMapPieces/start_selected.png"),
	"end_selected": preload("res://TemporaryMapPieces/exit_selected.png"),
	"item_selected": preload("res://TemporaryMapPieces/item_selected.png"),
	"enemy_selected": preload("res://TemporaryMapPieces/enemy_selected.png"),
	"trap_selected": preload("res://TemporaryMapPieces/trap_selected.png"),
	"teleport_selected": preload("res://TemporaryMapPieces/teleport_selected.png"),
	"star_selected": preload("res://TemporaryMapPieces/star_selected.png"),
	"tab_selected": preload("res://TemporaryMapPieces/tab_selected.png")
}

var cursorTextures = {
	"start": preload("res://TemporaryMapPieces/start_shape.png"),
	"end": preload("res://TemporaryMapPieces/exit_shape.png"),
	"item": preload("res://TemporaryMapPieces/item_shape.png"),
	"enemy": preload("res://TemporaryMapPieces/enemy_shape.png"),
	"trap": preload("res://TemporaryMapPieces/trap_shape.png"),
	"teleport": preload("res://TemporaryMapPieces/teleport_shape.png"),
	"star": preload("res://TemporaryMapPieces/star_shape.png"),
	"tab": preload("res://TemporaryMapPieces/tab_shape.png"),
}

var pathTextures = {
	"empty": preload("res://TemporaryMapPieces/empty_path.png"),
	"dotted_diagonal_1": preload("res://TemporaryMapPieces/path_diagonal1_dotted.png"),
	"dotted_diagonal_2": preload("res://TemporaryMapPieces/path_diagonal2_dotted.png"),
	"diagonal_1": preload("res://TemporaryMapPieces/path_diagonal1.png"),
	"diagonal_2": preload("res://TemporaryMapPieces/path_diagonal2.png"),
	"dotted_up_down": preload("res://TemporaryMapPieces/path_up_down_dotted.png"),
	"dotted_left_right": preload("res://TemporaryMapPieces/path_left_right_dotted.png"),
	"up_down": preload("res://TemporaryMapPieces/path_up_down.png"),
	"left_right": preload("res://TemporaryMapPieces/path_left_right.png")
}

var optionsTextures = {
	"path" : preload("res://TemporaryMapPieces/filled_path_option.png"),
	"dotted_path" : preload("res://TemporaryMapPieces/dotted_path_option.png"),
	"path_selected" : preload("res://TemporaryMapPieces/filled_path_option_selected.png"),
	"dotted_path_selected" : preload("res://TemporaryMapPieces/dotted_path_option_selected.png"),
	"clear" : preload("res://TemporaryMapPieces/clear_paths.png")
}

var followerSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	if(!StoredDungeon.getDungeonMap()):
		StoredDungeon.setDungeonMap(self)
		mapSize = 790
	else:
		mapSize = 545
	StoredDungeon.addDungeonMap(self)
	generateNewMap()
	
	followerSprite = Sprite2D.new()
	followerSprite.texture = cellTextures["empty"]
	followerSprite.modulate.a = 1
	followerSprite.z_index = 1000
	followerSprite.z_as_relative = false
	followerSprite.scale = followerSprite.scale / 10
	add_child(followerSprite)
	
	WindowHelper.focusOnMouseHover(get_window())

	
@warning_ignore("unused_parameter")
func _process(delta):
	followerSprite.global_position = get_global_mouse_position()
	
	match cellOption:
		0:
			followerSprite.texture = cursorTextures["start"]
		1:
			followerSprite.texture = cursorTextures["end"]
		2:
			followerSprite.texture = cursorTextures["item"]
		3:
			followerSprite.texture = cursorTextures["enemy"]
		4:
			followerSprite.texture = cursorTextures["trap"]
		5:
			followerSprite.texture = cursorTextures["teleport"]
		6:
			followerSprite.texture = cursorTextures["star"]
		7:
			followerSprite.texture = cursorTextures["tab"]
			
	

func _input(event):
	WindowHelper.allowCheatInputs(event)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Left click: call the pressCell method
			clickCell(event.position, event.button_index)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Right click: call the pressCell method with the right-click texture
			clickCell(event.position, event.button_index)
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if(cellOption < 7):
				selectCellOption(cellOptionButtons[cellOption + 1], cellOption + 1)
			else:
				selectCellOption(cellOptionButtons[0], 0)
				
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if(cellOption > 0):
				selectCellOption(cellOptionButtons[cellOption - 1], cellOption - 1)
			else:
				selectCellOption(cellOptionButtons[7], 7)
				
		get_window().grab_focus()
			
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_1:
			selectCellOption(cellOptionButtons[0], 0)
		if event.pressed and event.keycode == KEY_2:
			selectCellOption(cellOptionButtons[1], 1)
		if event.pressed and event.keycode == KEY_3:
			selectCellOption(cellOptionButtons[2], 2)
		if event.pressed and event.keycode == KEY_4:
			selectCellOption(cellOptionButtons[3], 3)
		if event.pressed and event.keycode == KEY_5:
			selectCellOption(cellOptionButtons[4], 4)
		if event.pressed and event.keycode == KEY_6:
			selectCellOption(cellOptionButtons[5], 5)
		if event.pressed and event.keycode == KEY_7:
			selectCellOption(cellOptionButtons[6], 6)
		if event.pressed and event.keycode == KEY_8:
			selectCellOption(cellOptionButtons[7], 7)
			
		get_window().grab_focus()
	

func getButtonAtPosition(pos):
	for child in get_children():
		if child is TextureButton and child.get_rect().has_point(pos):
			return child

func clickCell(pos, buttonIndex):	
	var button = getButtonAtPosition(pos)
	
		
	var textureCycles = {
		CellOptions.START: [cellTextures["empty"], cellTextures["start"], cellTextures["start_selected"]],
		CellOptions.END: [cellTextures["empty"], cellTextures["end"], cellTextures["end_selected"]],
		CellOptions.ENEMY: [cellTextures["empty"], cellTextures["enemy"], cellTextures["enemy_selected"]],
		CellOptions.ITEM: [cellTextures["empty"], cellTextures["item"], cellTextures["item_selected"]],
		CellOptions.TRAP: [cellTextures["empty"], cellTextures["trap"], cellTextures["trap_selected"]],
		CellOptions.TELEPORT: [cellTextures["empty"], cellTextures["teleport"], cellTextures["teleport_selected"]],
		CellOptions.STAR: [cellTextures["empty"], cellTextures["star"], cellTextures["star_selected"]],
		CellOptions.TAB: [cellTextures["empty"], cellTextures["tab"], cellTextures["tab_selected"]]
	}
	
	var pathTexturesDictionary = {
		"left_right": [pathTextures["empty"], pathTextures["dotted_left_right"], pathTextures["left_right"]],
		"up_down": [pathTextures["empty"], pathTextures["dotted_up_down"], pathTextures["up_down"]],
		"diagonal": [pathTextures["empty"], pathTextures["dotted_diagonal_1"], pathTextures["diagonal_1"], pathTextures["dotted_diagonal_2"], pathTextures["diagonal_2"]]
	}
	
	var index = 2 # left click
	if buttonIndex == MOUSE_BUTTON_RIGHT:
		index = 1
	
	if button:
		if button.get_meta("type") == "cell":
			if cellOption in textureCycles:
				var textures = textureCycles[cellOption]
				
				if button.texture_normal in textures:
					if button.texture_normal != textures[0]:
						button.texture_normal = textures[0]
					else:
						button.texture_normal = textures[index]
				else:
					button.texture_normal = cellTextures["empty"]
			playSound()
				
		if button.get_meta("type") == "path":
			if button.get_meta("path_type") == "left_right":
				var textures = pathTexturesDictionary["left_right"]
				if button.texture_normal in textures:
					if button.texture_normal != textures[0]:
						button.texture_normal = textures[0]
					else:
						button.texture_normal = textures[index]
			elif button.get_meta("path_type") == "up_down":
				var textures = pathTexturesDictionary["up_down"]
				if button.texture_normal in textures:
					if button.texture_normal != textures[0]:
						button.texture_normal = textures[0]
					else:
						button.texture_normal = textures[index]
			elif button.get_meta("path_type") == "diagonal":
				var textures = pathTexturesDictionary["diagonal"]
				if button.texture_normal in textures:
					if button.texture_normal == textures[3] or button.texture_normal == textures[4]:
						button.texture_normal = textures[0]
					elif button.texture_normal == textures[0]:
						button.texture_normal = textures[index]
					else:
						button.texture_normal = textures[index+2]
			playSound()
			
		if button.get_meta("type") == "clear":
			clearBoard()	



func generateNewMap():
	clearBoard()

func createGridButton(texture, posX, posY, size):
	var gridButton = TextureButton.new()
	gridButton.texture_normal = texture
	gridButton.position = Vector2(posX, posY)
	gridButton.scale = Vector2(size, size)
	return gridButton
	

func generateGrid():
	# Generate the Grid
	
	@warning_ignore("integer_division")
	gridSize = StoredDungeon.dungeonSize + StoredDungeon.dungeonSize/2
	if(gridSize % 2 == 0):
		gridSize += 1
	
	
	cellSize = mapSize / gridSize / 2
	var cellScale = 1.0/(128.0/cellSize)
	
	# Cells
	cells = []
	for x in range (gridSize):
		cells.append([])
		for y in range(gridSize):
			var gridButton = createGridButton(cellTextures["empty"], x * cellSize * 2, y * cellSize * 2, cellScale)
			gridButton.set_meta("type", "cell")
			add_child(gridButton)
			cells[x].append(gridButton)
			
	# Paths
	var pathConfigs = [
		{ "rangeX": gridSize - 1, "rangeY": gridSize - 1, "offset": Vector2(cellSize, cellSize), "meta": "path" , "meta2": "diagonal"},
		{ "rangeX": gridSize - 1, "rangeY": gridSize, "offset": Vector2(cellSize, 0), "meta": "path" , "meta2": "left_right"},
		{ "rangeX": gridSize, "rangeY": gridSize - 1, "offset": Vector2(0, cellSize), "meta": "path" , "meta2": "up_down"}
	]

	paths = []
	var pathIndex = 0
	for config in pathConfigs:
		paths.append([])
		for x in range(config.rangeX):
			paths[pathIndex].append([])
			for y in range(config.rangeY):
				var pathButton = createGridButton(pathTextures["empty"], x * cellSize * 2 + config.offset.x, y * cellSize * 2 + config.offset.y, cellScale)
				pathButton.set_meta("type", config.meta)
				pathButton.set_meta("path_type", config.meta2)
				add_child(pathButton)
				paths[pathIndex][x].append(pathButton)
		pathIndex += 1

func createButton(texture, pos, btnScale, callback, arg, buttonList):
	var button = TextureButton.new()
	button.texture_normal = texture
	button.position = pos
	button.scale = btnScale
	button.connect("pressed", callback.bind(button, arg))
	add_child(button)
	buttonList.append(button)
	return button

func generateOptionsMenu():
	# Initial positions
	var posX = mapSize
	var posY = optionSize
	var btnScale = Vector2(0.25, 0.25)

	var cellButtons = [
		{ "texture": cellTextures["start_selected"], "option": CellOptions.START },
		{ "texture": cellTextures["end"], "option": CellOptions.END },
		{ "texture": cellTextures["item"], "option": CellOptions.ITEM },
		{ "texture": cellTextures["enemy"], "option": CellOptions.ENEMY },
		{ "texture": cellTextures["trap"], "option": CellOptions.TRAP },
		{ "texture": cellTextures["teleport"], "option": CellOptions.TELEPORT },
		{ "texture": cellTextures["star"], "option": CellOptions.STAR},
		{ "texture": cellTextures["tab"], "option": CellOptions.TAB}
	]

	posY += optionSize # gap
	for buttonData in cellButtons:
		createButton(buttonData.texture, Vector2(posX, posY), btnScale, selectCellOption, buttonData.option, cellOptionButtons)
		posY += optionSize * 1.5

	# Clear Board Option
	posY += optionSize # gap
	var clearButton = createButton(optionsTextures["clear"], Vector2(posX, posY), btnScale, empty, null, cellOptionButtons)
	clearButton.set_meta("type", "clear")

func playSound():
	get_node("AudioClick").play()

func selectCellOption(cellButton, newOption):
	playSound()
	
	deselectAllCellOptions()
	cellOption = newOption
	
	var textureMap = {
		cellTextures["start"]: cellTextures["start_selected"],
		cellTextures["end"]: cellTextures["end_selected"],
		cellTextures["enemy"]: cellTextures["enemy_selected"],
		cellTextures["item"]: cellTextures["item_selected"],
		cellTextures["trap"]: cellTextures["trap_selected"],
		cellTextures["teleport"]: cellTextures["teleport_selected"],
		cellTextures["star"]: cellTextures["star_selected"],
		cellTextures["tab"]: cellTextures["tab_selected"]
	}
	
	if cellButton.texture_normal in textureMap:
		cellButton.texture_normal = textureMap[cellButton.texture_normal]
			
func deselectAllCellOptions():
	var textureMap = {
		cellTextures["start_selected"]: cellTextures["start"],
		cellTextures["end_selected"]: cellTextures["end"],
		cellTextures["enemy_selected"]: cellTextures["enemy"],
		cellTextures["item_selected"]: cellTextures["item"],
		cellTextures["trap_selected"]: cellTextures["trap"],
		cellTextures["teleport_selected"]: cellTextures["teleport"],
		cellTextures["star_selected"]: cellTextures["star"],
		cellTextures["tab_selected"]: cellTextures["tab"],
	}
	
	for button in cellOptionButtons:
		if button.texture_normal in textureMap:
			button.texture_normal = textureMap[button.texture_normal]

func empty():
	return
	
func closeWindow():
	get_parent().queue_free()
	
func setMiddleTile():
	var middle: int = 0
	middle = ((gridSize + 1) / 2) - 1
	cells[middle][middle].texture_normal = cellTextures["teleport_selected"]
	
func autofillBoard(room, startX, startY):
	var mapCenter = gridSize / 2
	var startOffsetX = mapCenter - startX
	var startOffsetY = mapCenter - startY
	
	var positionX = room.posX + startOffsetX
	var positionY = room.posY + startOffsetY
	
	
	# The Cell Itself
	if(room.roomType == Room.RoomType.START || room.roomType == Room.RoomType.ARTIFACT || room.roomType == Room.RoomType.EXIT):
		cells[positionX][positionY].texture_normal = cellTextures["teleport_selected"]
	elif(room.roomType == Room.RoomType.ITEM || room.roomType == Room.RoomType.MIMIC):
		cells[positionX][positionY].texture_normal = cellTextures["item_selected"]
	elif(room.roomType == Room.RoomType.ENEMY):
		cells[positionX][positionY].texture_normal = cellTextures["trap_selected"]
	elif(room.roomType == Room.RoomType.SHOP):
		cells[positionX][positionY].texture_normal = cellTextures["enemy_selected"]
	elif(room.roomType == Room.RoomType.SOOTHSAYER):
		cells[positionX][positionY].texture_normal = cellTextures["star_selected"]
	elif(room.roomType == Room.RoomType.TELEPORTER_ENTRANCE || room.roomType == Room.RoomType.TELEPORTER_EXIT):
		cells[positionX][positionY].texture_normal = cellTextures["end_selected"]
	else:
		cells[positionX][positionY].texture_normal = cellTextures["start_selected"]
	
	
	var exits = room.getExits()
	var validExits = []
	
	# Paths connecting cells
	for exit in exits:
		if(exit == "NW"):
			paths[0][positionX-1][positionY-1].texture_normal = pathTextures["diagonal_2"]
			validExits.append(exit)
		elif(exit == "NE"):
			paths[0][positionX][positionY-1].texture_normal = pathTextures["diagonal_1"]
			validExits.append(exit)
		elif(exit == "SW"):
			paths[0][positionX-1][positionY].texture_normal = pathTextures["diagonal_1"]
			validExits.append(exit)
		elif(exit == "SE"):
			paths[0][positionX][positionY].texture_normal = pathTextures["diagonal_2"]
			validExits.append(exit)
		elif(exit == "W"):
			paths[1][positionX-1][positionY].texture_normal = pathTextures["left_right"]
			validExits.append(exit)
		elif(exit == "E"):
			paths[1][positionX][positionY].texture_normal = pathTextures["left_right"]
			validExits.append(exit)
		elif(exit == "N"):
			paths[2][positionX][positionY-1].texture_normal = pathTextures["up_down"]
			validExits.append(exit)
		elif(exit == "S"):
			paths[2][positionX][positionY].texture_normal = pathTextures["up_down"]
			validExits.append(exit)
	
	
	# Fill in nearby enemies		
	if(room.roomType == Room.RoomType.TEMP && room.nearEnemy):
		for validExit in validExits:
			if(validExit == "N"):
				if(cells[positionX][positionY-1].texture_normal == cellTextures["empty"]):
					cells[positionX][positionY-1].texture_normal = cellTextures["trap"]
			elif(validExit == "S"):
				if(cells[positionX][positionY+1].texture_normal == cellTextures["empty"]):
					cells[positionX][positionY+1].texture_normal = cellTextures["trap"]
			elif(validExit == "W"):
				if(cells[positionX-1][positionY].texture_normal == cellTextures["empty"]):
					cells[positionX-1][positionY].texture_normal = cellTextures["trap"]
			elif(validExit == "E"):
				if(cells[positionX+1][positionY].texture_normal == cellTextures["empty"]):
					cells[positionX+1][positionY].texture_normal = cellTextures["trap"]
					
			elif(validExit == "NE"):
				if(cells[positionX+1][positionY-1].texture_normal == cellTextures["empty"]):
					cells[positionX+1][positionY-1].texture_normal = cellTextures["trap"]
			elif(validExit == "NW"):
				if(cells[positionX-1][positionY-1].texture_normal == cellTextures["empty"]):
					cells[positionX-1][positionY-1].texture_normal = cellTextures["trap"]
			elif(validExit == "SE"):
				if(cells[positionX+1][positionY+1].texture_normal == cellTextures["empty"]):
					cells[positionX+1][positionY+1].texture_normal = cellTextures["trap"]
			elif(validExit == "SW"):
				if(cells[positionX-1][positionY+1].texture_normal == cellTextures["empty"]):
					cells[positionX-1][positionY+1].texture_normal = cellTextures["trap"]		
	
	
	
	
	return
	
func clearBoard():
	for child in get_children():
		if child is TextureButton:
			child.queue_free()
		
	cellOptionButtons = []
	cellOption = CellOptions.START
		
	generateGrid()
	generateOptionsMenu()
	playSound()
	setMiddleTile()
	
	if(followerSprite != null):
		followerSprite.z_index = 1000
