extends Node

var size: int
var grid: Array
var maximumRoomExits: int = 3
var maximumBigRooms: int = 3
var bigRooms: int = 0
var pathLengthMin: int
var pathLengthMax: int
var Room = preload("res://Room.gd")
var startRoom
var lastRoomChecked
var latestPathRooms = []
var previousDungeonState = []  # Stores the last successful dungeon state
@export var visualizer: Node2D

# For optimization debugging, checks how many times path was restarted in a session
var totalRestarts: int = 0
var maximumRestarts: int = 0

func createNewRoom(room, roomType, posX, posY):
	room.setRoomType(roomType)
	room.setPosition(posX, posY)

func makeGrid(dungeonSize:int):
	#print("Making grid")
	size = dungeonSize
	
	grid = []
	for i in range(size):
		grid.append([])
		for j in range(size):
			grid[i].append(null)
			grid[i][j] = Room.new()
			createNewRoom(grid[i][j], Room.RoomType.EMPTY, i, j)

func setRoomType(room, x, y, newRoomType):
	if room != null:
		room.setRoomType(newRoomType)
	elif x != null and y != null:
		grid[x][y].setRoomType(newRoomType)
	else:
		print("INVALID OPERATION FOR setRoomType()")

func getRoomType(x:int, y:int):
	return grid[x][y].getRoomType()

func getSize():
	return size

func getAllRoomsOfType(roomType):
	var matchingRooms = []
	
	for i in range(size):
		for j in range(size):
			if grid[i][j].getRoomType() == roomType:
				matchingRooms.append(grid[i][j])
	return matchingRooms

func getRandomRoomOfType(roomType):
	var matchingRooms = getAllRoomsOfType(roomType)
	return matchingRooms[randi() % matchingRooms.size()]

func pickRandomEmptyRoom():
	var emptyRooms = getAllRoomsOfType(Room.RoomType.EMPTY)
	
	#Gather all empty rooms
	#for i in range(size):
	#	for j in range(size):
	#		if grid[i][j].getRoomType() == Room.RoomType.EMPTY:
	#			emptyRooms.append(grid[i][j])
	
	if emptyRooms.size() > 0:
		return emptyRooms[randi() % emptyRooms.size()] #Return random empty room
	else:
		print("Error in pickRandomEmptyRoom(), no empty rooms exist")
		return null  # Return null if no empty rooms exist

func pickRandomEmptyRoomNoEdges():
	var emptyRooms = []
	
	#Gather all empty rooms
	for i in range(1, size-1, 1):
		for j in range(1, size-1, 1):
			if (grid[i][j].getRoomType() == Room.RoomType.EMPTY):
				emptyRooms.append(grid[i][j])
	
	if emptyRooms.size() > 0:
		return emptyRooms[randi() % emptyRooms.size()] #Return random empty room
	else:
		print("Error in pickRandomEmptyRoom(), no empty rooms exist")
		return null  # Return null if no empty rooms exist

func pickRandomBlankRoom():
	var blankRooms = getAllRoomsOfType(Room.RoomType.TEMP)
				
	if blankRooms.size() > 0:
		return blankRooms[randi() % blankRooms.size()] #Return random blank room
	else:
		print("Error in pickRandomBlankRoom(), no blank rooms exist")
		return null  # Return null if no blank rooms exist	

func pickRandomBlankRoomWithLimitedExits():
	var blankRooms = []
	
	#Gather all blank rooms
	for i in range(size):
		for j in range(size):
			if (grid[i][j].getRoomType() == Room.RoomType.TEMP && grid[i][j].getExitCount() < 3):
				blankRooms.append(grid[i][j])

	if blankRooms.size() > 0:
		return blankRooms[randi() % blankRooms.size()] #Return random blank room
	else:
		print("Error in pickRandomBlankRoom(), no blank rooms exist")
		return null  # Return null if no blank rooms exist	

func setRandomEmptyRoom(newRoomType):
	var room
	if(size > 3):
		room = pickRandomEmptyRoomNoEdges()
	else:
		room = pickRandomEmptyRoom()
	
	room.setRoomType(newRoomType)
	if(room.getRoomType() == Room.RoomType.START):
		setStartRoom(room)
	return(room)

func getRandomBlankRoomWithLimitedExits():
	var room = pickRandomBlankRoomWithLimitedExits()
	return(room)	

func getRandomBlankRoom():
	var room = pickRandomBlankRoom()
	return(room)	

func setStartRoom(room):
	room.setFoundByGenerator(true)
	startRoom = room
	

func determinePathLength(pathCount):
	
	@warning_ignore("integer_division")
	pathLengthMax = ((size * size / 2) + size/2)
	@warning_ignore("integer_division")
	pathLengthMin = ((size * size / 2) - size/2)
	pathLengthMin = min(pathLengthMin, 50)
	
	if(pathCount > 0):
		pathLengthMin = pathLengthMin / pathCount
		pathLengthMin = min(pathLengthMin, pathLengthMin / (pathCount*2))
	
	return

func resetAllRooms(ignoreStart):
	for row in grid:
		for room in row:
			if(ignoreStart):
				room.clearRoomState()
			elif(room != startRoom):
				room.clearRoomState()
			room.resetExits() # this is here otherwise start will not reset its exits if ignoreStart is true
	bigRooms = 0

func findPath():
	var directions = {}
	var foundPossiblePath: bool = true
	var foundValidPath: bool = false
	var currentRoom
	var pathLength: int = 0
	var restartCount: int = 0
	
	resetRoomExplorationStatus()
	
	while(!foundValidPath):
		currentRoom = startRoom
		pathLength = 0
		foundPossiblePath = true
		
		#Clear pathRooms array
		latestPathRooms.clear()
		latestPathRooms.append(currentRoom)
				
		while(foundPossiblePath):
			directions = findValidPath(currentRoom)
			pathLength += 1
			if(directions == {} || pathLength > pathLengthMax):
				foundPossiblePath = false
			else:
				currentRoom = movePathInRandomDirection(currentRoom, directions)
				if(currentRoom == null):
					break
				latestPathRooms.append(currentRoom)
				
		if(pathLengthMin <= pathLength && pathLength <= pathLengthMax): # found path
			foundValidPath = true
			#print("Saving dungeon state")
			saveCurrentDungeonState()
		else: # path not found and generator will try again
			#print("path length is not acceptable, length is ", pathLength)
			#print("should be between ", pathLengthMin, " and ", pathLengthMax)
			restartCount += 1
			totalRestarts += 1
			maximumRestarts = max(maximumRestarts, restartCount)
			
			if(restartCount > 32):
				#print("Could not not path at all. Choosing new position")
				return false
			
			#print("Path not found, restarting")
			
			if(loadPreviousDungeonState()):
				resetRoomExplorationStatus()
			else:
				resetAllRooms(false)
	return true

func movePathInRandomDirection(currentRoom, directions):
	# Mapping integer keys to direction strings
	var directionMap = {
		1: "N",  2: "NE", 3: "E",  4: "SE",
		5: "S",  6: "SW", 7: "W",  8: "NW"
	}
	
	if(currentRoom.getExitCount() > maximumRoomExits):
		print("Restarting generation due to disconnected room") # this should NEVER happen
		return null
	
	# Get a list of direction keys (1 to 8)
	var directionKeys = directions.keys()
		
	# If no valid directions, return immediately
	if directionKeys.size() == 0:
		print("No valid directions left")
		return currentRoom
	
	# Pick a random direction from the keys list
	var randomDirectionKey = directionKeys[randi() % directionKeys.size()]
	
	# Get the corresponding direction value
	var randomDirection = directions[randomDirectionKey]
	
	# Convert integer key to string direction
	var directionString = directionMap[randomDirectionKey]
	
	# Calculate the next room's position
	var nextRoomPosX = currentRoom.posX + randomDirection.x
	var nextRoomPosY = currentRoom.posY + randomDirection.y
	
	# Move to the new room
	var nextRoom = grid[nextRoomPosX][nextRoomPosY]
	
	# Make sure room has no more than three exits
	if nextRoom.getExitCount() < maximumRoomExits && currentRoom.getExitCount() < maximumRoomExits:
		#Populate Room
		if(currentRoom.getRoomType() == Room.RoomType.EMPTY):
			currentRoom.setRoomType(Room.RoomType.TEMP)
		if(nextRoom.getRoomType() == Room.RoomType.EMPTY):
			nextRoom.setRoomType(Room.RoomType.TEMP)
		
		#Set As Found
		currentRoom.setFoundByGenerator(true)
		nextRoom.setFoundByGenerator(true)
		
		#Set Room Exits
		currentRoom.setExit(directionString, true)
		nextRoom.setExit(getOppositeDirection(directionString), true)
		
		lastRoomChecked = nextRoom
	else:
		print("disconnected room detected for next room. retrying") # This should NEVER happen
		return null
	
	# Debugging output
	#print("Moving from (", currentRoom.posX, ", ", currentRoom.posY, ") to (", nextRoomPosX, ", ", nextRoomPosY, ") using direction ", randomDirectionKey)
	
	# return the new room
	return nextRoom

func getOppositeDirection(direction: String) -> String:
	var opposites = { "N": "S", "NE": "SW", "E": "W", "SE": "NW", 
					  "S": "N", "SW": "NE", "W": "E", "NW": "SE" }
	return opposites.get(direction, "INVALID") # Returns INVALID is something goes wrong. This should NOT happen

func checkPathBoundaryConstraints(currentRoom, directions):
	if(currentRoom.getPosY() == 0):
		directions.erase(1)
		directions.erase(2)
		directions.erase(8)
	if(currentRoom.getPosY() == size-1):
		directions.erase(4)
		directions.erase(5)
		directions.erase(6)
	if(currentRoom.getPosX() == 0):
		directions.erase(6)
		directions.erase(7)
		directions.erase(8)
	if(currentRoom.getPosX() == size-1):
		directions.erase(2)
		directions.erase(3)
		directions.erase(4)
	return(directions)

func eliminateExploredRooms(currentRoom, directions):
	var toRemove = []
	for key in directions.keys():
		var direction = directions[key]
		var checkRoomPosY = currentRoom.posY + direction.y
		var checkRoomPosX = currentRoom.posX + direction.x
		# Check if the room is explored before including it as a valid direction
		if(grid[checkRoomPosX][checkRoomPosY].isFoundByGenerator()):
			toRemove.append(key)
	for key in toRemove:
		directions.erase(key)
	return(directions)

func eliminateWallRooms(currentRoom, directions):
	var toRemove = []
	for key in directions.keys():
		var direction = directions[key]
		var checkRoomPosY = currentRoom.posY + direction.y
		var checkRoomPosX = currentRoom.posX + direction.x
		# Check if the room is explored before including it as a valid direction
		if(grid[checkRoomPosX][checkRoomPosY].roomType == Room.RoomType.WALL):
			toRemove.append(key)
	for key in toRemove:
		directions.erase(key)
	return(directions)	

func preventDiagonalPathsCrossing(currentRoom, directions):
	var toRemove = []
	
	# Check diagonals in current path
	for key in directions.keys():
		if key in [2, 4, 6, 8]:  # Only check diagonals (NE, SE, SW, NW)
			var direction = directions[key]
			var adjacentX = currentRoom.posX + direction.x
			var adjacentY = currentRoom.posY
			var adjacentRoomX = grid[adjacentX][adjacentY]

			var adjacentY2 = currentRoom.posY + direction.y
			var adjacentX2 = currentRoom.posX
			var adjacentRoomY = grid[adjacentX2][adjacentY2]

			# If both adjacent rooms have been explored, block the diagonal movement
			if adjacentRoomX.isFoundByGenerator() && adjacentRoomY.isFoundByGenerator():
				toRemove.append(key)
				
			# Double check if paths have crossed before
			if key in [2]:
				if(adjacentRoomX.hasExit("NW") || adjacentRoomY.hasExit("SE")):
					toRemove.append(key)
			if key in [4]:
				if(adjacentRoomX.hasExit("SW") || adjacentRoomY.hasExit("NE")):
					toRemove.append(key)
			if key in [6]:
				if(adjacentRoomX.hasExit("SE") || adjacentRoomY.hasExit("NW")):
					toRemove.append(key)
			if key in [8]:
				if(adjacentRoomX.hasExit("NE") || adjacentRoomY.hasExit("SW")):
					toRemove.append(key)

				
	for key in toRemove:
		directions.erase(key)			
	return(directions)

# Preventing connections between START, EXIT, and ARTIFACT rooms
func preventSpecialRoomConnections(currentRoom, directions):
	var toRemove = []

	for key in directions.keys():
		var direction = directions[key]
		
		# Calculate the adjacent room's position based on direction
		var adjacentX = currentRoom.posX + direction.x
		var adjacentY = currentRoom.posY + direction.y
		var adjacentRoom = grid[adjacentX][adjacentY]
		
		# Check if the adjacent room is a START, EXIT, or ARTIFACT
		if adjacentRoom.getRoomType() == Room.RoomType.START || adjacentRoom.getRoomType() == Room.RoomType.EXIT || adjacentRoom.getRoomType() == Room.RoomType.ARTIFACT:
			# If so, mark this direction to be removed
			toRemove.append(key)
	
	# Remove directions that lead to special rooms
	for key in toRemove:
		directions.erase(key)

	return directions

func limitRoomExits(currentRoom, directions):
	var toRemove = []
	
	var newMaximumRoomExits = maximumRoomExits
	
	# If we find a big room, count it
	if(currentRoom.getExitCount() == maximumRoomExits):
		bigRooms += 0 # don't bother with this atm
	
	# If the limit is reached, reduce max room size
	if(bigRooms >= maximumBigRooms):
		newMaximumRoomExits -= 1
		print("Maximum big room limit reached")
	
	# Check exits for current room
	if currentRoom.getExitCount() >= newMaximumRoomExits:
	# If current room is at maximum, only take paths that exist currently
		var acceptableExits = currentRoom.getExits()
		for key in directions.keys():
			var direction = directions[key]
			if !acceptableExits.has(direction):
				toRemove.append(key)
	
	# Check exits for next room
	for key in directions.keys():
		var direction = directions[key]
		
		# Calculate the adjacent room's position based on direction
		var adjacentX = currentRoom.posX + direction.x
		var adjacentY = currentRoom.posY + direction.y
		var adjacentRoom = grid[adjacentX][adjacentY]
		
		# Check if adjacent room already has max exits
		if adjacentRoom.getExitCount() >= newMaximumRoomExits:
			# If so, mark this direction to be removed
			# print("found room with too many exits at, ", adjacentX, ", ", adjacentY)
			toRemove.append(key)
		
	
	# Remove directions that would lead to, or create a room with too many exits
	for key in toRemove:
		directions.erase(key)
	
	return directions
	
func forceNewExit(currentRoom, directions):
	var toRemove = []
	
	# Eliminate already explored directions
	var acceptableExits = currentRoom.getExits()
	for key in directions.keys():
		var direction = directions[key]
		if acceptableExits.has(direction):
			toRemove.append(key)
	
	for key in toRemove:
		directions.erase(key)
		
	return directions

# Helper function to check if a room is within bounds
func isValidRoom(x, y):
	return x >= 0 and x < size and y >= 0 and y < size

# Get the opposite direction for X-axis movement
func getOppositeDirectionX(x):
	if x > 0:
		return "W"  # Moving right means check left
	elif x < 0:
		return "E"  # Moving left means check right
	return ""

# Get the opposite direction for Y-axis movement
func getOppositeDirectionY(y):
	if y > 0:
		return "N"  # Moving down means check up
	elif y < 0:
		return "S"  # Moving up means check down
	return ""

func findValidPath(currentRoom):
	var directions = {
	1: Vector2(0, -1), # N
	2: Vector2(1, -1), # NE
	3: Vector2(1, 0), # E
	4: Vector2(1, 1), # SE
	5: Vector2(0, 1), # S
	6: Vector2(-1, 1), # SW
	7: Vector2(-1, 0), # W
	8: Vector2(-1, -1), # NW
	}
	
	# Eliminate Boundaries
	directions = checkPathBoundaryConstraints(currentRoom, directions)	
	# Eliminate Explored Rooms
	directions = eliminateExploredRooms(currentRoom, directions)
	# Eliminates Wall Rooms
	directions = eliminateWallRooms(currentRoom, directions)
	# Prevent diagonal paths from crossing other diagonal paths
	directions = preventDiagonalPathsCrossing(currentRoom, directions)
	# Prevent rooms from having too many exits
	directions = limitRoomExits(currentRoom, directions)
	# Prevents START, EXIT, and ARTIFACT rooms connecting
	directions = preventSpecialRoomConnections(currentRoom, directions)
	
	# Force tile to produce a new exit
	if(currentRoom.roomType == Room.RoomType.START && currentRoom == startRoom):
		#print("adding extra path to start room")
		directions = forceNewExit(currentRoom, directions)
	
	return directions

func placeArtifact():
	# Ensure we have a valid path before placing the artifact
	if latestPathRooms.size() < 3:
		print("Path is too short for an artifact placement.") # this should NEVER happen
		return
	
	# Define a range around the midpoint for some variation (e.g., 40%-60% of the path)
	var lowerBound = int(latestPathRooms.size() * 0.4)
	var upperBound = int(latestPathRooms.size() * 0.6)
	
	# in case it's the tutorial dungeon
	if(size < 4):
		lowerBound = int(latestPathRooms.size() * 0.1)
		upperBound = int(latestPathRooms.size() * 0.9)
		
	
	# Get valid candidates from the middle section
	var validArtifactRooms = latestPathRooms.slice(lowerBound, upperBound)
	
	# Pick a random room from the middle section
	if validArtifactRooms.size() > 0:
		var artifactRoom = validArtifactRooms[randi() % validArtifactRooms.size()]
		artifactRoom.setRoomType(Room.RoomType.ARTIFACT)
		#print("Artifact placed at (", artifactRoom.posX, ", ", artifactRoom.posY, ")")
	else:
		print("No valid room for artifact placement.") # this should NEVER happen

func placeBoss():
	var artifactRooms = getAllRoomsOfType(Room.RoomType.ARTIFACT)
	var artifactRoom = artifactRooms[0]
	
	var connectedRooms = getConnectedRooms(artifactRoom)
	var foundRoom = false
	
	for room in connectedRooms:
		if(room.roomType == Room.RoomType.TEMP):
			room.setRoomType(Room.RoomType.BOSS)
			foundRoom = true
			break
	
	return foundRoom

func saveCurrentDungeonState():
	previousDungeonState.clear()
	for i in range(size):
		var rowState = []
		for j in range(size):
			var room = grid[i][j]
			rowState.append({
				"roomType": room.getRoomType(),
				"exits": room.exits.duplicate(true)
			})
		previousDungeonState.append(rowState)

func loadPreviousDungeonState():
	if previousDungeonState.is_empty():
		#print("No previous dungeon state saved!")
		return false
	
	for i in range(size):
		for j in range(size):
			var room = grid[i][j]
			var savedData = previousDungeonState[i][j]
			room.setRoomType(savedData["roomType"])
			room.exits = savedData["exits"].duplicate(true)
			
	return true

func resetRoomExplorationStatus():
	if previousDungeonState.is_empty():
		print("No previous dungeon state saved for room exploration clearing!")
		return
	
	for i in range(size):
		for j in range(size):
			var room = grid[i][j]
			@warning_ignore("unused_variable")
			var savedData = previousDungeonState[i][j]
			room.setFoundByGenerator(false)  # Reset exploration status

func getLastRoomChecked():
	return lastRoomChecked
	
func getTotalRestartCount():
	return totalRestarts

func getMaximumRestartCount():
	return maximumRestarts

func hasNearbyRoomType(room, types):
	types = types if typeof(types) == TYPE_ARRAY else [types]
	for neighbor in getConnectedRooms(room):
		if neighbor.roomType in types and not neighbor.isDead:
			return true
	return false


func populateRoomType(roomType, maxAmount):
	if maxAmount <= 0:
		return
	
	var room
	var startingRoom = getStartRoom()

	var maxAttempts = size * size
	var attempts: int = 0

	# Create a list of connected rooms starting from the start room
	var connectedRoomsToStart = getConnectedRooms(startingRoom)

	var checkForNearbyEnemies = roomType in [Room.RoomType.ENEMY, Room.RoomType.TELEPORTER_EXIT]
	var checkForNearbyTeleporters = roomType in [Room.RoomType.ENEMY, Room.RoomType.TELEPORTER_EXIT]
	var checkForEdge = roomType in [Room.RoomType.TELEPORTER_EXIT]


	
	for i in range(maxAmount):
		# Loop until you find a valid room that isn't connected to the start
		var validRoom = false
		while not validRoom and attempts < maxAttempts:
			room = getRandomBlankRoom()

			# Check if the room is connected to the start room (it must be in the list of connected rooms)
			if !connectedRoomsToStart.has(room):
				validRoom = true
				if(checkForNearbyEnemies):
					for checkForEnemy in getConnectedRooms(room):
						if(checkForEnemy.roomType == Room.RoomType.ENEMY or checkForEnemy.roomType == Room.RoomType.BOSS):
							validRoom = false

				if(checkForNearbyTeleporters):
					for checkForTeleporter in getConnectedRooms(room):
						if(checkForTeleporter.roomType == Room.RoomType.TELEPORTER_ENTRANCE || checkForTeleporter.roomType == Room.RoomType.TELEPORTER_EXIT):
							validRoom = false
							
				if(checkForEdge):
					if(room.posX == 0 || room.posY == 0 || room.posX == size-1 || room.posY == size-1):
						validRoom = false

				if(validRoom):
					# Set the room type if it is connected to the start room
					room.setRoomType(roomType)
					# Any room type can have an item more flexibility
					#setRandomItem(room)
					#validRoom = true  # Exit the loop and move to the next room

			attempts += 1
			if attempts >= maxAttempts:
				print("Max attempts reached, aborting population of room types.")
				break

func setRandomItem(room):
	room.setItemType(Room.ItemType.keys()[randi() % Room.ItemType.size()])

func getConnectedRooms(checkRoom) -> Array:
	var connectedRooms = []

	var exits = checkRoom.getExits()
	
	# Loop through all exits and append the connected rooms based on the direction
	for exit in exits:
		if(exit == "N"):
			connectedRooms.append(grid[checkRoom.getPosX()][checkRoom.getPosY() - 1])  # North
		elif(exit == "NE"):
			connectedRooms.append(grid[checkRoom.getPosX() + 1][checkRoom.getPosY() - 1])  # North-East
		elif(exit == "E"):
			connectedRooms.append(grid[checkRoom.getPosX() + 1][checkRoom.getPosY()])  # East
		elif(exit == "SE"):
			connectedRooms.append(grid[checkRoom.getPosX() + 1][checkRoom.getPosY() + 1])  # South-East
		elif(exit == "S"):
			connectedRooms.append(grid[checkRoom.getPosX()][checkRoom.getPosY() + 1])  # South
		elif(exit == "SW"):
			connectedRooms.append(grid[checkRoom.getPosX() - 1][checkRoom.getPosY() + 1])  # South-West
		elif(exit == "W"):
			connectedRooms.append(grid[checkRoom.getPosX() - 1][checkRoom.getPosY()])  # West
		elif(exit == "NW"):
			connectedRooms.append(grid[checkRoom.getPosX() - 1][checkRoom.getPosY() - 1])  # North-West
	
	return connectedRooms

func getAdjacentRoom(room, direction: String):
	
	var adjacentRoom
	# Check adjacent room based on the direction
	match direction:
		# Cardinal directions
		"N":
			adjacentRoom = grid[room.posX][room.posY - 1] if room.posY > 0 else null
		"S":
			adjacentRoom = grid[room.posX][room.posY + 1] if room.posY < size - 1 else null
		"E":
			adjacentRoom = grid[room.posX + 1][room.posY] if room.posX < size - 1 else null
		"W":
			adjacentRoom = grid[room.posX - 1][room.posY] if room.posX > 0 else null

		# Diagonal directions
		"NE":
			adjacentRoom = grid[room.posX + 1][room.posY - 1] if room.posX < size - 1 and room.posY > 0 else null
		"SE":
			adjacentRoom = grid[room.posX + 1][room.posY + 1] if room.posX < size - 1 and room.posY < size - 1 else null
		"SW":
			adjacentRoom = grid[room.posX - 1][room.posY + 1] if room.posX > 0 and room.posY < size - 1 else null
		"NW":
			adjacentRoom = grid[room.posX - 1][room.posY - 1] if room.posX > 0 and room.posY > 0 else null
	
	return adjacentRoom

func getStartRoom():
	return findRoom(Room.RoomType.START)

func findRoom(roomType):
	for i in range(size):
		for j in range(size):
			if grid[i][j].getRoomType() == roomType:
				return grid[i][j]
	print(roomType, " room does not exist") # this should NEVER happen
	return null	

func randomizeRoomParameters(enemyStrength):
	# Put values up here to keep stats consistent across the dungeon
	#var enemyStrength = 6  # How powerful an enemy is
	var randomHealth = (enemyStrength / 2) + randi() % (enemyStrength - (enemyStrength / 2))  # Health varies
	var randomDamage = enemyStrength - randomHealth  # Damage is complementary
	
	#Randomly swap values to avoid predictable patterns
	if randi() % 2 == 0:
		var temp = randomHealth
		randomHealth = randomDamage
		randomDamage = temp
		
	randomHealth = max(randomHealth, 2)
	randomDamage = min(randomDamage, 4)
	
	# For weighting values a bit more
	var weightedValues = [2, 3, 3, 3, 4, 4] # 1/6 chance of 1, 2/6 chance of 3, 3/6 chance of 2
	
	for row in grid:
		for room in row:
			room.health = randomHealth
			room.attack = randomDamage
			room.potionStrength = 1 + randi() % 3
			room.weaponStrength = weightedValues[randi() % weightedValues.size()]
			room.shopPrice = 2 + randi() % 3
			room.gold = 2 + randi() % 4
			room.setRandomWeapon()
			room.setRandomEnemy()
			setRandomItem(room)
			if(room.roomType == Room.RoomType.BOSS):
				room.addBossBonus()
	return

func generateWarnings():
	# First set all to false by default
	for row in grid:
		for room in row:
			room.setNearMimic(false)
			room.setNearEnemy(false)
			room.nearTeleporter = false
			room.nearBoss = false
	
	for row in grid:
		for room in row:
			room.setNearMimic(hasNearbyRoomType(room, [Room.RoomType.MIMIC]))
			room.setNearEnemy(hasNearbyRoomType(room, [Room.RoomType.ENEMY]))
			room.nearTeleporter = hasNearbyRoomType(room, [Room.RoomType.TELEPORTER_ENTRANCE])
			room.nearBoss = hasNearbyRoomType(room, [Room.RoomType.BOSS])

func countRoomOfType(roomType):
	var count = 0
	
	for row in grid:
		for room in row:
			if(room.roomType == roomType):
				count += 1
				
	return count

func swapRooms(room1, room2):
	var storeRoom1 = room1.copyRoom()
	var storeRoom2 = room2.copyRoom()
	
	# Swap all room data
	grid[room1.posX][room1.posY] = storeRoom2.copyRoom()
	grid[room2.posX][room2.posY] = storeRoom1.copyRoom()
	
	# Conserve Coords and Exits
	grid[room1.posX][room1.posY].setExits(room1.getExitDictionary())
	grid[room2.posX][room2.posY].setExits(room2.getExitDictionary())
	
	grid[room1.posX][room1.posY].setPosition(room1.posX, room1.posY)
	grid[room2.posX][room2.posY].setPosition(room2.posX, room2.posY)
