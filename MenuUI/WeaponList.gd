extends VBoxContainer

var RoomTextureHelper = preload("res://RoomTextureHelper.gd").new()

@onready var defaultWeaponButton = $"../../ChooseDefaultWeapon"
@onready var retrievedWeaponIcon = $"../../HBoxContainer/RetrievedWeaponIcon"
@onready var retrievedWeaponDamage = $"../../HBoxContainer/RetrievedWeaponDamage"
@export var keepWeaponMode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	displayWeapons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func displayWeapons():
	
	for child in self.get_children():
		child.queue_free()
	
	if(keepWeaponMode):
		if(StoredElements.winWeapon == -1):
			retrievedWeaponDamage.text = ""
		else:
			retrievedWeaponDamage.text = str(StoredElements.winWeaponDamage) + "DMG"
		retrievedWeaponIcon.texture = RoomTextureHelper.getWeaponTexture(StoredElements.winWeapon)
		#addWeapon(StoredElements.player.weapon, StoredElements.player.attack, -2)
	
	for i in StoredElements.max_weapons:
		if i < StoredElements.weapons.size():
			addWeapon(StoredElements.weapons[i], StoredElements.weaponStrengths[i], i)
		else:
			addWeapon(-1, -1, -1)
	

func addWeapon(weaponId, weaponStrength, index):
	var hBoxMain = HBoxContainer.new()
	
	var panelContainer = PanelContainer.new()
	panelContainer.theme = load("res://Themes/rounded_panel_theme.tres")
	panelContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panelContainer.custom_minimum_size.y = 96
	hBoxMain.add_child(panelContainer)
	
	var hBoxDisplay = HBoxContainer.new()
	hBoxDisplay.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var weaponIcon = TextureRect.new()
	weaponIcon.texture = RoomTextureHelper.getWeaponTexture(weaponId)
	weaponIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hBoxDisplay.add_child(weaponIcon)
	
	if(weaponStrength == null):
		weaponStrength = -1
	
	if(weaponStrength > -1) and (weaponId > -1):
		var weaponDamageDisplay = Label.new()
		var label_settings = load("res://Label Settings/description.tres")
		weaponDamageDisplay.text = str(weaponStrength) + "DMG"
		weaponDamageDisplay.label_settings = label_settings
		hBoxDisplay.add_child(weaponDamageDisplay)

	panelContainer.add_child(hBoxDisplay)
	hBoxMain.add_child(hBoxDisplay)
	
	if((keepWeaponMode == false) and (weaponId > -1)) or ((keepWeaponMode == true) and (StoredElements.winWeapon != -1)):
		var buttonMargins = MarginContainer.new()
		var selectButton = Button.new()
		selectButton.theme = load("res://Themes/menu_button_theme.tres")
			
		selectButton.button_group = load("res://MenuUI/ButtonGroups/weapon_selection_button_group.tres")
		selectButton.toggle_mode = true
			
		if(keepWeaponMode):
			selectButton.text = "REPLACE SLOT"
			selectButton.connect("pressed", addWeaponToInventory.bind(index))
		else:
			selectButton.text = "SELECT"
			selectButton.connect("pressed", changeWeaponIndex.bind(index))
			
		buttonMargins.add_child(selectButton)
		hBoxMain.add_child(buttonMargins)
	
	add_child(hBoxMain)

func changeWeaponIndex(weaponId):
	defaultWeaponButton.changeWeaponIndex(weaponId)

func addWeaponToInventory(weaponIndex):
	print("adding weapon to index ", weaponIndex)
	
	AudioManager.get_node("Sounds/ButtonClick").play()
	
	StoredElements.weapons[weaponIndex] = StoredElements.winWeapon
	StoredElements.weaponStrengths[weaponIndex] = StoredElements.winWeaponDamage
	
	StoredElements.winWeapon = -1
	StoredElements.winWeaponDamage
	
	displayWeapons()
