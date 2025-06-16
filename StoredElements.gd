extends Node

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
var gold
var artifactCount
var weapons = []
var weaponStrengths = []
var highestDifficultyWinCount

# Set Up Stats
var difficulty
var wager
var classId
var weapon
var weaponStrength
var weaponIndex = -1

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

