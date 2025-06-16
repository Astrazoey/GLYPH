extends Node

var player
var master
var dungeonGenerator
var windowManager
var inventoryManager
var playing
var saveData = {}
var saveSlot = -1

var menu = "BOOT"

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

