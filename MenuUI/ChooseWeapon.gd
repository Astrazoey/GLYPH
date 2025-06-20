extends Button

var RoomTextureHelper = preload("res://RoomTextureHelper.gd").new()

@export var weaponIndex = -1 
@onready var weaponIcon = $"../PanelContainer/CurrentWeaponInfo/WeaponIcon"
@onready var weaponDamage = $"../PanelContainer/CurrentWeaponInfo/WeaponDamage"

var emptyIconTexture = preload("res://TemporaryIcons/empty_slot.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", changeWeaponIndex.bind(weaponIndex))
	updateWeaponDisplay(StoredElements.weaponIndex)


func changeWeaponIndex(newIndex):
	StoredElements.weaponIndex = newIndex
	AudioManager.get_node("Sounds/ButtonClick").play()
	updateWeaponDisplay(newIndex)
	

func updateWeaponDisplay(newIndex):
	#print(newIndex)

	if(StoredElements.weaponIndex <= -1) or (StoredElements.weapons.size() <= newIndex):
		weaponDamage.text = ""
		weaponIcon.texture = emptyIconTexture
	else:
		weaponDamage.text = str(StoredElements.weaponStrengths[newIndex])
		weaponIcon.texture = RoomTextureHelper.getWeaponTexture(StoredElements.weapons[newIndex])
