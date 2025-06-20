extends Node2D

var dungeon
var Room = preload("res://Room.gd")
var RoomTextureHelper = preload("res://RoomTextureHelper.gd").new()
var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()
var WindowHelper = preload("res://WindowHelper.gd").new()
var SceneFadeHelper = preload("res://SceneFadeHelper.gd").new()
var SaveGameHelper = preload("res://SaveGameHelper.gd").new()

@onready var menuContainer = $"RoomSymbols"

var posX: int = 0
var posY: int = 0
var exploredRooms = []

var showPlayerStats: bool = false
var showPlayer: bool = true

enum Class {ARCHIVIST, SCOUT, APPRAISER, SERFS, TRAPPER, FUGITIVE}

var characterClass = Class.TRAPPER

var startGold: int = 10
var startHealth: int = 10
var startArmor: int = 1 # chance to block damage
var startAgility: int = 2 # chance to dodge damage
var startAttack: int = 2 # attack bonus is calculated on hit
var startLives: int = 1 # used for classes that have multiple characters
var startWeapon = Room.WeaponType.SWORD
var maxHealth: int = 20

var gold
var health
var armor
var attack
var agility
var weapon
var lives
var effect = "NONE"
var abilityCooldown: int = 2
var currentCooldown: int = 0
var statusEffectCooldown: int = 0
var luck: float = 0
var hasArtifact: bool = false
var inCombat: bool = false
var moveCount = 0

var previousRoom # keep track of previous room for fleeing purposes


# Visualization stuff
var dotColor: Color = Color(0.2, 0.2, 0.2)
var dotColorOutline: Color = Color(0.8, 0.8, 0.8)
var playerSize: int = 10

#Textures
var emptyIcon = preload("res://TemporaryIcons/empty_icon.png")


# Icons
var hurtTexture = preload("res://TemporaryIcons/hurt.png")
var dodgeTexture = preload("res://TemporaryIcons/dodge.png")
var coinTexture = preload("res://TemporaryIcons/coin.png")
var coinDisplayTexture = preload("res://TemporaryIcons/coin_display.png")
var attackStrengthTexture = preload("res://TemporaryIcons/attack_strength.png")
var enemyHealthTexture = preload("res://TemporaryIcons/enemy_health.png")
var enemyHealthTexture2 = preload("res://TemporaryIcons/enemy_health2.png")
var enemyHealthTexture3 = preload("res://TemporaryIcons/enemy_health3.png")

# Empty Rooms
var emptyRoomTexture = preload("res://TemporaryIcons/empty_room.png")
var bossWarningTexture = preload("res://TemporaryIcons/boss_warning.png")
var enemyWarningTexture = preload("res://TemporaryIcons/enemy_warning.png")
var mimicWarningTexture = preload("res://TemporaryIcons/mimic_warning.png")
var teleporterWarningTexture = preload("res://TemporaryIcons/teleporter_warning.png")

# Actions
var fleeTexture = preload("res://TemporaryIcons/flee.png")
var breakItemTexture = preload("res://TemporaryIcons/destroy_item.png")
var stealTexture = preload("res://TemporaryIcons/steal.png")
var digTexture = preload("res://TemporaryIcons/dig.png")

# Abilities
var scoutTexture = preload("res://TemporaryIcons/scout.png")
var scoutCooldownTexture = preload("res://TemporaryIcons/scout_cooldown.png")
var appraiseTexture = preload("res://TemporaryIcons/appraise.png")
var disarmTexture = preload("res://TemporaryIcons/disarm.png")
var disarmCooldownTexture = preload("res://TemporaryIcons/disarm_cooldown.png")
var autofillTexture = preload("res://TemporaryIcons/autofill.png")

# Kill Self Button
var destroyTexture = preload("res://TemporaryIcons/destroy.png")

# Status
var deathTexture = preload("res://TemporaryIcons/death.png")
var reviveTexture = preload("res://TemporaryIcons/revive.png")

# Arrows
var arrowTextureN = preload("res://TemporaryIcons/arrowN.png")
var arrowTextureNE = preload("res://TemporaryIcons/arrowNE.png")
var arrowTextureE = preload("res://TemporaryIcons/arrowE.png")
var arrowTextureSE = preload("res://TemporaryIcons/arrowSE.png")
var arrowTextureS = preload("res://TemporaryIcons/arrowS.png")
var arrowTextureSW = preload("res://TemporaryIcons/arrowSW.png")
var arrowTextureW = preload("res://TemporaryIcons/arrowW.png")
var arrowTextureNW = preload("res://TemporaryIcons/arrowNW.png")
var arrowEmptyTexture = preload("res://TemporaryIcons/arrow_empty.png")

var arrowHoveredN = preload("res://TemporaryIcons/arrowN_hovered.png")
var arrowHoveredNE = preload("res://TemporaryIcons/arrowNE_hovered.png")
var arrowHoveredE = preload("res://TemporaryIcons/arrowE_hovered.png")
var arrowHoveredSE = preload("res://TemporaryIcons/arrowSE_hovered.png")
var arrowHoveredS = preload("res://TemporaryIcons/arrowS_hovered.png")
var arrowHoveredSW = preload("res://TemporaryIcons/arrowSW_hovered.png")
var arrowHoveredW = preload("res://TemporaryIcons/arrowW_hovered.png")
var arrowHoveredNW = preload("res://TemporaryIcons/arrowNW_hovered.png")

var emptySlot = preload("res://TemporaryIcons/empty_slot.png")
var emptySlot2 = preload("res://TemporaryIcons/empty_slot_2.png")

var emptyAttribute = preload("res://TemporaryIcons/empty_attribute.png")
var attributeContainer1 = preload("res://TemporaryIcons/attribute_container_1.png")
var attributeContainer2 = preload("res://TemporaryIcons/attribute_container_2.png")

# Menu Buttons
var roomButton
var itemButton
var auxItemButton
var abilityButtons = []
var deathButton
var statusEffectButton

# Arrows
var arrowButtonN
var arrowButtonNE
var arrowButtonE
var arrowButtonSE
var arrowButtonS
var arrowButtonSW
var arrowButtonW
var arrowButtonNW

# Attribute Displays
var healthIcons = []
var abilityIcons = []
var goldIcons = []
var goldBackground
var abilityBackground
var healthBackground

func _ready():
	StoredElements.setPlayer(self)
	setClassStats()
	resetPlayerStats()
	drawMenu()
	
	var viewport_size = get_parent().size
	var menu_size = Vector2(get_parent().size.x, get_parent().size.y)
	get_node("RoomSymbols").position = Vector2(128, 128)

	startGame()
	
func _input(event):
	WindowHelper.allowCheatInputs(event)
		

func startGame():
	
	#AudioManager.get_node("Sounds/GameStart").play()
	await get_tree().process_frame
	StoredElements.windowManager.openSeverenceWindows()
	
	StoredElements.gold -= StoredElements.wager
	StoredElements.gold = max(StoredElements.gold, 0)
	
	await get_tree().process_frame
	
	StoredElements.dungeonGenerator.difficulty = StoredElements.difficulty
	generateNewDungeon()
	updateCharacterStats(StoredElements.classId, StoredElements.wager)
	
	
	if(StoredElements.weaponIndex > -1):
		updateCharacterWeapon(StoredElements.weapons[StoredElements.weaponIndex], StoredElements.weaponStrengths[StoredElements.weaponIndex])
		StoredElements.weapons[StoredElements.weaponIndex] = -1
	StoredElements.weaponIndex = -1
	
	updatePlayerSymbols()
	
	$"../../../Map/PanelContainer/InteractiveMap".generateNewMap()
	
	#StoredDungeon.removeNullBoards()
	#if(StoredDungeon.dungeonMapNodes.size() > 0):
	#	for interactiveMap in StoredDungeon.dungeonMapNodes:
	#		if(interactiveMap && is_instance_valid(interactiveMap)):
	#			interactiveMap.clearBoard()	

func resetPlayerStats():
	health = startHealth
	armor = startArmor
	agility = startAgility
	@warning_ignore("integer_division")
	gold = startGold / startLives # multiple characters will divvy up their gold
	attack = startAttack
	lives = startLives
	weapon = startWeapon
	exploredRooms = []
	hasArtifact = false
	currentCooldown = 0
	statusEffectCooldown = 0
	luck = 0
	moveCount = 0

func setClassStats():
	if(characterClass == Class.ARCHIVIST):
		startHealth = 10
		maxHealth = 20
		startArmor = 0
		startAgility = 3
		startAttack = 3
		startLives = 1
		abilityCooldown = 0
		startWeapon = Room.WeaponType.SWORD
	elif(characterClass == Class.SCOUT):
		startHealth = 10
		maxHealth = 20
		startArmor = 0
		startAgility = 3
		startAttack = 3
		startLives = 1
		abilityCooldown = 2
		startWeapon = Room.WeaponType.SWORD
	elif(characterClass == Class.APPRAISER):
		startHealth = 10
		maxHealth = 20
		startArmor = 0
		startAgility = 3
		startAttack = 3
		startLives = 1
		abilityCooldown = 0
		startWeapon = Room.WeaponType.HAMMER
	elif(characterClass == Class.SERFS):
		startHealth = 5
		maxHealth = 15
		startArmor = 0
		startAgility = 3
		startAttack = 3
		startLives = 4
		abilityCooldown = 0
		startWeapon = Room.WeaponType.PICKAXE
	elif(characterClass == Class.TRAPPER):
		startHealth = 10
		maxHealth = 20
		startArmor = 0
		startAgility = 3
		startAttack = 3
		startLives = 1
		abilityCooldown = 2
		startWeapon = Room.WeaponType.SWORD
	elif(characterClass == Class.FUGITIVE):
		startHealth = 10
		maxHealth = 20
		startArmor = 0
		startAgility = 5
		startAttack = 2
		startLives = 1
		abilityCooldown = 0
		startWeapon = Room.WeaponType.SHORTSWORD
	
func generateNewDungeon():
	StoredElements.dungeonGenerator.startDungeonGeneration()
	spawnPlayer()
	
func updateCharacterStats(newClass, wager):
	characterClass = newClass
	startGold = wager
	setClassStats()
	resetPlayerStats()
	
func updateCharacterWeapon(newWeapon, weaponStr):
	weapon = newWeapon
	attack = weaponStr
	

func spawnPlayer():
	resetPlayerStats()
	movePlayerToRoom(Room.RoomType.START)
	StoredDungeon.setPlayer(showPlayer, playerSize, posX, posY)
	if StoredDungeon.getDungeonVisualizer() != null:
		StoredDungeon.getDungeonVisualizer().redraw()
	updatePlayerSymbols()
	drawMenu()
	return

func newLife():
	lives -= 1
	health = startHealth
	attack = startAttack
	@warning_ignore("integer_division")
	gold = startGold / startLives
	movePlayerToRoom(Room.RoomType.START)
	# for now, the artifact will teleport to its original position
	hasArtifact = false
	var artifactRoom = dungeon.findRoom(Room.RoomType.ARTIFACT)
	artifactRoom.isDead = false
	redrawEverything()

func movePlayerToRoom(roomType):
	for row in dungeon.grid:
		for room in row:
			if(room.getRoomType() == roomType):
				posX = room.getPosX()
				posY = room.getPosY()
				isInNewRoom(room)
				return
	
	print("No valid room to move player to") # should ideally never happen
	return null

func movePlayerToPosition(x, y):
	previousRoom = dungeon.grid[posX][posY] # save previous position
	inCombat = false
	posX = x
	posY = y
	var newRoom = dungeon.grid[posX][posY]
	isInNewRoom(newRoom)

func killPlayer():
	if(lives > 1):
		roomButton.texture_normal = reviveTexture
		roomButton.texture_hover = reviveTexture
		roomButton.connect("pressed", newLife.bind())
	else:
		roomButton.texture_normal = deathTexture
		roomButton.texture_hover = deathTexture
		roomButton.connect("pressed", returnToMenu.bind())
		
	AudioManager.get_node("Sounds/Death").play()

func getRewards(goldAmount, hasArtifact):
	StoredElements.gold += goldAmount
	if(hasArtifact):
		StoredElements.artifactCount += 1
		if(StoredElements.isHighestDifficulty()):
			print("is highest difficulty!")
			StoredElements.highestDifficultyWinCount += 1
			
	StoredElements.updateUnlocks()
	SaveGameHelper.saveGame(StoredElements.saveSlot)
	
	StoredElements.winGold = gold
	StoredElements.winArtifact = hasArtifact
	StoredElements.winWeapon = weapon
	StoredElements.winWeaponDamage = attack

func win():	
	AudioManager.get_node("Sounds/Win").play()
	getRewards(gold, hasArtifact)
	StoredElements.windowManager.closeSeverenceWindows()
	SaveGameHelper.saveGame(StoredElements.saveSlot)
	SceneFadeHelper.fadeScene(StoredElements.windowManager, null, "res://MenuUI/victory_menu.tscn", 1)

func returnToMenu():
	AudioManager.get_node("Sounds/ButtonClick").play()
	StoredElements.winGold = gold
	StoredElements.winArtifact = hasArtifact
	StoredElements.winWeapon = weapon
	StoredElements.winWeaponDamage = attack
	#StoredElements.master.updateMenu()
	SaveGameHelper.saveGame(StoredElements.saveSlot)
	StoredElements.windowManager.closeSeverenceWindows()
	SceneFadeHelper.fadeScene(StoredElements.windowManager, null, "res://MenuUI/defeat_screen.tscn", 1)
	#StoredElements.windowManager.openMasterWindow()

func setDungeon(newDungeon):
	dungeon = newDungeon

func createMenuButton(texture, pos):
	var button = TextureButton.new()
	button.texture_normal = texture
	button.position = pos
	menuContainer.add_child(button)
	return button

func drawMenu():
	# Room
	roomButton = MenuMakerHelper.createSimpleButton(emptyIcon, null, Vector2(0, 0), menuContainer)
	
	# Arrows
	arrowButtonN = MenuMakerHelper.createSimpleButton(arrowEmptyTexture, arrowEmptyTexture, Vector2(44 , -48), menuContainer)
	arrowButtonNE = MenuMakerHelper.createSimpleButton(arrowEmptyTexture, arrowEmptyTexture, Vector2(108 , -20), menuContainer)
	arrowButtonE = MenuMakerHelper.createSimpleButton(arrowEmptyTexture, arrowEmptyTexture, Vector2(136 , 48), menuContainer)
	arrowButtonSE = MenuMakerHelper.createSimpleButton(arrowEmptyTexture, arrowEmptyTexture, Vector2(108 , 108), menuContainer)
	arrowButtonS = MenuMakerHelper.createSimpleButton(arrowEmptyTexture, arrowEmptyTexture, Vector2(44 , 136), menuContainer)
	arrowButtonSW = MenuMakerHelper.createSimpleButton(arrowEmptyTexture, arrowEmptyTexture, Vector2(-20 , 108), menuContainer)
	arrowButtonW = MenuMakerHelper.createSimpleButton(arrowEmptyTexture, arrowEmptyTexture, Vector2(-48 , 48), menuContainer)
	arrowButtonNW = MenuMakerHelper.createSimpleButton(arrowEmptyTexture, arrowEmptyTexture, Vector2(-20 , -20), menuContainer)
	
	# Items
	itemButton = MenuMakerHelper.createSimpleButton(emptySlot, null, Vector2(-84, -72), menuContainer)
	auxItemButton = MenuMakerHelper.createSimpleButton(RoomTextureHelper.getWeaponTexture(weapon), null, Vector2(-105, -92), menuContainer)
	auxItemButton.scale = Vector2(0.5, 0.5)
	
	abilityButtons = []
	# Abilities
	for i in 3:
		var abilityButtonPos
		match i:
			0:
				abilityButtonPos = Vector2(176, -16)
			1:
				abilityButtonPos = Vector2(208, 36)
			2:
				abilityButtonPos = Vector2(176, 88)
		abilityButtons.append(MenuMakerHelper.createSimpleButton(emptySlot, null, abilityButtonPos, menuContainer))

	# Active Status Effect
	#statusEffectButton = MenuMakerHelper.createSimpleButton(emptySlot2, null, Vector2(224, -92), menuContainer)
	
	# Death Button
	#deathButton = createMenuButton(destroyTexture, Vector2(224, 192))
	#deathButton.connect("pressed", killPlayer.bind())
	#deathButton.connect("mouse_entered", hoverButton.bind(deathButton))
	#deathButton.connect("mouse_exited", unhoverButton.bind(deathButton))
	
	# Gold Display
	if(StoredElements.difficulty > 1):
		goldBackground = MenuMakerHelper.createSimpleButton(attributeContainer2, null, Vector2(-124, -20), menuContainer)
		goldIcons = createAttributeIcons(Vector2(-124 + 4, -20), 5, false)

	# Health/Damage Display
	healthBackground = MenuMakerHelper.createSimpleButton(attributeContainer1, null, Vector2(-28, -108), menuContainer)
	healthIcons = createAttributeIcons(Vector2(-28, -108 + 4), 5, true)

	# Ability Display
	if characterClass == Class.SCOUT or characterClass == Class.APPRAISER:
		abilityBackground = MenuMakerHelper.createSimpleButton(attributeContainer1, null, Vector2(-28, 188), menuContainer)
		abilityIcons = createAttributeIcons(Vector2(-28, 188 + 4), 5, true)


func createAttributeIcons(startPos, count, isHorizontal):
	var icons = []
	for i in range(1, count + 1):
		var pos
		if(isHorizontal):
			pos = Vector2(startPos.x + (i * 4) + ((i - 1) * 32), startPos.y)
		else:
			pos = Vector2(startPos.x, startPos.y + (i * 4) + ((i - 1) * 32))
		icons.append(MenuMakerHelper.createSimpleButton(emptyAttribute, null, pos, menuContainer))
	return icons

func updatePlayerSymbols():
	# Get Current Room
	var currentRoom = dungeon.grid[posX][posY]
	AudioManager.get_node("Sounds/ButtonClick").play()
	
	MenuMakerHelper.clearMenu(menuContainer)
	
	# Re-draw menu
	drawMenu()
	
	roomButton.texture_normal = RoomTextureHelper.getRoomTexture(currentRoom)
	roomButton.connect("mouse_entered", hoverButton.bind(roomButton))
	roomButton.connect("mouse_exited", unhoverButton.bind(roomButton))
	
	# Kill player if out of health
	if(health <= 0):
		killPlayer()
		return
		
	match currentRoom.getRoomType():
		
		Room.RoomType.TEMP:
			if(weapon == Room.WeaponType.PICKAXE && !currentRoom.secretRevealed):
				abilityButtons[2].texture_normal = digTexture
				abilityButtons[2].connect("pressed", dig.bind(currentRoom))
			
			if(currentRoom.secretRevealed && currentRoom.hasItem):
				roomButton.connect("pressed", getItem.bind(currentRoom))
				showItem(currentRoom)
		
		Room.RoomType.EXIT:
			roomButton.connect("pressed", win.bind())
			
		Room.RoomType.SHOP:
			if(currentRoom.hasPaid):
				roomButton.connect("pressed", getItem.bind(currentRoom))
			elif(currentRoom.hasItem):
				roomButton.connect("pressed", pay.bind(currentRoom))
				
			if(currentRoom.hasItem):
				showItem(currentRoom)
				if(!currentRoom.hasPaid):
					if(!currentRoom.secretRevealed):
						abilityButtons[2].texture_normal = stealTexture
						abilityButtons[2].connect("pressed", steal.bind(currentRoom))
					displayPrice(currentRoom)
		
		Room.RoomType.ITEM:
			if(currentRoom.hasItem):
				roomButton.connect("pressed", getItem.bind(currentRoom))
				showItem(currentRoom)
				if(!currentRoom.isDead) and StoredElements.difficulty > 3:
					abilityButtons[2].texture_normal = breakItemTexture
					abilityButtons[2].connect("pressed", destroyItem.bind(currentRoom))
		
		Room.RoomType.TELEPORTER_ENTRANCE:
			roomButton.connect("pressed", teleportToExit.bind(currentRoom))
			
		Room.RoomType.TELEPORTER_EXIT:
			var teleporters = dungeon.getAllRoomsOfType(Room.RoomType.TELEPORTER_ENTRANCE)
			if(teleporters.size() > 0):
				for teleporter in teleporters:
					if(!teleporter.isDead):
						roomButton.connect("pressed", disarmTeleporters.bind())
						break
			

		Room.RoomType.ENEMY:
			if(currentRoom.isDead):
				if(currentRoom.hasItem && currentRoom.isDead):
					showItem(currentRoom)
					roomButton.connect("pressed", getItem.bind(currentRoom))
			else:
				abilityButtons[2].texture_normal = fleeTexture
				abilityButtons[2].connect("pressed", flee.bind())
				if(characterClass == Class.FUGITIVE && !inCombat):
					inCombat = true
				else:
					enemyAttack(currentRoom.dealDamage(), currentRoom.enemyType, false)
				roomButton.connect("pressed", attackEnemy.bind(currentRoom))
				
		Room.RoomType.BOSS:
			if(currentRoom.isDead):
				if(currentRoom.hasItem && currentRoom.isDead):
					showItem(currentRoom)
					roomButton.connect("pressed", getItem.bind(currentRoom))
			else:
				abilityButtons[2].texture_normal = fleeTexture
				abilityButtons[2].connect("pressed", flee.bind())
				enemyAttack(currentRoom.dealDamage(), currentRoom.enemyType, true)
				roomButton.connect("pressed", attackEnemy.bind(currentRoom))

		Room.RoomType.ARTIFACT:
			if(!currentRoom.isDead):
				roomButton.connect("pressed", getArtifact.bind(currentRoom))
	
		Room.RoomType.MIMIC:
			if(!currentRoom.isDead):
				if(currentRoom.secretRevealed):
					roomButton.connect("pressed", killMimic.bind(currentRoom))
				else:
					abilityButtons[2].texture_normal = breakItemTexture
					abilityButtons[2].connect("pressed", destroyItem.bind(currentRoom))
					roomButton.connect("pressed", revealMimic.bind(currentRoom))
					if(characterClass != Class.TRAPPER):
						showItem(currentRoom)
				
		
		
		Room.RoomType.SWAPPER:
			roomButton.connect("pressed", swapRoom.bind(currentRoom))
		
		Room.RoomType.SOOTHSAYER:
			roomButton.connect("pressed", soothsayer.bind(currentRoom))
			
		Room.RoomType.HEALTH_ROOM:
			if(currentRoom.isDead == false):
				roomButton.connect("pressed", showPlayerHealth.bind(currentRoom))
		
	# Stop Player Movement if Needed
	if(!currentRoom.restrictPlayerMovement()):
		createArrowButtons(currentRoom)
	
	# Abilities
	setAbilityButtons(currentRoom)
	
	return
	
func hoverButton(button):
	var tween = create_tween()
	if button.get_signal_connection_list("pressed"):
		tween.tween_property(button, "modulate", Color(2, 2, 2, 1), 0.1)

func unhoverButton(button):
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0, 1), 0.2)
	
func setAbilityButtons(currentRoom):
	#if(currentCooldown > 0):
	#	return

	for entry in abilityButtons:
		entry.connect("mouse_entered", hoverButton.bind(entry))
		entry.connect("mouse_exited", unhoverButton.bind(entry))

	# Scout
	if(characterClass == Class.SCOUT):
		if(currentCooldown <= 0):
			abilityButtons[0].texture_normal = scoutTexture
			abilityButtons[0].connect("pressed", scout.bind(currentRoom))
		else:
			abilityButtons[0].texture_normal = scoutCooldownTexture

	# Appraise
	elif(characterClass == Class.APPRAISER):
		var canAppraise = false
		
		var appraisableRoomTypes = [
			Room.RoomType.BOSS,
			Room.RoomType.ENEMY,
			Room.RoomType.SHOP,
			Room.RoomType.ITEM,
			Room.RoomType.MIMIC
		]
		
		var appraisableItemTypes = [
			"HEALTH_POTION",
			"WEAPON",
			"GOLD"
		]
		
		if currentRoom.roomType in appraisableRoomTypes:
			if (currentRoom.roomType == Room.RoomType.ENEMY or currentRoom.roomType == Room.RoomType.BOSS) and !currentRoom.isDead:
				canAppraise = true
			elif (currentRoom.hasItem and currentRoom.itemType in appraisableItemTypes):
				canAppraise = true
		elif currentRoom.roomType == Room.RoomType.TEMP and currentRoom.hasItem and currentRoom.secretRevealed:
			canAppraise = true
		
		if canAppraise:
			abilityButtons[0].texture_normal = appraiseTexture
			abilityButtons[0].connect("pressed", appraise.bind(currentRoom))

	# Disarm
	elif(characterClass == Class.TRAPPER):
		if(!currentRoom.isDead):
			if(currentRoom.roomType == Room.RoomType.TELEPORTER_ENTRANCE || currentRoom.roomType == Room.RoomType.SWAPPER):
				if(currentCooldown <= 0):
					abilityButtons[0].texture_normal = disarmTexture
					abilityButtons[0].connect("pressed", disarm.bind(currentRoom))
				else:
					abilityButtons[0].texture_normal = disarmCooldownTexture

	elif(characterClass == Class.ARCHIVIST):
		abilityButtons[0].texture_normal = autofillTexture
		abilityButtons[0].connect("pressed", autofillMap.bind(currentRoom))
	
	

func createArrowButtons(currentRoom):
	# Define arrow directions and their corresponding buttons
	var arrowButtons = {
		"N": arrowButtonN, "NE": arrowButtonNE, "E": arrowButtonE, "SE": arrowButtonSE,
		"S": arrowButtonS, "SW": arrowButtonSW, "W": arrowButtonW, "NW": arrowButtonNW
	}
	var arrowTextures = {
		"N": arrowTextureN, "NE": arrowTextureNE, "E": arrowTextureE, "SE": arrowTextureSE,
		"S": arrowTextureS, "SW": arrowTextureSW, "W": arrowTextureW, "NW": arrowTextureNW
	}
	var arrowHoverTextures = {
		"N": arrowHoveredN, "NE": arrowHoveredNE, "E": arrowHoveredE, "SE": arrowHoveredSE,
		"S": arrowHoveredS, "SW": arrowHoveredSW, "W": arrowHoveredW, "NW": arrowHoveredNW
	}
	# Assign textures and connect buttons dynamically
	for direction in arrowButtons.keys():
		if currentRoom.hasExit(direction):
			var button = arrowButtons[direction]
			button.texture_normal = arrowTextures[direction]
			button.texture_hover = arrowHoverTextures[direction]
			button.connect("pressed", movePlayer.bind(direction))
	

func destroyItem(currentRoom):
	if(currentRoom.roomType == Room.RoomType.ITEM):
		AudioManager.get_node("Sounds/BreakItem").play()
		currentRoom.hasItem = false
	elif(currentRoom.roomType == Room.RoomType.MIMIC):
		AudioManager.get_node("Sounds/DefeatEnemy").play()
		currentRoom.roomType = Room.RoomType.ITEM
		currentRoom.secretRevealed = true
	currentRoom.isDead = true
	redrawEverything()
	return

func movePlayer(direction: String):
	var direction_map = {
		"N": Vector2(0, -1),
		"NE": Vector2(1, -1),
		"E": Vector2(1, 0),
		"SE": Vector2(1, 1),
		"S": Vector2(0, 1),
		"SW": Vector2(-1, 1),
		"W": Vector2(-1, 0),
		"NW": Vector2(-1, -1)
	}
	
	if direction in direction_map:
		var movement = direction_map[direction]
		movePlayerToPosition(posX + movement.x, posY + movement.y)

	moveCount += 1
	redrawEverything()

func getDamageBlocked():
	var base = armor / 4
	var remainder = armor % 4
	
	if remainder == 0:
		return base
	
	var chance = remainder * 0.25
	return base + int(randf() < chance)


func takeDamage(damage):
	
	AudioManager.get_node("Sounds/TakeDamage").play()
	
	# Armor
	damage = damage - getDamageBlocked()
	
	damage = min(damage, 5) # just in case damage goes out of bounds
	damage = max(damage, 1) # just in case damage goes out of bounds
	for i in damage:
		healthIcons[i].texture_normal = hurtTexture
	health -= damage
	
	var tween = create_tween()
	tween.tween_property(healthBackground, "modulate", Color(1, 0.2, 0.2, 1), 0.1)
	await tween.finished
		
	tween = create_tween()
	tween.tween_property(healthBackground, "modulate", Color(1, 1, 1, 1), 0.5)
	await tween.finished
	

func miss():
	AudioManager.get_node("Sounds/Dodge").play()
	
	for i in healthIcons.size():
		healthIcons[i].texture_normal = dodgeTexture
		
	var tween = create_tween()
	tween.tween_property(healthBackground, "modulate", Color(0.2, 0.2, 1, 1), 0.1)
	await tween.finished
		
	tween = create_tween()
	tween.tween_property(healthBackground, "modulate", Color(1, 1, 1, 1), 0.5)
	await tween.finished
	
	return

# Enemy attacks
func enemyAttack(damage, enemyType, isBoss):
	var precision = 0.0
	if(isBoss):
		precision = 5.0
	else:
		if(enemyType == Room.EnemyType.BASIC):
			precision = 4.0
		elif(enemyType == Room.EnemyType.UNDEAD):
			precision = 2.0
	
	var missChance = clamp((float(agility) - precision) * 0.1, 0.0, 0.5)
	
	missChance += luck
	
	if randf() < missChance:
		miss()
		luck = 0
	else:
		takeDamage(damage)
		luck += 0.1
	
func dig(currentRoom):
	var digChance: float = 0.4
	digChance += luck
	
	if randf() < digChance:
		currentRoom.hasItem = true
		AudioManager.get_node("Sounds/Dodge").play()
		luck = 0
	else:
		currentRoom.hasItem = false
		AudioManager.get_node("Sounds/BreakItem").play()
		luck += 0.1
		
	currentRoom.secretRevealed = true
	redrawEverything()

func steal(currentRoom):
	var precision = 3.0
	var stealChance = clamp((float(agility) - precision) * 0.2, 0.0, 1.0)
	
	stealChance += luck
	
	if randf() < stealChance:
		currentRoom.hasPaid = true
		AudioManager.get_node("Sounds/Dodge").play()
		luck = 0
		redrawEverything()
	else:
		currentRoom.hasItem = false
		currentRoom.hasPaid = true
		currentRoom.secretRevealed = true
		redrawEverything()
		takeDamage(5)
		luck += 0.1
		

	
func swapRoom(currentRoom):
	if(!currentRoom.isTriggered):
		var enemyRoom = dungeon.getRandomRoomOfType(Room.RoomType.ENEMY)
		var itemRoom = dungeon.getRandomRoomOfType(Room.RoomType.ITEM)
	
		dungeon.swapRooms(enemyRoom, itemRoom)
		dungeon.generateWarnings()
		StoredElements.dungeonGenerator.drawDungeon()
		
		AudioManager.get_node("Sounds/Teleport").play()
		
	currentRoom.isTriggered = true
	currentRoom.isDead = true
	
	redrawEverything()
	
func disarm(currentRoom):
	AudioManager.get_node("Sounds/UseAbility").play()
	currentCooldown = abilityCooldown
	currentRoom.isDead = true
	redrawEverything()
	
func appraise(currentRoom):
	AudioManager.get_node("Sounds/UseAbility").play()
	currentCooldown = abilityCooldown
	
	if ((currentRoom.roomType == Room.RoomType.ENEMY) or (currentRoom.roomType == Room.RoomType.BOSS)) and (not currentRoom.isDead):
		var textures = [enemyHealthTexture, enemyHealthTexture2, enemyHealthTexture3]
		displayQuantity(currentRoom.health, abilityIcons, textures)
	elif currentRoom.hasItem:
		appraiseItem(currentRoom)
	
func appraiseItem(currentRoom):
	match currentRoom.getItemType():
		"HEALTH_POTION":
			displayQuantity(currentRoom.potionStrength, abilityIcons, [enemyHealthTexture])
		"WEAPON":
			displayQuantity(currentRoom.weaponStrength, abilityIcons, [attackStrengthTexture])
		"GOLD":
			displayQuantity(currentRoom.gold, abilityIcons, [coinDisplayTexture])
	
	
@warning_ignore("unused_parameter")
func scout(currentRoom):
	currentCooldown = abilityCooldown
	AudioManager.get_node("Sounds/UseAbility").play()
	
	var connectedRooms = dungeon.getConnectedRooms(dungeon.grid[posX][posY])
	connectedRooms.shuffle()
	
	redrawEverything()
	
	for i in range(min(connectedRooms.size(), abilityIcons.size())):
		abilityIcons[i].texture_normal = RoomTextureHelper.getRoomTexture(connectedRooms[i])
		abilityIcons[i].scale = Vector2(0.25, 0.25)
		
	
func autofillMap(currentRoom):
	
	var startingNode = dungeon.getStartRoom()
	var startX = startingNode.posX
	var startY = startingNode.posY
	
	AudioManager.get_node("Sounds/UseAbility").play()
	StoredDungeon.removeNullBoards()
	if(StoredDungeon.dungeonMapNodes.size() > 0):
		for interactiveMap in StoredDungeon.dungeonMapNodes:
			if(interactiveMap && is_instance_valid(interactiveMap)):
				interactiveMap.autofillBoard(currentRoom, startX, startY)
	
	return
	
func soothsayer(currentRoom):
	AudioManager.get_node("Sounds/UseAbility").play()
	
	var directionalRooms = []
	for dir in ["N", "S", "E", "W"]:
		var room = dungeon.getAdjacentRoom(currentRoom, dir)
		if room:
			directionalRooms.append(room)
	
	directionalRooms.shuffle()
	
	var index = 0
	for i in range(min(directionalRooms.size(), healthIcons.size())):
		if(directionalRooms[i].roomType != Room.RoomType.EMPTY && directionalRooms[i].roomType != Room.RoomType.WALL):
			healthIcons[index].texture_normal = RoomTextureHelper.getRoomTexture(directionalRooms[i])
			healthIcons[index].scale = Vector2(0.25, 0.25)
			index += 1
	
func showPlayerHealth(currentRoom):
	AudioManager.get_node("Sounds/UseAbility").play()
	
	currentRoom.isDead = true
	redrawEverything()
	
	var textures = [enemyHealthTexture, enemyHealthTexture2, enemyHealthTexture3]
	displayQuantity(health, healthIcons, textures)
	
	pass
	
func revealMimic(currentRoom):
	currentRoom.secretRevealed = true
	currentRoom.hasItem = false
	redrawEverything()
	takeDamage(3)
	
func killMimic(currentRoom):
	currentRoom.isDead = true
	dungeon.generateWarnings()
	redrawEverything()
	
func attackEnemy(enemy):
	var finalAttack = attack
	
	# Fugitives are weak
	if(characterClass == Class.FUGITIVE):
		finalAttack -= 1
	
	# enemy weapon weaknesses
	if(enemy.roomType != Room.RoomType.BOSS):
		if(enemy.enemyType == Room.EnemyType.UNDEAD && weapon == Room.WeaponType.HAMMER):
			finalAttack += 1
		elif(enemy.enemyType == Room.EnemyType.BASIC && weapon == Room.WeaponType.AXE):
			finalAttack += 1
	else:
		if(weapon == Room.WeaponType.SWORD || weapon == Room.WeaponType.SHORTSWORD):
			finalAttack += 1
	
	finalAttack = max(finalAttack, 1)
	
	enemy.health -= finalAttack
	
	# Weapon is weakened when enemy is killed
	if(enemy.health <= 0):
		attack -= 1
		attack = max(attack, 1)
		enemy.isDead = true
		AudioManager.get_node("Sounds/DefeatEnemy").play()
		
	dungeon.generateWarnings()
	redrawEverything()
	
func flee():
	# Player will be kicked out of the room and moved to a random adjacent room unless they are a fugitive
	
	# Get a random connected room from the room the player is in
	var connectedRooms = dungeon.getConnectedRooms(dungeon.grid[posX][posY])
	
	if connectedRooms.size() > 1:
		for room in connectedRooms:
			if(room == previousRoom):
				connectedRooms.erase(room)
	
	var fleeRoom = previousRoom #assume previous room by default
	if characterClass == Class.FUGITIVE:
		fleeRoom = previousRoom
	else:
		fleeRoom = connectedRooms[randi() % connectedRooms.size()]
	
	# Move player to new room
	movePlayerToPosition(fleeRoom.getPosX(), fleeRoom.getPosY())
	redrawEverything()
	
@warning_ignore("unused_parameter")
func teleportToExit(currentRoom):
	disarmTeleporters()
	movePlayerToRoom(Room.RoomType.TELEPORTER_EXIT)
	AudioManager.get_node("Sounds/Teleport").play()
	redrawEverything()
	return
	
func disarmTeleporters():
	
	var connections = roomButton.get_signal_connection_list("pressed")
	for connection in connections:
		roomButton.disconnect("pressed", connection["callable"])
	
	var teleporters = dungeon.getAllRoomsOfType(Room.RoomType.TELEPORTER_ENTRANCE)
	var playedSound = false
	if(teleporters.size() > 0):
		for teleporter in teleporters:
			if(!playedSound && !teleporter.isDead):
				AudioManager.get_node("Sounds/Teleport").play()
				playedSound = true
			teleporter.isDead = true
	dungeon.generateWarnings()
	

func getArtifact(currentRoom):
	currentRoom.isDead = true
	hasArtifact = true
	AudioManager.get_node("Sounds/GetItem").play()
	redrawEverything()

func showItem(currentRoom):
	var itemDisplay = itemButton #if not currentRoom.weaponSwapped else auxItemButton
	itemDisplay.texture_normal = RoomTextureHelper.getItemTexture(currentRoom)

	if currentRoom.roomType != Room.RoomType.SHOP or currentRoom.hasPaid:
		match currentRoom.getItemType():
			"HEALTH_POTION":
				displayQuantity(currentRoom.potionStrength, healthIcons, [enemyHealthTexture, enemyHealthTexture2, enemyHealthTexture3])
			"GOLD":
				displayQuantity(currentRoom.gold, healthIcons, [coinDisplayTexture])


func displayQuantity(amount, icons, textures):
	var iconCount = icons.size()
	var maxLevel = textures.size()
	
	amount = min(amount, iconCount * maxLevel)
	
	for level in range(maxLevel - 1, -1, -1):
		var unitsPerIcon = level + 1
		var neededIcons = ceil(amount / unitsPerIcon)
		if neededIcons <= iconCount:
			var fullIcons = amount / unitsPerIcon
			var remainder = amount % unitsPerIcon
			var index = 0
			
			for i in range(fullIcons):
				icons[index].texture_normal = textures[level]
				index += 1
			
			if remainder > 0 and index < iconCount:
				icons[index].texture_normal = textures[remainder - 1]
				index += 1


func displayPrice(currentRoom):
	var price = currentRoom.shopPrice
	
	if(characterClass == Class.APPRAISER):
		price -= 1
		
	displayQuantity(price, goldIcons, [coinDisplayTexture])

func pay(currentRoom):
	var adjustedPrice = currentRoom.shopPrice
	if(characterClass == Class.APPRAISER):
		adjustedPrice -= 1
	
	if(gold >= currentRoom.shopPrice):
		currentRoom.hasPaid = true
		gold -= adjustedPrice
		redrawEverything()

func getItem(currentRoom):
	if(currentRoom.hasItem):
		if(currentRoom.getItemType() == "HEALTH_POTION"):
			currentRoom.hasItem = false
			health += currentRoom.potionStrength
			health = min(health, maxHealth)
		elif(currentRoom.getItemType() == "WEAPON"):
			swapWeapon(currentRoom)
		elif(currentRoom.getItemType() == "GOLD"):
			currentRoom.hasItem = false
			gold += currentRoom.gold
		elif(currentRoom.getItemType() == "WHETSTONE"):
			match weapon:
				Room.WeaponType.PICKAXE:
					if(attack < 4):
						attack += 1
						attack = min(attack, 4)
				Room.WeaponType.SWORD:
					if(attack < 7):
						attack += 1
						attack = min(attack, 7)
				Room.WeaponType.SHORTSWORD:
					if(attack < 5):
						attack += 2
						attack = min(attack, 5)
				_:
					if(attack < 6):
						attack += 1
						attack = min(attack, 6)
			
			currentRoom.hasItem = false
		elif(currentRoom.getItemType() == "ARMOR"):
			if(armor < 10):
				armor += 1
				armor = min(armor, 10)
			currentRoom.hasItem = false
		elif(currentRoom.getItemType() == "AGILITY"):
			if(agility < 10):
				agility += 1
				agility = min(agility, 10)
			currentRoom.hasItem = false
		
		AudioManager.get_node("Sounds/GetItem").play()
		redrawEverything()

func swapWeapon(currentRoom):
	var newRoomStrength = attack
	var newRoomType = weapon
	attack = currentRoom.weaponStrength
	weapon = currentRoom.weaponType
	currentRoom.weaponStrength = newRoomStrength
	currentRoom.weaponType = newRoomType
	currentRoom.weaponSwapped = !currentRoom.weaponSwapped

func redrawEverything():
	updatePlayerSymbols()
	StoredDungeon.setPlayer(showPlayer, playerSize, posX, posY)
	if(StoredDungeon.getDungeonVisualizer() != null):
		StoredDungeon.getDungeonVisualizer().redraw()
	StoredElements.dungeonGenerator.drawDungeon()

func isInNewRoom(currentRoom):
	if currentRoom in exploredRooms:
		return false
	else:
		exploredRooms.append(currentRoom)
		currentCooldown -= 1
		currentCooldown = max(currentCooldown, 0)
		statusEffectCooldown -= 1
		statusEffectCooldown = max(statusEffectCooldown, 0)
		return true
