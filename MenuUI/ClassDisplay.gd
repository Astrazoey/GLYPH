extends VBoxContainer

var RoomTextureHelper = preload("res://RoomTextureHelper.gd").new()

@onready var classImage = $ClassImage
@onready var className = $ClassNameLabel

@onready var abilities = $PanelContainer/MarginContainer/VBoxContainer/AbilityBoxContainer
@onready var weaponDisplay = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/WeaponDisplayTexture
@onready var weaponStrength = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/WeaponStrengthLabel
@onready var stats = $PanelContainer/MarginContainer/VBoxContainer/StatsLabel

@export var showDefaultWeapon = true

var archivistAbilityTexture = preload("res://TemporaryIcons/autofill.png")
var appraiserAbilityTexture = preload("res://TemporaryIcons/appraise.png")
var trapperAbilityTexture = preload("res://TemporaryIcons/disarm.png")
var scoutAbilityTexture = preload("res://TemporaryIcons/scout.png")
var serfAbilityTexture = preload("res://TemporaryIcons/revive.png")

var emptyTexture = preload("res://TemporaryIcons/empty_slot.png")

var axeWeaponTexture = preload("res://TemporaryIcons/weapon_axe.png")
var pickaxeWeaponTexture = preload("res://TemporaryIcons/weapon_pickaxe.png")
var swordWeaponTexture = preload("res://TemporaryIcons/sword.png")
var shortswordWeaponTexture = preload("res://TemporaryIcons/weapon_shortsword.png")
var hammerWeaponTexture = preload("res://TemporaryIcons/weapon_hammer.png")

var labelSettings = load("res://Label Settings/description.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	updateClassDisplay()


func updateClassDisplay():
	
	for child in abilities.get_children():
		child.queue_free()
	
	match StoredElements.classId:
		StoredElements.CharacterClass.ARCHIVIST:
			var abilityDictionary = {
				1: {"texture" : archivistAbilityTexture, "cooldown" : 0}
			}
			setClassInfo("ARCHIVIST", abilityDictionary, swordWeaponTexture, 3, 10, 20, 0, 3, null)
		StoredElements.CharacterClass.SCOUT:
			var abilityDictionary = {
				1: {"texture" : scoutAbilityTexture, "cooldown" : 2}
			}
			setClassInfo("SCOUT", abilityDictionary, swordWeaponTexture, 3, 10, 20, 0, 3, null)
		StoredElements.CharacterClass.APPRAISER:
			var abilityDictionary = {
				1: {"texture" : appraiserAbilityTexture, "cooldown" : 0},
				2: {"texture" : emptyTexture, "cooldown" : -1}
			}
			setClassInfo("APPPRAISER", abilityDictionary, hammerWeaponTexture, 3, 10, 20, 0, 3, null)
		StoredElements.CharacterClass.SERFS:
			var abilityDictionary = {
				1: {"texture" : serfAbilityTexture, "cooldown" : -1}
			}
			setClassInfo("SERFS", abilityDictionary, pickaxeWeaponTexture, 3, 5, 15, 0, 3, null)
		StoredElements.CharacterClass.TRAPPER:
			var abilityDictionary = {
				1: {"texture" : trapperAbilityTexture, "cooldown" : 2},
				2: {"texture" : emptyTexture, "cooldown" : -1}
			}
			setClassInfo("TRAPPER", abilityDictionary, swordWeaponTexture, 3, 10, 20, 0, 3, null)
		StoredElements.CharacterClass.FUGITIVE:
			var abilityDictionary = {
				1: {"texture" : emptyTexture, "cooldown" : -1},
				2: {"texture" : emptyTexture, "cooldown" : -1}
			}
			setClassInfo("FUGITIVE", abilityDictionary, shortswordWeaponTexture, 2, 10, 20, 0, 5, null)

		
func setClassInfo(classText, classAbilities, weaponTexture, weaponDamage, hp, maxhp, def, agi, additionalLabel):
	className.text = classText
	
	for key in classAbilities:
		var ability = classAbilities[key]
		createAbilityBox(ability["texture"], ability["cooldown"], false)
	var separator = HSeparator.new()
	abilities.add_child(separator)
	if(showDefaultWeapon) or (StoredElements.weaponIndex < 0):
		createAbilityBox(weaponTexture, weaponDamage, true)
	else:
		createAbilityBox(RoomTextureHelper.getWeaponTexture(StoredElements.weapons[StoredElements.weaponIndex]), StoredElements.weaponStrengths[StoredElements.weaponIndex], true)
	stats.text = "%dHP %dMAXHP %dDEF %dAGI" % [hp, maxhp, def, agi]
	
	if(additionalLabel != null):
		var extraLabel = Label.new()
		extraLabel.text = additionalLabel
		extraLabel.label_settings = labelSettings
		add_child(extraLabel)
		
func createAbilityBox(texture, cooldown, isWeapon):
	var abilityHbox = HBoxContainer.new()
	var abilityLabel = Label.new()
	if(isWeapon):
		if(showDefaultWeapon):
			abilityLabel.text = "DEFAULT WEAPON "
		else:
			abilityLabel.text = "WEAPON "
	else:
		abilityLabel.text = "ABILITY"
	abilityLabel.label_settings = labelSettings
	var abilityIcon = TextureRect.new()
	abilityIcon.texture = texture
	abilityIcon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	abilityIcon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	abilityIcon.size = Vector2(64, 64)
	var cooldownLabel = Label.new()
	if(isWeapon):
		cooldownLabel.text = str(cooldown) + "DMG"
	else:
		if(cooldown >= 0):
			cooldownLabel.text = str(cooldown) + "CD"
		else:
			cooldownLabel.text = "PASSIVE"
	cooldownLabel.label_settings = labelSettings
	
	abilityHbox.add_child(abilityLabel)
	abilityHbox.add_child(abilityIcon)
	abilityHbox.add_child(cooldownLabel)
	abilities.add_child(abilityHbox)
