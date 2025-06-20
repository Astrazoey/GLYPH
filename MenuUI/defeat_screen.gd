extends Control

var RoomTextureHelper = preload("res://RoomTextureHelper.gd").new()
var FadeSceneHelper = preload("res://SceneFadeHelper.gd").new()

@onready var deathInfo = $MarginContainer/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer2/ClassDeathInfo
@onready var gold = $MarginContainer/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/HBoxContainer/GoldDisplay
@onready var weaponIcon = $MarginContainer/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer3/HBoxContainer/WeaponIcon
@onready var damage = $MarginContainer/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer3/HBoxContainer/WeaponAttack
# Called when the node enters the scene tree for the first time.
func _ready():
	
	FadeSceneHelper.fade_in(self, 2)
	
	var deathString = ""

	match StoredElements.classId:
		0:
			deathString = "ARCHIVIST"
		1:
			deathString = "SCOUT"
		2:
			deathString = "APPRAISER"
		3:
			deathString = "SERFS"
		4:
			deathString = "TRAPPER"
		5:
			deathString = "FUGITIVE"
	
	deathString = deathString + " DIED IN THE SEVERENCE"
	deathInfo.text = deathString
	
	gold.text = str(StoredElements.winGold)
	weaponIcon.texture = RoomTextureHelper.getWeaponTexture(StoredElements.winWeapon)
	damage.text = str(StoredElements.winWeaponDamage) + "DMG"

