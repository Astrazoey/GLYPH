extends Node2D

var WindowHelper = preload("res://WindowHelper.gd").new()
var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()

var dungeon = null
var dungeonSize: int = 0
var cellSize: int = 64  # Default, overridden by DungeonGeneration
var Room = preload("res://Room.gd")

var roomTypeStyles = {
	Room.RoomType.WALL: [Color(0, 0, 0), true],
	Room.RoomType.EMPTY: [Color(0, 0, 0), false],
	Room.RoomType.START: [Color(0, 1, 0), true],
	Room.RoomType.ARTIFACT: [Color(0, 0, 1), true],
	Room.RoomType.EXIT: [Color(1, 0, 0), true],
	Room.RoomType.TEMP: [Color(1, 1, 1), true],
	Room.RoomType.ENEMY: [Color(0.5, 0, 0), true],
	Room.RoomType.ITEM: [Color(1, 1, 0), true],
	Room.RoomType.SHOP: [Color(0.5, 0.5, 0), true],
	Room.RoomType.TELEPORTER_ENTRANCE: [Color(1, 0, 1), true],
	Room.RoomType.TELEPORTER_EXIT: [Color(0.5, 0, 0.5), true],
	Room.RoomType.MIMIC: [Color(0, 0.3, 0), true],
	Room.RoomType.SWAPPER: [Color(0, 0, 0.5), true],
	Room.RoomType.SOOTHSAYER: [Color(0.5, 0.5, 0.5), true],
	Room.RoomType.BOSS: [Color(0.1, 0.2, 0.3), true],
	Room.RoomType.HEALTH_ROOM: [Color(0.3, 0.2, 0.3), true],
}

func _input(event):
	WindowHelper.allowCheatInputs(event)
	WindowHelper.allowMapInput(event)

func _ready():
	StoredDungeon.setDungeonVisualizer(self)

func setDungeon(dungeonRef):
	if(dungeonRef != null):
		dungeon = dungeonRef
		dungeonSize = dungeonRef.getSize()
	else:
		dungeon = null
		dungeonSize = 0
		cellSize = 0
	redraw()


func redraw():
	queue_redraw()
	showStats()

func _draw():
	if dungeon == null:
		return  # No dungeon, no drawing
	
	cellSize = 400 / (dungeonSize*2)
	
	for x in range(dungeonSize):
		for y in range(dungeonSize):
			# Get Cell Position and Center
			var pos = Vector2(x * cellSize * 2 + 2, y * cellSize * 2 + 2)
			var center = pos + Vector2(cellSize / 2 + 2, cellSize / 2 + 2)
			
			drawPaths(x, y, center)
			drawCells(x, y, pos)
			
	if(StoredDungeon.showPlayer && dungeon != null):
		draw_circle(Vector2(cellSize/2 + cellSize*StoredDungeon.playerPosX*2 + 2, cellSize/2 + cellSize * StoredDungeon.playerPosY*2 + 2), cellSize/4, Color(0.8, 0.8, 0.8))
		draw_circle(Vector2(cellSize/2 + cellSize*StoredDungeon.playerPosX*2 + 2, cellSize/2 + cellSize * StoredDungeon.playerPosY*2 + 2), cellSize/5, Color(0.2, 0.2, 0.2))
	
func createCell(pos, color, filled):
	draw_rect(Rect2(pos, Vector2(cellSize, cellSize)), color, filled)

func drawCells(x, y, pos):
	var room_type = dungeon.getRoomType(x, y)
	if roomTypeStyles.has(room_type):
		var style = roomTypeStyles[room_type]
		createCell(pos, style[0], style[1])

func drawPaths(x, y, center):
	var room = dungeon.grid[x][y]

	var directions = {
		"N": Vector2(0, -1),
		"S": Vector2(0, 1),
		"E": Vector2(1, 0),
		"W": Vector2(-1, 0),
		"NE": Vector2(1, -1),
		"SE": Vector2(1, 1),
		"NW": Vector2(-1, -1),
		"SW": Vector2(-1, 1),
	}

	for dir in directions:
		var offset = directions[dir]
		var target_x = x + int(offset.x)
		var target_y = y + int(offset.y)

		# Check to see if rooms are in bounds
		#var in_bounds = target_x >= 0 && target_x < dungeonSize && target_y >= 0 && target_y < dungeonSize

		if room.getExit(dir): #and in_bounds:
			draw_line(center, center + offset * cellSize, Color(1, 1, 1))

func showStats():
	MenuMakerHelper.clearMenu(self)
	MenuMakerHelper.createSimpleLabel("Gold: %d | Artifact: %s | Moves: %d" % [StoredElements.player.gold, str(StoredElements.player.hasArtifact), StoredElements.player.moveCount], 12, Vector2(16, 416), self)
	MenuMakerHelper.createSimpleLabel("HP: %d | ATK: %d | DEF: %d | AGI: %d | CD: %d | CCD: %d" % [StoredElements.player.health, StoredElements.player.attack, StoredElements.player.armor, StoredElements.player.agility, StoredElements.player.abilityCooldown, StoredElements.player.currentCooldown], 12, Vector2(16, 432), self)
