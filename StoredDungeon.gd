extends Node

var dungeon = null
var dungeonSize: int = 6
var cellSize: int = 64
var dungeonVisualizerNode : Node
var dungeonMapNode: Node

var dungeonMapNodes = []

var playerSize
var playerPosX
var playerPosY
var showPlayer

func setDungeonVisualizer(node : Node):
	dungeonVisualizerNode = node

func getDungeonVisualizer():
	return dungeonVisualizerNode
	
func setDungeonMap(node : Node):
	dungeonMapNode = node
	
	
func getDungeonMap():
	return dungeonMapNode

func setDungeon(dungeonRef):
	dungeon = dungeonRef
	dungeonSize = dungeonRef.getSize()
	
func addDungeonMap(node : Node):
	dungeonMapNodes.append(node)
	
func removeNullBoards():
	for interactiveMap in dungeonMapNodes:
		if(!interactiveMap):
			dungeonMapNodes.erase(interactiveMap)
		elif !is_instance_valid(interactiveMap):
			dungeonMapNodes.erase(interactiveMap)
			

func setPlayer(showPlayer2, playerSize2, playerPosX2, playerPosY2):
	playerSize = playerSize2
	playerPosX = playerPosX2
	playerPosY = playerPosY2
	showPlayer = showPlayer2
	
	
