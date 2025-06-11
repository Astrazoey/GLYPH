extends Node2D

const PAGE_SIZE = 14

var pages = []
var currentPage = 0
var chapterHeadings = []
var chapterDescriptions = []

var chapters = {
	"Table of Contents": {
		"description": "Contents of this glossary",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "This text should never display", "type": "icon"},
		],
		"entryCount" : 9
	},
	"Getting Started": {
		"description": "On the right side of the screen, set a class, how many Kings you're willing to risk, and your difficulty.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The class determines the type of adventurer you are sending into the Severance. They have special abilities and different stats", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Your wager determines how many Kings (currency) your adventurer enters the Severance with. If they die inside, the Kings will be lost", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The difficulty determines the size of the Severance, and what types of rooms can appear inside", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "It's recommended to start on the lower difficulties first, and choose the Archivist class for learning the map", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "When you click 'Begin Severance', your adventurer will be sent in", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The top right of the screen shows how much gold you have to wage, and the amount of artifacts collected", "type": "dotpoint"},
		],
		"entryCount" : 14
	},
	"How To Play": {
		"description": "The objective of the game is to send adventurers into the Severance and have them return alive with an Artifact (and maybe some extra gold)",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The adventurer sends you Glyphs in the bottom left of the screen to communicate their location and surroundings", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Your job is to guide the adventurer through the Severence by interpreting the Glyphs and mapping their position", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "You can use the interactive map and abacus however you please to keep track of the adventurers stats and location", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Use this Glossary at any time to see what the glyphs mean", "type": "dotpoint"},
		],
		"entryCount" : 14
	},
	"Game UI": {
		"description": "An explanation of what each element on the UI represents",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/glossary_ui.png"), "text": "...", "type": "image"},
		],
		"entryCount" : 14
	},
	"Abacus": {
		"description": "The abacus lets you keep track of in-game stats. Use it however you please, it has no gameplay effect otherwise.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/glossary_abacus.png"), "text": "...", "type": "image"},
		],
		"entryCount" : 14
	},
	"Interactive Map": {
		"description": "The interactive map allows you to make a map of the current Severance. Left click and right click will fill in the symbols in different ways. You may use this how you please. The Archivist class will draw on the map for you and is a good way for beginners to learn how to use the map.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/glossary_map.png"), "text": "...", "type": "image"},
		],
		"entryCount" : 14
	},
	"Stats": {
		"description": "Info on each class",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Health (HP) determines amount of health for character", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Maximum Health (MAXHP) determines maximum amount of health for character", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Damage (DMG) determines damage dealt by weapons", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Agility (AGI) determines dodge chance from enemies or successful steal chance from shops", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Defense (DEF) determines chance of taking less damage", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Cooldown (CD) prevents ability usage and is reset by discovering new rooms", "type": "dotpoint"},
		],
		"entryCount" : 14
	},
	"Classes": {
		"description": "Info on each class. Consult previous page for stat info",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "ARCHIVIST: 10HP | 20MAXHP | 0DEF | 3AGI | Sword 3DMG | Ability: Draws positions on the map | 0CD", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "SCOUT: 10HP | 20MAXHP | 0DEF | 3AGI | Sword 3DMG | Ability: Shows nearby rooms | 2CD", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "APPRAISER: 10HP | 20MAXHP | 0DEF | 3AGI | Hammer 3DMG | Ability: Shows room info, Shop Discount | 0CD", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "SERFS: 5HP | 15MAXHP | 0DEF | 3AGI | Pickaxe 3DMG | Ability: Send new character on death | 0CD", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "TRAPPER: 10HP | 20MAXHP | 0DEF | 3AGI | Sword 3DMG | Ability: Disarm traps, Mimics show empty item | 2CD", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "FUGITIVE: 10HP | 20MAXHP | 0DEF | 5AGI | Shortsword 3DMG | Ability: First combat initiative, Flees to previous room, -1DMG | 0CD", "type": "dotpoint"},
		],
		"entryCount" : 14
	},
	"Action Glyphs": {
		"description": "Click these Glyphs to perform an action. These will appear based on the context of the room.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/arrowN.png"), "text": "Move adventurer", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/flee.png"), "text": "Run away from enemy to another room", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/destroy_item.png"), "text": "Destroy potential mimic and safely obtain item. Destroys item if it's not a mimic", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/steal.png"), "text": "Attempt to steal from shop", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/dig.png"), "text": "Attempt to dig item from room", "type": "glyph"},
		],
		"entryCount" : 14
	},
	"Ability Glyphs": {
		"description": "Click these Glyphs to perform a class ability. Classes have different abilities, and some abilities have a cooldown which decreases as the player discovers new rooms.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/scout.png"), "text": "Shows the room types of all connected room", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/appraise.png"), "text": "Reveals hidden information such as enemy health, weapon strength, and shop item value", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/disarm.png"), "text": "Disarms traps", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/autofill.png"), "text": "Marks position and paths on the map", "type": "glyph"},
		],
		"entryCount" : 14
	},
	"Basic Room Glyphs": {
		"description" : "Glyphs representing basic room types. Some of these glyphs can be interacted with by clicking on them.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/start.png"), "text": "Starting room", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/empty_room.png"), "text": "Empty room", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/artifact.png"), "text": "Interact to pick up the artifact", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/exit.png"), "text": "Interact to exit the Severance", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/shop.png"), "text": "Interact to pay the shop the amount displayed on the sidebar", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/shop_paid.png"), "text": "Paid shop", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/item.png"), "text": "Interact to pick up item", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/item_picked_up.png"), "text": "Empty item room", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/soothsayer.png"), "text": "Interact to show room types in each cardinal direction", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/health_room.png"), "text": "One time use will tell you how much health you have", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/health_room_dead.png"), "text": "Health display room has been used", "type": "glyph"}
		],
		"entryCount" : 14
	},
	"Death/Exit Glyphs": {
		"description" : "Glyphs representing room exit status or death",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/death.png"), "text": "Adventurer has died and the Severence has closed", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/revive.png"), "text": "Adventurer has died, interact to send in a new one", "type": "glyph"},
		],
		"entryCount" : 14
	},
	"Enemy Glyphs" : {
		"description" : "Glyphs representing enemies. Players cannot move until the enemy is defeated. The damage dealt by the enemy each turn is indicated on the top bar. Use your abacus to track your health. Click on the enemy symbol to attack it.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/enemy_warning.png"), "text": "Empty room with living enemy nearby", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/boss_warning.png"), "text": "Empty room with tough enemy nearby", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/enemy_dead.png"), "text": "Dead enemy, interact to pick up item", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/enemy_basic.png"), "text": "Enemy weak to axes", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/enemy_undead.png"), "text": "Enemy weak to hammers", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/boss.png"), "text": "Tough enemy weak to swords", "type": "glyph"},
		],
		"entryCount" : 12
	},
	"Trap Glyphs" : {
		"description" : "These Glyphs will prevent movement until activated, usually to the player's detriment.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/mimic_warning.png"), "text": "Empty room with active mimic nearby", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/teleporter_warning.png"), "text": "Empty room with active teleporter nearby", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/mimic.png"), "text": "Mimic trap revealed. Click to kill it (or get item)", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/teleporter_entrance.png"), "text": "Teleporter trap entrance - Click this symbol teleport to the teleporter exit", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/teleporter_exit.png"), "text": "Teleporter exit - Click this symbol disable all teleporter traps", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/swapper.png"), "text": "Swap room trap - Two rooms will swap properties with each other somewhere", "type": "glyph"}
		],
		"entryCount" : 14
	},
	"Item Glyphs" : {
		"description" : "Glyphs showing items you can pick up. Interact with the Room Glyph to pick up. Items will trigger as soon as they are picked up. Information about the item will display on the top bar IF the class is able to understand it.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/health_potion.png"), "text": "+HP", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/coin.png"), "text": "Kings Currency", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/whetstone.png"), "text": "+1ATK (capped at weapon's max damage)", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/armor.png"), "text": "+1DEF", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/agility.png"), "text": "+1AGI", "type": "glyph"}
		],
		"entryCount" : 10
	},
	"Weapon Glyphs" : {
		"description" : "Glyphs showing weapons you can pick up. Interact with the Room Glyph to pick up weapons. Picking up a weapon item will swap the adventurer's weapon with the item, as only one weapon can be carried at a time. Information about the weapon will display on the top bar IF the class is able to understand it. Weapon attack is reduced by 1 for each enemy killed.",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/sword.png"), "text": "Sword. MAXDMG = 7", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/weapon_axe.png"), "text": "Axe. MAXDMG = 6", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/weapon_hammer.png"), "text": "Hammer. MAXDMG = 6", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/weapon_pickaxe.png"), "text": "Pickaxe. MAXDMG = 4. Digs items in empty rooms.", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/weapon_shortsword.png"), "text": "Shortsword. MAXDMG = 5. DMG increases are twice as effective", "type": "glyph"}
		],
		"entryCount" : 10
	},
	"Info Glyphs" : {
		"description" : "Glyphs information about the game",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/hurt.png"), "text": "For each one displayed, player has taken 1 damage", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/dodge.png"), "text": "Player has dodged an incoming attack", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/enemy_health.png"), "text": "Each displayed represents 1HP", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/enemy_health2.png"), "text": "Each displayed represents 2HP", "type": "glyph"},
			{"icon": preload("res://TemporaryIcons/enemy_health3.png"), "text": "Each displayed represents 3HP", "type": "glyph"}
		],
		"entryCount" : 14
	},
	"Advanced Tips" : {
		"description" : "Helpful extra information",
		"entries" : [
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Rooms near start will always be empty", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Enemies never spawn next to each other or teleporters", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "On VERY HARD+, a powerful foe appears next to the artifact", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Severences generate in a square grid", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The grid size is fixed per difficulty", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "There is a fixed max amount of rooms per type per Severance, based on difficulty", "type": "dotpoint"},
			{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The start room will never generate on the edge of the grid", "type": "dotpoint"}
		],
		"entryCount" : 14
	}
}



func _ready():
	generatePages()
	displayPage(0)

func generatePages():
	pages.clear()
	
	for chapter in chapters.keys():
		var content = chapters[chapter]["entries"]
		var columnModifier = 1
		
		if(chapters[chapter]["entries"].size() < 1):
			pass
		elif(chapters[chapter]["entries"][0]["type"] == "dotpoint"):
			columnModifier = 2
			
		var pageSize = chapters[chapter]["entryCount"]
		
		for i in range(0, content.size(), pageSize / columnModifier):
			pages.append(content.slice(i, i + pageSize / columnModifier))
			chapterHeadings.append(chapter)
			chapterDescriptions.append(chapters[chapter]["description"])

func displayPage(pageIndex):
	get_node("AudioTurnPage").play()
	
	pageIndex = max(0, pageIndex)
	pageIndex = min(pages.size(), pageIndex)
	
	currentPage = pageIndex
	
	for child in get_children():
		if not child is AudioStreamPlayer:
			child.queue_free()
	
	# Heading
	var title = Label.new()
	title.text = chapterHeadings[currentPage]
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(50, 20)
	add_child(title)
	
	# Description
	var description = Label.new()
	description.autowrap_mode = TextServer.AUTOWRAP_WORD
	description.text = chapterDescriptions[currentPage]
	description.add_theme_font_size_override("font_size", 14)
	description.position = Vector2(50, 60)
	description.size.x = 600
	add_child(description)
	
	var boundary = Label.new()
	boundary.text = "|"
	boundary.add_theme_font_size_override("font_size", 24)
	boundary.position = Vector2(720, 820)
	add_child(boundary)
	
	
	var yOffset = 100 + description.size.y
	var xOffset = 50
	var columnWidth = 320
	var column =  0
	
	if(pageIndex != 0):
		# Display Content

		for i in pages[currentPage].size():
			var entry = pages[currentPage][i]
			
			if(entry["type"] == "glyph"):
				var icon = TextureRect.new()
				icon.texture = entry["icon"]
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.custom_minimum_size = Vector2(64, 64)
				icon.position = Vector2(xOffset + (column * columnWidth), yOffset)
				add_child(icon)
				
				var text = Label.new()
				text.text = entry["text"]
				text.autowrap_mode = TextServer.AUTOWRAP_WORD
				text.add_theme_font_size_override("font_size", 14)
				text.position = Vector2(xOffset + 70 + (column * columnWidth), yOffset + 5)
				text.size = Vector2(250, 200)
				
				add_child(text)
				
				yOffset += 80
				if(i + 1) % (PAGE_SIZE / 2) == 0:
					column = 1
					yOffset = 100 + description.size.y
			elif(entry["type"] == "dotpoint"):
				var dotpoint = TextureRect.new()
				dotpoint.texture = entry["icon"]
				dotpoint.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				dotpoint.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				dotpoint.custom_minimum_size = Vector2(25, 25)
				dotpoint.position = Vector2(xOffset + (column * columnWidth), yOffset)
				add_child(dotpoint)
				
				var text = Label.new()
				text.text = entry["text"]
				text.autowrap_mode = TextServer.AUTOWRAP_WORD
				text.add_theme_font_size_override("font_size", 14)
				text.position = Vector2(xOffset + 35 + (column * columnWidth), yOffset - 5)
				text.size = Vector2(500, 200)
				
				add_child(text)
				yOffset += 80
			elif(entry["type"] == "image"):
				var image = TextureRect.new()
				image.texture = entry["icon"]
				#dotpoint.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				#dotpoint.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				#dotpoint.custom_minimum_size = Vector2(25, 25)
				image.position = Vector2(xOffset + (column * columnWidth), yOffset)
				add_child(image)
				
				yOffset += 80
	else:
		var chapterIndex = 0
		for heading in range(1, chapterHeadings.size()):
			chapterIndex += 1
			
			var skipToChapter = TextureButton.new()
			skipToChapter.texture_normal = preload("res://TemporaryIcons/arrowE.png")
			skipToChapter.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			skipToChapter.custom_minimum_size = Vector2(25, 25)
			skipToChapter.position = Vector2(xOffset + (column * columnWidth), yOffset)
			skipToChapter.pressed.connect(displayPage.bind(chapterIndex))
			add_child(skipToChapter)
			
			
			var chapterHeading = Label.new()
			chapterHeading.autowrap_mode = TextServer.AUTOWRAP_WORD
			chapterHeading.text = chapterHeadings[chapterIndex]
			chapterHeading.add_theme_font_size_override("font_size", 16)
			chapterHeading.position = Vector2(74 + xOffset + (column * columnWidth), yOffset)
			chapterHeading.size.x = 600
			add_child(chapterHeading)
			
			yOffset += 64
			if(chapterIndex + 1) % (20 / 2) == 0:
				column = 1
				yOffset = 100 + description.size.y
			
			
			
	
	# Page Number
	var pageNumber = Label.new()
	pageNumber.text = "Page %d/%d" % [currentPage + 1, pages.size()]
	pageNumber.position = Vector2(320, 780)
	add_child(pageNumber)
	
	# Nav buttons
	if currentPage > 0:
		var backButton = Button.new()
		backButton.text = "<--"
		backButton.position = Vector2(90, 780)
		backButton.pressed.connect(displayPage.bind(currentPage - 1))
		add_child(backButton)
		
	if currentPage < pages.size() - 1:
		var nextButton = Button.new()
		nextButton.text = "-->"
		nextButton.position = Vector2(680, 780)
		nextButton.pressed.connect(displayPage.bind(currentPage + 1))
		add_child(nextButton)
		
	if currentPage > 0:
		var homeButton = Button.new()
		homeButton.text = "Home"
		homeButton.position = Vector2(20, 780)
		homeButton.pressed.connect(displayPage.bind(0))
		add_child(homeButton)
	
