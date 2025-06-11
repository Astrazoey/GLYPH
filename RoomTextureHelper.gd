extends Node

var Room = preload("res://Room.gd")

# No room
var emptyIcon = preload("res://TemporaryIcons/empty_icon.png")
var emptyIcon2 = preload("res://TemporaryIcons/empty_slot.png")

# Room Textures
var startRoomTexture = preload("res://TemporaryIcons/start.png")
var exitRoomTexture = preload("res://TemporaryIcons/exit.png")
var teleporterEntranceTexture = preload("res://TemporaryIcons/teleporter_entrance.png")
var teleporterExitTexture = preload("res://TemporaryIcons/teleporter_exit.png")
var basicEnemyTexture = preload("res://TemporaryIcons/enemy_basic.png")
var undeadEnemyTexture = preload("res://TemporaryIcons/enemy_undead.png")
var deadEnemyTexture = preload("res://TemporaryIcons/enemy_dead.png")
var artifactTexture = preload("res://TemporaryIcons/artifact.png")
var mimicTexture = preload("res://TemporaryIcons/mimic.png")
var soothsayerTexture = preload("res://TemporaryIcons/soothsayer.png")
var shopTexture = preload("res://TemporaryIcons/shop.png")
var shopPaidTexture = preload("res://TemporaryIcons/shop_paid.png")
var itemTexture = preload("res://TemporaryIcons/item.png")
var itemTakenTexture = preload("res://TemporaryIcons/item_picked_up.png")
var swapperTexture = preload("res://TemporaryIcons/swapper.png")
var bossTexture = preload("res://TemporaryIcons/boss.png")
var healthRoomTexture = preload("res://TemporaryIcons/health_room.png")
var healthRoomDeadTexture = preload("res://TemporaryIcons/health_room_dead.png")

# Empty Rooms
var emptyRoomTexture = preload("res://TemporaryIcons/empty_room.png")
var bossWarningTexture = preload("res://TemporaryIcons/boss_warning.png")
var enemyWarningTexture = preload("res://TemporaryIcons/enemy_warning.png")
var mimicWarningTexture = preload("res://TemporaryIcons/mimic_warning.png")
var teleporterWarningTexture = preload("res://TemporaryIcons/teleporter_warning.png")

# Items
var healthPotionTexture = preload("res://TemporaryIcons/health_potion.png")
var whetstoneTexture = preload("res://TemporaryIcons/whetstone.png")
var coinTexture = preload("res://TemporaryIcons/coin.png")
var armorTexture = preload("res://TemporaryIcons/armor.png")
var agilityTexture = preload("res://TemporaryIcons/agility.png")

# Weapons
var weaponTexture = preload("res://TemporaryIcons/sword.png")
var axeTexture = preload("res://TemporaryIcons/weapon_axe.png")
var hammerTexture = preload("res://TemporaryIcons/weapon_hammer.png")
var pickaxeTexture = preload("res://TemporaryIcons/weapon_pickaxe.png")
var shortswordTexture = preload("res://TemporaryIcons/weapon_shortsword.png")

func getItemTexture(room):
	match room.getItemType():
		"HEALTH_POTION":
			return healthPotionTexture
		"WEAPON":
			return getWeaponTexture(room.weaponType)
		"GOLD":
			return coinTexture
		"WHETSTONE":
			return whetstoneTexture
		"ARMOR":
			return armorTexture
		"AGILITY":
			return agilityTexture
	return emptyIcon2

func getWeaponTexture(roomWeapon):
	match roomWeapon:
		Room.WeaponType.SWORD:
			return weaponTexture
		Room.WeaponType.AXE:
			return axeTexture
		Room.WeaponType.HAMMER:
			return hammerTexture
		Room.WeaponType.PICKAXE:
			return pickaxeTexture
		Room.WeaponType.SHORTSWORD:
			return shortswordTexture
	return emptyIcon2

func getRoomTexture(room):
	if room.getRoomType() == Room.RoomType.START:
		return startRoomTexture
	elif room.getRoomType() == Room.RoomType.EXIT:
		return exitRoomTexture
	elif room.getRoomType() == Room.RoomType.SHOP:
		if(room.hasPaid and !room.secretRevealed):
			return shopPaidTexture
		else:
			return shopTexture
	elif room.getRoomType() == Room.RoomType.ITEM:
		return itemTexture if room.hasItem else itemTakenTexture
	elif room.getRoomType() == Room.RoomType.TELEPORTER_ENTRANCE:
		return teleporterEntranceTexture
	elif room.getRoomType() == Room.RoomType.TELEPORTER_EXIT:
		return teleporterExitTexture
	elif room.getRoomType() == Room.RoomType.ENEMY:
		if(room.isDead):
			return deadEnemyTexture
		elif(room.enemyType == Room.EnemyType.UNDEAD):
			return undeadEnemyTexture
		else:
			return basicEnemyTexture
	elif room.getRoomType() == Room.RoomType.ARTIFACT:
		return artifactTexture
	elif room.getRoomType() == Room.RoomType.MIMIC:
		return mimicTexture if room.secretRevealed else itemTexture
	elif room.getRoomType() == Room.RoomType.SWAPPER:
		return swapperTexture
	elif room.getRoomType() == Room.RoomType.SOOTHSAYER:
		return soothsayerTexture
	elif room.getRoomType() == Room.RoomType.BOSS:
		return bossTexture
	elif room.getRoomType() == Room.RoomType.HEALTH_ROOM:
		return healthRoomDeadTexture if room.isDead else healthRoomTexture
	elif room.getRoomType() == Room.RoomType.TEMP:
		if room.nearBoss:
			return bossWarningTexture
		elif room.nearEnemy:
			return enemyWarningTexture
		elif room.nearMimic:
			return mimicWarningTexture
		elif room.nearTeleporter:
			return teleporterWarningTexture
		else:
			return emptyRoomTexture
	else:
		return emptyRoomTexture # TODO: replace this with a different texture
