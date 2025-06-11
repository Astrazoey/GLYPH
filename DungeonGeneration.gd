extends Node

var dungeonSize: int = 7 # CANNOT be less than 3
var branchingPathAmount: int = 4 # if 0 then shows main path only

var enemyCount: int = 5
var bossCount: int = 0
var enemyStrength: int = 5
var itemCount: int = 4
var shopCount: int = 0
var mimicCount: int = 0
var wallCount: int = 0
var teleporterEntranceCount: int = 0
var teleporterExitCount: int = 0
var swapperCount: int = 0
var soothsayerCount: int = 0
var healthRoomCount: int = 0

var nextStartRoom

var Dungeon = preload("res://Dungeon.gd")
var Room = preload("res://Room.gd")
var dungeon
var pathSuccess: bool = false
var maxAttempts: int = 16
var player

enum Difficulties {TUTORIAL, EASY, MEDIUM, HARD, VERY_HARD, EXTREME, VERY_EXTREME, CUSTOM}
var difficulty = Difficulties.VERY_HARD


var dungeonVisualizerWindow : Window  # Reference to the visualizer window
var dungeonMapWindow : Window # Reference to the map window


# Called when the node enters the scene tree for the first time.
func _ready():
	StoredElements.setDungeonGenerator(self)
	return
	
func setDungeonVisualizer(window: Window):
	dungeonVisualizerWindow = window

func setDungeonMap(window: Window):
	dungeonMapWindow = window


func startDungeonGeneration():
	#seed(1)
	pathSuccess = false # reset this value in case this is a new dungeon
	
	#print("Setting difficulty...")
	selectDifficulty()
	
	#print("Starting generation...")
	dungeon = Dungeon.new()

	while(!pathSuccess):
		#print("Trying new generation...")
		dungeon.makeGrid(dungeonSize)
		pathSuccess = generateDungeon()

	# Draw Dungeon
	drawDungeon()
	drawMap()
	
	#Set Dungeon in Main Dungeon
	StoredDungeon.setDungeon(dungeon)
	
	player = get_node("Player")
	if player:
		player.setDungeon(dungeon)
		player.spawnPlayer()
	else:
		print("Player not found.")

func drawDungeon():
	StoredDungeon.getDungeonVisualizer().setDungeon(dungeon)

func drawMap():
	StoredDungeon.dungeonSize = dungeonSize


func selectDifficulty():
	var baseSettings = {
	"dungeonSize": 4,
	"branchingPathAmount": 1,
	"enemyCount": 0,
	"enemyStrength": 5,
	"bossCount": 0,
	"itemCount": 1,
	"shopCount": 0,
	"teleporterEntranceCount": 0,
	"teleporterExitCount": 0,
	"wallCount": 0,
	"mimicCount": 0,
	"swapperCount": 0,
	"soothsayerCount": 0,
	"healthRoomCount": 0
	}

	var difficultyModifications = {
		Difficulties.TUTORIAL: {
			# No changes, same as base_settings
		},
		Difficulties.EASY: {
			"dungeonSize": 4,
			"branchingPathAmount": 3,
			"enemyCount": 2,
			"itemCount": 2
		},
		Difficulties.MEDIUM: {
			"branchingPathAmount": 8,
			"dungeonSize": 5,
			"enemyCount": 3,
			"shopCount": 1,
			"itemCount" : 2,
			"teleporterEntranceCount": 1,
			"teleporterExitCount": 1
		},
		Difficulties.HARD: {
			"dungeonSize": 5,
			"branchingPathAmount": 8,
			"enemyCount": 4,
			"enemyStrength": 6,
			"shopCount": 1,
			"itemCount": 3,
			"mimicCount": 1,
			"swapperCount": 1,
			"teleporterEntranceCount": 1,
			"teleporterExitCount": 1,
			"soothsayerCount": 1,
			"healthRoomCount": 1
		},
		Difficulties.VERY_HARD: {
			"dungeonSize": 6,
			"branchingPathAmount": 9,
			"enemyCount": 5,
			"bossCount": 1,
			"enemyStrength": 7,
			"itemCount": 3,
			"shopCount": 2,
			"mimicCount": 2,
			"teleporterEntranceCount": 1,
			"teleporterExitCount": 1,
			"wallCount": 1,
			"swapperCount": 1,
			"soothsayerCount": 1,
			"healthRoomCount": 1
		},
		Difficulties.EXTREME: {
			"dungeonSize": 7,
			"branchingPathAmount": 12,
			"enemyCount": 6,
			"bossCount": 1,
			"enemyStrength": 7,
			"itemCount": 5,
			"shopCount": 3,
			"mimicCount": 2,
			"teleporterEntranceCount": 1,
			"teleporterExitCount": 1,
			"wallCount": 2,
			"swapperCount": 1,
			"soothsayerCount": 2,
			"healthRoomCount": 1
		},
		Difficulties.VERY_EXTREME: {
			"dungeonSize": 8,
			"branchingPathAmount": 12,
			"enemyCount": 9,
			"bossCount": 1,
			"enemyStrength": 8,
			"itemCount": 6,
			"shopCount": 4,
			"mimicCount": 3,
			"teleporterEntranceCount": 1,
			"teleporterExitCount": 1,
			"wallCount": 2,
			"swapperCount": 1,
			"soothsayerCount": 3,
			"healthRoomCount": 1
		},
		Difficulties.CUSTOM: {
			"dungeonSize": 20,
			"branchingPathAmount": 12,
			"enemyCount": 20,
			"itemCount": 10,
			"shopCount": 6,
			"mimicCount": 6,
			"teleporterEntranceCount": 6,
			"teleporterExitCount": 1,
			"wallCount": 6,
			"swapperCount": 4
		}
	}
	
	
	
	var settings = baseSettings.duplicate(true)  # Copy base settings
	if difficulty in difficultyModifications:
		settings.merge(difficultyModifications[difficulty], true)  # Apply modifications

	for key in settings:
		set(key, settings[key])

func generateDungeon():
	var currentPathSuccess: bool = false
	var creationAttempts: int = 0
	
	while(!currentPathSuccess):
		# Clear all rooms first
		dungeon.resetAllRooms(false)
		
		# Add walls
		for i in wallCount:
			dungeon.setRandomEmptyRoom(Room.RoomType.WALL)
		
		# Pick a random starting location
		dungeon.setRandomEmptyRoom(Room.RoomType.START)
		# Save dungeon in case this is a new dungeon entirely
		dungeon.saveCurrentDungeonState()
		# Find out the min and max path length
		dungeon.determinePathLength(0)
		# Find valid main path
		currentPathSuccess = dungeon.findPath()
		creationAttempts += 1
		if(creationAttempts > maxAttempts):
			return false
		

	#print("adding exit")
	# Add exit to main path
	var exitRoom = dungeon.getLastRoomChecked()
	dungeon.setRoomType(exitRoom, null, null, Room.RoomType.EXIT)
	
	#print("adding artifact")
	# Add artifact to main path
	dungeon.placeArtifact()
	
	# Add boss to main path
	if(bossCount > 0):
		var bossSuccess = dungeon.placeBoss()
		if(!bossSuccess):
			print("failed to place boss")
			return false
	
	#print("saving dungeon")
	# Save current state of the dungeon
	dungeon.saveCurrentDungeonState()
	
	#print("making branching paths")
	# Draw branching paths, does not work because the find pathing sometimes erases room data
	if(branchingPathAmount > 0):
		for i in branchingPathAmount:
			currentPathSuccess = false
			while(!currentPathSuccess):
				
				if(dungeon.getStartRoom() == null):
					print("start room is null, setting one")
					dungeon.setStartRoom(dungeon.getRandomBlankRoom())
					print(dungeon.getRandomBlankRoom())
				
				if(dungeon.getStartRoom().getExitCount() < 3): # generate a second path from the start room
					nextStartRoom = dungeon.getStartRoom()
				else:
					nextStartRoom = dungeon.getRandomBlankRoomWithLimitedExits()
					
				#print("Path started at: ", nextStartRoom.getPosX(), ", ", nextStartRoom.getPosY())
					
				dungeon.setStartRoom(nextStartRoom)
				dungeon.determinePathLength(i+1)
				currentPathSuccess = dungeon.findPath()
				creationAttempts += 1
				

				
				if(creationAttempts > maxAttempts):
					return false
				
			dungeon.saveCurrentDungeonState()	
		
	#print("successfully made a path")
		
	# Make sure the start room has 2 exits
	# should never happen but is happening anyway for some reason and causing performance issues
	if(dungeon.getStartRoom().getExitCount() < 2 && dungeonSize > 3):
		#print("start room fails to have at least two exits")
		return false
		
	#print("successfully did not make two start rooms")
		
	# make sure there's only 1 start room
	# no idea why there's sometimes 2 start rooms, shouldn't happen
	if(dungeon.countRoomOfType(Room.RoomType.START) > 1):
		#print("detected multiple start rooms")
		return false

	#print("populating rooms")
	# Populate rooms
	dungeon.populateRoomType(Room.RoomType.TELEPORTER_ENTRANCE, teleporterEntranceCount)
	dungeon.populateRoomType(Room.RoomType.TELEPORTER_EXIT, teleporterExitCount)
	dungeon.populateRoomType(Room.RoomType.SWAPPER, swapperCount)
	dungeon.populateRoomType(Room.RoomType.SHOP, shopCount)	
	dungeon.populateRoomType(Room.RoomType.ENEMY, enemyCount)
	dungeon.populateRoomType(Room.RoomType.ITEM, itemCount)
	dungeon.populateRoomType(Room.RoomType.MIMIC, mimicCount)
	dungeon.populateRoomType(Room.RoomType.SOOTHSAYER, soothsayerCount)
	dungeon.populateRoomType(Room.RoomType.HEALTH_ROOM, healthRoomCount)
	
	# Set stats for rooms
	dungeon.randomizeRoomParameters(enemyStrength)
	
	# Gives information to rooms about nearby threats
	dungeon.generateWarnings()
	
	return true
