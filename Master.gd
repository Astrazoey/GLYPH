extends Node2D

# Helpers & Containers
var Player = preload("res://Player.gd")
var Room = preload("res://Room.gd")
var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()
var SaveGameHelper = preload("res://SaveGameHelper.gd").new()
var SceneFadeHelper = preload("res://SceneFadeHelper.gd").new()
@onready var menuContainer = $"MasterMenu"

# Stats
#var gold = 15
#var artifactCount = 0

# Saving
#var saveSlot = 0
@export var saveSlotCount: int = 3

# Weapons
#var weapons = []
#var weaponStrengths = []
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
	loadGameSlot()

func getRewards(goldAmount, hasArtifact):
	StoredElements.gold += goldAmount
	if(hasArtifact):
		StoredElements.artifactCount += 1
		if(difficulty == maxAvaliableDifficulty):
			StoredElements.highestDifficultyWinCount += 1

func addAdjusters(incrementTexture, incrementTextureHovered, decrementTexture, decrementTextureHovered, incrementMethod, decrementMethod, posY):
	@warning_ignore("integer_division")
	MenuMakerHelper.addTextureButton(incrementTexture, incrementTextureHovered, incrementMethod, Vector2(0.5, 0.5), Vector2(64, posY + (40 / 16)), menuContainer)
	@warning_ignore("integer_division")
	MenuMakerHelper.addTextureButton(decrementTexture, decrementTextureHovered, decrementMethod, Vector2(0.5, 0.5), Vector2(-84, posY + (40 / 16)), menuContainer)

func addWeaponButton(index, posY):
	if(index+1 > StoredElements.weapons.size()):
		StoredElements.weapons.resize(index+1)
		StoredElements.weapons[index] = -1
		
	if(index+1 > StoredElements.weaponStrengths.size()):
		StoredElements.weaponStrengths.resize(index+1)
		StoredElements.weaponStrengths[index] = -1

	var weaponButton = MenuMakerHelper.addTextButton(getWeaponName(index), 16, setWeapon.bind(index), posY, menuContainer)
	if(StoredElements.weapons[index] < 0):
		weaponButton.disabled = true
	
	return weaponButton
	
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
	wager = min(wager, StoredElements.gold)
	
	get_node("AudioClick").play()
	
	menuPositionY = 22

	# Stats
	addHeadingAndAdvanceY("Kings: %d" % StoredElements.gold, 16, 1.25)
	addHeadingAndAdvanceY("Artifacts: %d" % StoredElements.artifactCount, 16, 2)
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
	if(StoredElements.weaponIndex == -1):
		defaultWeaponText = "-> Default Weapon"
		
	defaultWeaponDisplay = addTextButtonAndAdvanceY(defaultWeaponText, 16, weaponDefault.bind(), 2)
	addTextButtonAndAdvanceY("BEGIN SEVERENCE", 22, startGame.bind(), 2)
	addTextButtonAndAdvanceY("BACK TO MAIN MENU", 22, backToMainMenu.bind(), 1)

func updateWeaponButtonDisplays():
	var i = 0
	for w in StoredElements.weapons:
		if(i < weaponDisplays.size()):
			updateButtonDisplay(weaponDisplays[i], getWeaponName(i))
			i += 1
	
	if(StoredElements.weaponIndex == -1):	
		updateButtonDisplay(defaultWeaponDisplay, "-> Default Weapon")
	else:
		updateButtonDisplay(defaultWeaponDisplay, "Default Weapon")

func weaponDefault():
	StoredElements.weaponIndex = -1
	updateWeaponButtonDisplays()
	
func setWeapon(index):
	defaultWeapon = false
	StoredElements.weaponIndex = index
	StoredElements.weapon = StoredElements.weapons[index]
	StoredElements.weaponStr = StoredElements.weaponStrengths[index]
	updateWeaponButtonDisplays()
	
func backToMainMenu():
	SaveGameHelper.saveGame(StoredElements.saveSlot)
	SceneFadeHelper.fadeScene(StoredElements.windowManager, null, "res://MenuUI/main_menu.tscn", 1)
	get_parent().queue_free()

func playMenuSound():
	get_node("AudioClick").play()

func startGame():
	get_node("AudioStart").play()
	isPlaying = true
	StoredElements.windowManager.openSeverenceWindows()
	
	StoredElements.gold -= wager
	StoredElements.gold = max(StoredElements.gold, 0)
	
	var difficultiesEnum = preload("res://DungeonGeneration.gd").Difficulties  # Load the enum from Player.gd
	StoredElements.dungeonGenerator.difficulty = difficultiesEnum[getDifficultyById(difficulty)]
	StoredElements.player.generateNewDungeon()
	StoredElements.player.updateCharacterStats(StoredElements.player.Class[getClassById(classId)], wager)
	
	
	if(StoredElements.weaponIndex > -1):
		StoredElements.player.updateCharacterWeapon(StoredElements.weapon, StoredElements.weaponStr)
		StoredElements.weapons[StoredElements.weaponIndex] = -1
	StoredElements.weaponIndex = -1
	
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
	wager = clamp(wager + amount, 0, min(StoredElements.gold, maxWager))
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
	if(StoredElements.weapons[index] > -1):
		buttonStr = ""
		if(StoredElements.weaponIndex == index):
			buttonStr += "-> "
		
		if(StoredElements.weapons[index] == Room.WeaponType.SWORD):
			buttonStr += "Sword"
		elif(StoredElements.weapons[index] == Room.WeaponType.AXE):
			buttonStr += "Axe"
		elif(StoredElements.weapons[index] == Room.WeaponType.HAMMER):
			buttonStr += "Hammer"
		elif(StoredElements.weapons[index] == Room.WeaponType.PICKAXE):
			buttonStr += "Pickaxe"
		elif(StoredElements.weapons[index] == Room.WeaponType.SHORTSWORD):
			buttonStr += "Shortsword"
			
		buttonStr += " +" + str(StoredElements.weaponStrengths[index])
	
	return buttonStr
	
func getDifficultyName(difficultyCheck):
	var difficultyText = ""
	match difficultyCheck:
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
	maxAvaliableDifficulty = (StoredElements.highestDifficultyWinCount / 3) + 1
	maxAvaliableDifficulty = max(1, maxAvaliableDifficulty)
	maxAvaliableDifficulty = min(maxDifficulty, maxAvaliableDifficulty)
	return maxAvaliableDifficulty
	
func loadGameSlot():
	var outputVariables = StoredElements.saveData
	
	if(outputVariables == {}):
		outputVariables = SaveGameHelper.startDefaultSave(-1)
	
	StoredElements.saveSlot = outputVariables.saveSlot
	StoredElements.gold = outputVariables.gold
	StoredElements.artifactCount = outputVariables.artifactCount
	StoredElements.weapons = outputVariables.weapons
	StoredElements.weaponStrengths = outputVariables.weaponStrengths
	StoredElements.highestDifficultyWinCount = outputVariables.winCount
	
	updateMenu()	
