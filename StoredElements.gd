extends Node

# Cheats
var enableCheats = false

# Major Elements
var player
var master
var dungeonGenerator
var windowManager
var inventoryManager
var playing
var saveData = {}
var saveSlot = -1

# Current Menu
var menu = "BOOT"

# General Stats
var gold = 0
var artifactCount = 0

var highestDifficultyWinCount: int

# Set Up Stats
var wager = 0
var max_wager = 0

var weapons = []
var weaponStrengths = []
var weapon = 0
var weaponStr = 2
var weaponIndex = -1
var max_weapons = 1

# Difficulties - unlock system to be replaced by artifacts instead of "highest win count"
var difficulty = 0
var difficulties = {
	"TUTORIAL" : true,
	"VERY EASY" : false,
	"EASY" : false,
	"MEDIUM" : false,
	"HARD" : false,
	"VERY HARD" : false,
	"EXTREME" : false,
}
var defaultDifficulties

var difficultyLevels = [
	"TUTORIAL",
	"VERY EASY",
	"EASY",
	"MEDIUM",
	"HARD",
	"VERY HARD",
	"EXTREME",
]

# Classes
enum CharacterClass {ARCHIVIST, SCOUT, APPRAISER, SERFS, TRAPPER, FUGITIVE}
var classId = CharacterClass.ARCHIVIST
var classUnlocks = {
	"ARCHIVIST" : true,
	"SCOUT" : false,
	"APPRAISER" : false,
	"SERFS" : false,
	"TRAPPER" : false,
	"FUGITIVE" : false,
}
var defaultClasses

# Win Items
var winWeapon = -1
var winWeaponDamage = 2
var winGold = 0
var winArtifact = false

func _ready():
	defaultClasses = classUnlocks.duplicate()
	defaultDifficulties = difficulties.duplicate()
	updateUnlocks()

func setPlayer(newPlayer):
	player = newPlayer
	
func setMaster(newMaster):
	master = newMaster

func setDungeonGenerator(newDungeonGenerator):
	dungeonGenerator = newDungeonGenerator

func setWindowManager(newWindowManager):
	windowManager = newWindowManager

func setInventoryManager(newInventoryManager):
	inventoryManager = newInventoryManager


func updateUnlocks():
	difficulties = defaultDifficulties.duplicate()
	classUnlocks = defaultClasses.duplicate()
	max_wager = 0
	max_weapons = 1
	
	if highestDifficultyWinCount >= 3:
		difficulties["VERY EASY"] = true
		classUnlocks["APPRAISER"] = true
	if highestDifficultyWinCount >= 6:
		difficulties["EASY"] = true
		classUnlocks["SCOUT"] = true
		max_weapons = 2
	if highestDifficultyWinCount >= 10:
		difficulties["MEDIUM"] = true
		max_wager = 5
		max_weapons = 3
	if highestDifficultyWinCount >= 15:
		difficulties["HARD"] = true
		classUnlocks["TRAPPER"] = true
	if highestDifficultyWinCount >= 20:
		difficulties["VERY HARD"] = true
		classUnlocks["SERFS"] = true
		max_wager = 10
		max_weapons = 4
	if highestDifficultyWinCount >= 30:
		difficulties["EXTREME"] = true
		classUnlocks["FUGITIVE"] = true
		max_weapons = 5
		
	weapons.resize(max_weapons)
	weaponStrengths.resize(max_weapons)
	
	for i in weapons:
		if i == null:
			i = -1
	for i in weaponStrengths:
		if i == null:
			i = -1

func isHighestDifficulty():
	for i in range(difficulty + 1, difficultyLevels.size()):
		var name = difficultyLevels[i]
		if difficulties.get(name, false):
			return false
	return difficulties.get(difficultyLevels[difficulty], false)	
