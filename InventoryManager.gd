extends Node2D



var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()
var RoomTextureHelper = preload("res://RoomTextureHelper.gd").new()
var Player = preload("res://Player.gd")
@onready var menuContainer = $"MenuContainer"

# Textures
var emptyTexture = preload("res://TemporaryIcons/empty_slot.png")


func _ready():
	StoredElements.setInventoryManager(self)
	var viewport_size = get_viewport_rect().size
	var menu_size = get_viewport_rect().size
	get_node("MenuContainer").position.x = ((viewport_size.x - menu_size.x) / 2 + (menu_size.x / 2))
	#updateMenu()
	pass # Replace with function body.

func closeWindow():
	StoredElements.windowManager.closeInventoryWindow()
	StoredElements.windowManager.openMasterWindow()
	StoredElements.windowManager.closeSeverenceWindows()
	StoredElements.master.updateMenu()

func updateMenu():
	get_node("AudioClick").play()
	MenuMakerHelper.clearMenu(menuContainer)
		
	var menuPosY = 22
	
	var menuLabel = MenuMakerHelper.addHeading("SUCCESSFUL EXIT", 26, menuPosY, menuContainer)
	menuPosY += menuLabel.size.y * 1.25
	
	var newArtifactLabel = MenuMakerHelper.addHeading("Retrieved Artifact", 20, menuPosY, menuContainer)
	menuPosY += newArtifactLabel.size.y * 1.25
	var displayedArtifactIcon = MenuMakerHelper.createSimpleButton(emptyTexture, emptyTexture, Vector2(-32, menuPosY), menuContainer)
	menuPosY += displayedArtifactIcon.size.y * 1.25
	
	var newWeaponLabel = MenuMakerHelper.addHeading("Retrieved Weapon", 20, menuPosY, menuContainer)
	menuPosY += newWeaponLabel.size.y * 1.25

	var displayedWeaponIcon
	if(StoredElements.player.weapon > -1):
		displayedWeaponIcon = MenuMakerHelper.createSimpleButton(RoomTextureHelper.getWeaponTexture(StoredElements.player.weapon), RoomTextureHelper.getWeaponTexture(StoredElements.player.weapon), Vector2(-64, menuPosY), menuContainer)
		@warning_ignore("unused_variable")
		var newWeaponDamage = MenuMakerHelper.createSimpleLabel("+%d" % StoredElements.player.attack, 20, Vector2(8, menuPosY+16), menuContainer)
	else:
		displayedWeaponIcon = MenuMakerHelper.createSimpleButton(emptyTexture, emptyTexture, Vector2(-64, menuPosY), menuContainer)

	menuPosY += displayedWeaponIcon.size.y * 1.5

	var storedWeaponLabel = MenuMakerHelper.addHeading("Stored Weapons", 20, menuPosY, menuContainer)
	menuPosY += storedWeaponLabel.size.y * 1.25

	var slotAmount = StoredElements.master.weaponSlotCount
	var rowCounter = 1
	for i in range(1, slotAmount+1):
		var xOffset = 0
		if(rowCounter % 3 == 0):
			xOffset = 112 - 48
			rowCounter = 1
		elif(rowCounter % 2 == 0):
			xOffset = 0 - 48
			rowCounter += 1
		elif(rowCounter % 1 == 0):
			xOffset = -112 - 48
			rowCounter += 1
		
		var weaponSlot
		if(StoredElements.master.weapons.size() > i-1) and (StoredElements.master.weapons[i-1] > -1):
			weaponSlot = MenuMakerHelper.createSimpleButton(RoomTextureHelper.getWeaponTexture(StoredElements.master.weapons[i-1]), RoomTextureHelper.getWeaponTexture(StoredElements.master.weapons[i-1]), Vector2(xOffset, menuPosY), menuContainer)
			@warning_ignore("unused_variable")
			var weaponDamage = MenuMakerHelper.createSimpleLabel("+%d" % StoredElements.master.weaponStrengths[i-1], 20, Vector2(64 + 8 + xOffset, menuPosY+16), menuContainer)
		else:
			weaponSlot = MenuMakerHelper.createSimpleButton(emptyTexture, emptyTexture, Vector2(xOffset, menuPosY), menuContainer)
		
		weaponSlot.connect("pressed", giveWeaponToMaster.bind(i-1))
			
		if(i % 3 == 0) or (i == slotAmount):
			menuPosY += weaponSlot.size.y * 1.25
	

	var goldLabel = MenuMakerHelper.addHeading("Kings Retrieved: %d" % StoredElements.player.gold, 16, menuPosY, menuContainer)
	menuPosY += goldLabel.size.y * 1.25
	
	var movesLabel = MenuMakerHelper.addHeading("Total Moves: %d" % StoredElements.player.moveCount, 16, menuPosY, menuContainer)
	menuPosY += movesLabel.size.y * 2
	
	print(StoredElements.master.difficulty)
	print(StoredElements.master.getMaxDifficulty())
	print(StoredElements.player.hasArtifact)
	
	if(StoredElements.master.difficulty + 1 == StoredElements.master.getMaxDifficulty()) and StoredElements.player.hasArtifact:
		if (StoredElements.master.highestDifficultyWinCount % 3 == 0):
			var difficultyText = "New Difficulty Unlocked! - " + StoredElements.master.getDifficultyName(StoredElements.master.getMaxDifficulty())
			var difficultyLabel = MenuMakerHelper.addHeading(difficultyText, 24, menuPosY, menuContainer)
			menuPosY += difficultyLabel.size.y * 2
	
	@warning_ignore("unused_variable")
	var continueButton = MenuMakerHelper.addTextButton("CONTINUE", 20, closeWindow.bind(), menuPosY, menuContainer)
	
func giveWeaponToMaster(index):
	if(StoredElements.player.weapon > -1):
		get_node("AudioUseAbility").play()
		
		StoredElements.master.weapons[index] = StoredElements.player.weapon
		StoredElements.master.weaponStrengths[index] = StoredElements.player.attack
	
		StoredElements.player.weapon = -1
		updateMenu()
	
