extends Node

enum RoomType {
	WALL,
	EMPTY,
	START,
	ARTIFACT,
	EXIT,
	TEMP,
	ENEMY,
	ITEM,
	TELEPORTER_ENTRANCE,
	TELEPORTER_EXIT,
	SHOP,
	MIMIC,
	SWAPPER,
	SOOTHSAYER,
	BOSS,
	HEALTH_ROOM
}
var roomType = RoomType.EMPTY
enum ItemType {
	WEAPON,
	HEALTH_POTION,
	GOLD,
	WHETSTONE,
	ARMOR,
	AGILITY
}
var itemType = ItemType.HEALTH_POTION
enum EnemyType {BASIC, UNDEAD}
var enemyType = EnemyType.BASIC

enum WeaponType {
	SWORD,
	AXE,
	HAMMER,
	PICKAXE,
	SHORTSWORD
}
var weaponType = WeaponType.SWORD

var foundByGenerator: bool = false

var posX: int
var posY: int

var isDead: bool = false
var hasItem: bool = true
var hasPaid: bool = false
var isTriggered: bool = false
var weaponSwapped: bool = false
var secretRevealed: bool = false

var health: int = 5
var attack: int = 1
var shopPrice: int = 5
var gold: int = 2

var potionStrength: int = 2
var weaponStrength: int = 3

var nearEnemy: bool = false
var nearMimic: bool = false
var nearTeleporter: bool = false
var nearBoss: bool = false

var exits = {
	"N": false, "NE": false, "E": false, "SE": false,
	"S": false, "SW": false, "W": false, "NW": false
}

func copyRoom():
	var newRoom = new()
	
	newRoom.roomType = roomType
	newRoom.itemType = itemType
	newRoom.enemyType = enemyType
	newRoom.weaponType = weaponType
	
	newRoom.foundByGenerator = foundByGenerator
	
	newRoom.posX = posX
	newRoom.posY = posY
	
	newRoom.isDead = isDead
	newRoom.hasItem = hasItem
	newRoom.hasPaid = hasPaid
	newRoom.isTriggered = isTriggered
	newRoom.weaponSwapped = weaponSwapped
	newRoom.secretRevealed = secretRevealed
	
	newRoom.health = health
	newRoom.attack = attack
	newRoom.shopPrice = shopPrice
	newRoom.gold = gold
	
	newRoom.potionStrength = potionStrength
	newRoom.weaponStrength = weaponStrength
	
	newRoom.nearEnemy = nearEnemy
	newRoom.nearMimic = nearMimic
	newRoom.nearTeleporter = nearTeleporter
	newRoom.nearBoss = nearBoss
	
	newRoom.exits = exits.duplicate()
	
	return newRoom

func setNearEnemy(value):
	nearEnemy = value
	
func setNearMimic(value):
	nearMimic = value

func takeDamage(damage):
	health =- damage

func dealDamage():
	return 1 + randi() % attack

func defaultValue():
	roomType = RoomType.EMPTY
		
func getRoomType():
	return roomType
	
func getItemType():
	return itemType
	
func getEnemyType():
	return enemyType
		
func setRoomType(newRoomType):
	roomType = newRoomType
	
func setItemType(newItemType):
	itemType = newItemType
	
func setEnemyType(newEnemyType):
	enemyType = newEnemyType
	
func setRandomWeapon():
	weaponType = WeaponType.values()[randi() % WeaponType.size()]

func setRandomEnemy():
	enemyType = EnemyType.values()[randi() % EnemyType.size()]

func isFoundByGenerator():
	return foundByGenerator
	
func setFoundByGenerator(found):
	foundByGenerator = found
	
func setPosition(x, y):
	posX = x
	posY = y
	
func getPosX():
	return posX

func getPosY():
	return posY

# Get an exit state
func getExit(direction: String) -> bool:
	return exits.get(direction, false)

# Set an exit state
func setExit(direction: String, state: bool) -> void:
	if direction in exits:
		exits[direction] = state

func setExits(newExits):
	exits = newExits
	

func resetExits():
	for key in exits.keys():
		exits[key] = false
		
func clearRoomState():
	resetExits()
	foundByGenerator = false
	roomType = RoomType.EMPTY

func hasExit(direction: String) -> bool:
	return exits.has(direction) and exits[direction]
	
func getExitCount():
	var exitCount: int = 0
	for key in exits.keys():
		if(exits[key]):
			exitCount += 1
	return exitCount
	
func getExitDictionary():
	return exits
	
func getExits():
	var activeExits = []
		
	for direction in exits.keys():
		if exits[direction]:
			activeExits.append(direction)
	return activeExits

func restrictPlayerMovement():
	if(getRoomType() == RoomType.SWAPPER
	|| getRoomType() == RoomType.MIMIC
	|| getRoomType() == RoomType.ENEMY
	|| getRoomType() == RoomType.BOSS
	|| getRoomType() == RoomType.TELEPORTER_ENTRANCE
	|| getRoomType() == RoomType.ARTIFACT):
		if(!isDead):
			# Return false if it's a dormant mimic
			if(getRoomType() == RoomType.MIMIC && !secretRevealed):
				return false
			
			return true
	return false

func addBossBonus():
	health += 5
	attack += 1
	
	health = min(health, 10)
	attack = min(attack, 3)
