extends Node2D

# Helpers & Containers
var Player = preload("res://Player.gd")
var Room = preload("res://Room.gd")
var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()
var SaveGameHelper = preload("res://SaveGameHelper.gd").new()
@onready var menuContainer = $"MasterMenu"

# Stats
var gold = 15
var artifactCount = 0

# Saving
var saveSlot = 0
@export var saveSlotCount: int = 3

# Weapons
var weapons = []
var weaponStrengths = []
var weaponIndex = -1
var weaponSlotCount = 3

# Dungeon Stats
var wager = 0
var difficulty = 0
var weapon = null
var weaponStr = 2
var defaultWeapon = true
var className = "ARCHIVIST"
var classId = 0
var highestDifficultyWinCount: int = 100

var maxWager = 20
var maxClasses = 6 - 1
var maxDifficulty = 6
var maxAvaliableDifficulty: int = 1

# Menu Creation
var menuPositionY
var classDisplay
var wagerDisplay
var difficultyDisplay
var weaponDisplays = []
var defaultWeaponDisplay

# Game State
var isPlaying = false
@export var cheats = true

# Textures
var plusTexture = preload("res://TemporaryIcons/plus_sign.png") 
var minusTexture = preload("res://TemporaryIcons/minus_sign.png")

var plusTextureHovered = preload("res://TemporaryIcons/plus_sign_hovered.png") 
var minusTextureHovered = preload("res://TemporaryIcons/minus_sign_hovered.png") 

var rightTexture = preload("res://TemporaryIcons/arrowE.png") 
var leftTexture = preload("res://TemporaryIcons/arrowW.png") 

var rightTextureHovered = preload("res://TemporaryIcons/arrowE_hovered.png") 
var leftTextureHovered = preload("res://TemporaryIcons/arrowW_hovered.png") 



func _ready():
	StoredElements.setMaster(self)
	var viewport_size = get_viewport_rect().size
	var menu_size = get_viewport_rect().size
	get_node("MasterMenu").position.x = ((viewport_size.x - menu_size.x) / 2 + (menu_size.x / 2))
	updateMainMenu()

func getRewards(goldAmount, hasArtifact):
	gold += goldAmount
	if(hasArtifact):
		artifactCount += 1
		if(difficulty == maxAvaliableDifficulty):
			highestDifficultyWinCount += 1

func addAdjusters(incrementTexture, incrementTextureHovered, decrementTexture, decrementTextureHovered, incrementMethod, decrementMethod, posY):
	@warning_ignore("integer_division")
	MenuMakerHelper.addTextureButton(incrementTexture, incrementTextureHovered, incrementMethod, Vector2(0.5, 0.5), Vector2(64, posY + (40 / 16)), menuContainer)
	@warning_ignore("integer_division")
	MenuMakerHelper.addTextureButton(decrementTexture, decrementTextureHovered, decrementMethod, Vector2(0.5, 0.5), Vector2(-84, posY + (40 / 16)), menuContainer)

func addWeaponButton(index, posY):
	if(index+1 > weapons.size()):
		weapons.resize(index+1)
		weapons[index] = -1
		
	if(index+1 > weaponStrengths.size()):
		weaponStrengths.resize(index+1)
		weaponStrengths[index] = -1

	var weaponButton = MenuMakerHelper.addTextButton(getWeaponName(index), 16, setWeapon.bind(index), posY, menuContainer)
	if(weapons[index] < 0):
		weaponButton.disabled = true
	
	return weaponButton

func updateMainMenu():
	get_node("AudioClick").play()
	MenuMakerHelper.clearMenu(menuContainer)
	menuPositionY = 22
	
	addHeadingAndAdvanceY("GLYPH MAIN MENU", 26, 2)
	for i in saveSlotCount:
		addTextButtonAndAdvanceY("LOAD SLOT %d" % (i+1), 22, loadGame.bind(i), 1.25)
	
	menuPositionY += 16
	addTextButtonAndAdvanceY("QUIT GAME", 22, quitGame.bind(), 1)

	
func addHeadingAndAdvanceY(title, fontSize, spacing):
	var heading = MenuMakerHelper.addHeading(title, fontSize, menuPositionY, menuContainer)
	menuPositionY += heading.size.y * spacing
	return heading

func addTextButtonAndAdvanceY(text, fontSize, method, factor):
	var button = MenuMakerHelper.addTextButton(text, fontSize, method, menuPositionY, menuContainer)
	menuPositionY += button.size.y * factor
	return button

func updateMenu():
	MenuMakerHelper.clearMenu(menuContainer)
	
	# Make sure wager can't be set higher than gold amount
	wager = min(wager, gold)
	
	get_node("AudioClick").play()
	
	menuPositionY = 22

	# Stats
	addHeadingAndAdvanceY("Kings: %d" % gold, 16, 1.25)
	addHeadingAndAdvanceY("Artifacts: %d" % artifactCount, 16, 2)
	# Title
	addHeadingAndAdvanceY("SEVERENCE SETUP", 26, 2)
	# Class
	addHeadingAndAdvanceY("~ CLASS ~", 22, 1.25)
	addAdjusters(rightTexture, rightTextureHovered, leftTexture, leftTextureHovered, incrementClass.bind(1), incrementClass.bind(-1), menuPositionY)
	classDisplay = addHeadingAndAdvanceY(className, 16, 2)
	# Wager
	addHeadingAndAdvanceY("WAGER", 22, 1.25)
	addAdjusters(plusTexture, plusTextureHovered, minusTexture, minusTextureHovered, incrementWager.bind(1), incrementWager.bind(-1), menuPositionY)
	wagerDisplay = addHeadingAndAdvanceY(str(wager), 16, 2)
	# Difficulty
	addHeadingAndAdvanceY("DIFFICULTY", 22, 1.25)
	addAdjusters(plusTexture, plusTextureHovered, minusTexture, minusTextureHovered, incrementDifficulty.bind(1), incrementDifficulty.bind(-1), menuPositionY)
	difficultyDisplay = addHeadingAndAdvanceY(getDifficultyName(difficulty), 16, 2)
		
	weaponDisplays.clear()
	for i in range(weaponSlotCount):	
		var weaponButton = addWeaponButton(i, menuPositionY)
		weaponDisplays.append(weaponButton)
		menuPositionY += weaponButton.size.y * 1.1

	var defaultWeaponText = "Default Weapon"
	if(weaponIndex == -1):
		defaultWeaponText = "-> Default Weapon"
		
	defaultWeaponDisplay = addTextButtonAndAdvanceY(defaultWeaponText, 16, weaponDefault.bind(), 2)
	addTextButtonAndAdvanceY("BEGIN SEVERENCE", 22, startGame.bind(), 2)
	addTextButtonAndAdvanceY("BACK TO MAIN MENU", 22, backToMainMenu.bind(), 1)

func updateWeaponButtonDisplays():
	var i = 0
	for w in weapons:
		if(i < weaponDisplays.size()):
			updateButtonDisplay(weaponDisplays[i], getWeaponName(i))
			i += 1
	
	if(weaponIndex == -1):	
		updateButtonDisplay(defaultWeaponDisplay, "-> Default Weapon")
	else:
		updateButtonDisplay(defaultWeaponDisplay, "Default Weapon")

func weaponDefault():
	weaponIndex = -1
	updateWeaponButtonDisplays()
	
func setWeapon(index):
	defaultWeapon = false
	weaponIndex = index
	weapon = weapons[index]
	weaponStr = weaponStrengths[index]
	updateWeaponButtonDisplays()
	
func quitGame():
	saveGame(saveSlot)
	get_tree().quit()
	
func backToMainMenu():
	saveGame(saveSlot)
	updateMainMenu()

func playMenuSound():
	get_node("AudioClick").play()

func startGame():
	get_node("AudioStart").play()
	isPlaying = true
	StoredElements.windowManager.openSeverenceWindows()
	
	gold -= wager
	gold = max(gold, 0)
	
	var difficultiesEnum = preload("res://DungeonGeneration.gd").Difficulties  # Load the enum from Player.gd
	StoredElements.dungeonGenerator.difficulty = difficultiesEnum[getDifficultyById(difficulty)]
	StoredElements.player.generateNewDungeon()
	StoredElements.player.updateCharacterStats(StoredElements.player.Class[getClassById(classId)], wager)
	
	
	if(weaponIndex > -1):
		StoredElements.player.updateCharacterWeapon(weapon, weaponStr)
		weapons[weaponIndex] = -1
	weaponIndex = -1
	
	StoredElements.player.updatePlayerSymbols()
	updateMenu()
	
	StoredDungeon.removeNullBoards()
	if(StoredDungeon.dungeonMapNodes.size() > 0):
		for interactiveMap in StoredDungeon.dungeonMapNodes:
			if(interactiveMap && is_instance_valid(interactiveMap)):
				interactiveMap.clearBoard()
	
func updateButtonDisplay(button, text):
	button.text = text
	MenuMakerHelper.centerText(button)
	playMenuSound()
	
func incrementWager(amount):
	wager = clamp(wager + amount, 0, min(gold, maxWager))
	updateButtonDisplay(wagerDisplay, str(wager))
	
func incrementClass(amount):
	classId = (classId + amount + (maxClasses + 1)) % (maxClasses + 1)
	className = getClassById(classId)
	updateButtonDisplay(classDisplay, className)

func incrementDifficulty(amount):
	difficulty = clamp(difficulty + amount, 0, getMaxDifficulty())
	updateButtonDisplay(difficultyDisplay, getDifficultyName(difficulty))
	
func getWeaponName(index):
	var buttonStr = "Empty"
	if(weapons[index] > -1):
		buttonStr = ""
		if(weaponIndex == index):
			buttonStr += "-> "
		
		if(weapons[index] == Room.WeaponType.SWORD):
			buttonStr += "Sword"
		elif(weapons[index] == Room.WeaponType.AXE):
			buttonStr += "Axe"
		elif(weapons[index] == Room.WeaponType.HAMMER):
			buttonStr += "Hammer"
		elif(weapons[index] == Room.WeaponType.PICKAXE):
			buttonStr += "Pickaxe"
		elif(weapons[index] == Room.WeaponType.SHORTSWORD):
			buttonStr += "Shortsword"
			
		buttonStr += " +" + str(weaponStrengths[index])
	
	return buttonStr
	
func getDifficultyName(difficulty):
	var difficultyText = ""
	match difficulty:
		0:
			difficultyText = "TUTORIAL"
		1:
			difficultyText = "VERY EASY"
		2:
			difficultyText = "EASY"
		3:
			difficultyText = "MODERATE"
		4:
			difficultyText = "HARD"
		5:
			difficultyText = "VERY HARD"
		6:
			difficultyText = "EXTREME"
	return difficultyText
	
func getClassById(id):
	var classEnum = preload("res://Player.gd").Class  # Load the enum from Player.gd
	if id >= 0 and id < classEnum.size():
		return classEnum.keys()[id]  # Return the string name of the class
	else:
		return "Unknown"  # Fallback for invalid IDs
		
func getDifficultyById(id):
	var classEnum = preload("res://DungeonGeneration.gd").Difficulties  # Load the enum from Player.gd
	if id >= 0 and id < classEnum.size():
		return classEnum.keys()[id]  # Return the string name of the class
	else:
		return "Unknown"  # Fallback for invalid IDs

func getMaxClasses():
	return StoredElements.player.Class.size() - 1

func getMaxDifficulty():
	@warning_ignore("integer_division")
	maxAvaliableDifficulty = (highestDifficultyWinCount / 3) + 1
	maxAvaliableDifficulty = max(1, maxAvaliableDifficulty)
	maxAvaliableDifficulty = min(maxDifficulty, maxAvaliableDifficulty)
	return maxAvaliableDifficulty
	
func saveGame(slot):
	var saveData = {
		"gold": gold,
		"artifactCount": artifactCount,
		"weapons": weapons,
		"weaponStrengths": weaponStrengths,
		"winCount" : highestDifficultyWinCount
	}
	
	SaveGameHelper.saveGame(saveData, slot)

func loadGame(slot: int):
	saveSlot = slot
	var outputVariables = {}
	outputVariables = SaveGameHelper.loadGame(slot, outputVariables)
	
	gold = outputVariables.gold
	artifactCount = outputVariables.artifactCount
	weapons = outputVariables.weapons
	weaponStrengths = outputVariables.weaponStrengths
	highestDifficultyWinCount = outputVariables.winCount
	
	updateMenu()
