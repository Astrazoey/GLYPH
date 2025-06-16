extends Control

var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()
var GlossaryHelper = preload("res://GlossaryHelper.gd").new()

const PAGE_SIZE = 14

var pages = []
var currentPage = 0
var chapterHeadings = []
var chapterDescriptions = []

var pageCount = 0

@onready var nextButton = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Page Control/Next Button"
@onready var backButton = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Page Control/Back Button"
@onready var homeButton = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Page Control/Home Button"
@onready var pageNumber = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Page Control/Page Number"

@onready var headingLabel = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Heading"
@onready var descriptionLabel = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Description"

@onready var column1 = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Entries/MarginContainer1/Column 1"
@onready var column2 = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Entries/MarginContainer2/Column 2"
@onready var vSeparator = $"MarginContainer/Contents Page/MarginContainer/VBoxContainer/Entries/VSeparator"

#var chapters = {
	#"Table of Contents": {
		#"description": "Contents of this glossary",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "This text should never display", "type": "icon"},
		#],
		#"entryCount" : 9
	#},
	#"Getting Started": {
		#"description": "On the right side of the screen, set a class, how many Kings you're willing to risk, and your difficulty.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The class determines the type of adventurer you are sending into the Severance. They have special abilities and different stats", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Your wager determines how many Kings (currency) your adventurer enters the Severance with. If they die inside, the Kings will be lost", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The difficulty determines the size of the Severance, and what types of rooms can appear inside", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "It's recommended to start on the lower difficulties first, and choose the Archivist class for learning the map", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "When you click 'Begin Severance', your adventurer will be sent in", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The top right of the screen shows how much gold you have to wage, and the amount of artifacts collected", "type": "dotpoint"},
		#],
		#"entryCount" : 14
	#},
	#"How To Play": {
		#"description": "The objective of the game is to send adventurers into the Severance and have them return alive with an Artifact (and maybe some extra gold)",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The adventurer sends you Glyphs in the bottom left of the screen to communicate their location and surroundings", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Your job is to guide the adventurer through the Severence by interpreting the Glyphs and mapping their position", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "You can use the interactive map and abacus however you please to keep track of the adventurers stats and location", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Use this Glossary at any time to see what the glyphs mean", "type": "dotpoint"},
		#],
		#"entryCount" : 14
	#},
	#"Game UI": {
		#"description": "An explanation of what each element on the UI represents",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/glossary_ui.png"), "text": "...", "type": "image"},
		#],
		#"entryCount" : 14
	#},
	#"Abacus": {
		#"description": "The abacus lets you keep track of in-game stats. Use it however you please, it has no gameplay effect otherwise.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/glossary_abacus.png"), "text": "...", "type": "image"},
		#],
		#"entryCount" : 14
	#},
	#"Interactive Map": {
		#"description": "The interactive map allows you to make a map of the current Severance. Left click and right click will fill in the symbols in different ways. You may use this how you please. The Archivist class will draw on the map for you and is a good way for beginners to learn how to use the map.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/glossary_map.png"), "text": "...", "type": "image"},
		#],
		#"entryCount" : 14
	#},
	#"Stats": {
		#"description": "Info on each class",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Health (HP) determines amount of health for character", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Maximum Health (MAXHP) determines maximum amount of health for character", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Damage (DMG) determines damage dealt by weapons", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Agility (AGI) determines dodge chance from enemies or successful steal chance from shops", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Defense (DEF) determines chance of taking less damage", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Cooldown (CD) prevents ability usage and is reset by discovering new rooms", "type": "dotpoint"},
		#],
		#"entryCount" : 14
	#},
	#"Classes": {
		#"description": "Info on each class. Consult previous page for stat info",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "ARCHIVIST: 10HP | 20MAXHP | 0DEF | 3AGI | Sword 3DMG | Ability: Draws positions on the map | 0CD", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "SCOUT: 10HP | 20MAXHP | 0DEF | 3AGI | Sword 3DMG | Ability: Shows nearby rooms | 2CD", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "APPRAISER: 10HP | 20MAXHP | 0DEF | 3AGI | Hammer 3DMG | Ability: Shows room info, Shop Discount | 0CD", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "SERFS: 5HP | 15MAXHP | 0DEF | 3AGI | Pickaxe 3DMG | Ability: Send new character on death | 0CD", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "TRAPPER: 10HP | 20MAXHP | 0DEF | 3AGI | Sword 3DMG | Ability: Disarm traps, Mimics show empty item | 2CD", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "FUGITIVE: 10HP | 20MAXHP | 0DEF | 5AGI | Shortsword 3DMG | Ability: First combat initiative, Flees to previous room, -1DMG | 0CD", "type": "dotpoint"},
		#],
		#"entryCount" : 14
	#},
	#"Action Glyphs": {
		#"description": "Click these Glyphs to perform an action. These will appear based on the context of the room.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/arrowN.png"), "text": "Move adventurer", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/flee.png"), "text": "Run away from enemy to another room", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/destroy_item.png"), "text": "Destroy potential mimic and safely obtain item. Destroys item if it's not a mimic", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/steal.png"), "text": "Attempt to steal from shop", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/dig.png"), "text": "Attempt to dig item from room", "type": "glyph"},
		#],
		#"entryCount" : 14
	#},
	#"Ability Glyphs": {
		#"description": "Click these Glyphs to perform a class ability. Classes have different abilities, and some abilities have a cooldown which decreases as the player discovers new rooms.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/scout.png"), "text": "Shows the room types of all connected room", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/appraise.png"), "text": "Reveals hidden information such as enemy health, weapon strength, and shop item value", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/disarm.png"), "text": "Disarms traps", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/autofill.png"), "text": "Marks position and paths on the map", "type": "glyph"},
		#],
		#"entryCount" : 14
	#},
	#"Basic Room Glyphs": {
		#"description" : "Glyphs representing basic room types. Some of these glyphs can be interacted with by clicking on them.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/start.png"), "text": "Starting room", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/empty_room.png"), "text": "Empty room", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/artifact.png"), "text": "Interact to pick up the artifact", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/exit.png"), "text": "Interact to exit the Severance", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/shop.png"), "text": "Interact to pay the shop the amount displayed on the sidebar", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/shop_paid.png"), "text": "Paid shop", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/item.png"), "text": "Interact to pick up item", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/item_picked_up.png"), "text": "Empty item room", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/soothsayer.png"), "text": "Interact to show room types in each cardinal direction", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/health_room.png"), "text": "One time use will tell you how much health you have", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/health_room_dead.png"), "text": "Health display room has been used", "type": "glyph"}
		#],
		#"entryCount" : 14
	#},
	#"Death/Exit Glyphs": {
		#"description" : "Glyphs representing room exit status or death",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/death.png"), "text": "Adventurer has died and the Severence has closed", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/revive.png"), "text": "Adventurer has died, interact to send in a new one", "type": "glyph"},
		#],
		#"entryCount" : 14
	#},
	#"Enemy Glyphs" : {
		#"description" : "Glyphs representing enemies. Players cannot move until the enemy is defeated. The damage dealt by the enemy each turn is indicated on the top bar. Use your abacus to track your health. Click on the enemy symbol to attack it.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/enemy_warning.png"), "text": "Empty room with living enemy nearby", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/boss_warning.png"), "text": "Empty room with tough enemy nearby", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/enemy_basic.png"), "text": "Enemy weak to axes", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/enemy_dead.png"), "text": "Dead enemy, interact to pick up item", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/enemy_undead.png"), "text": "Enemy weak to hammers", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/enemy_undead_dead.png"), "text": "Dead enemy, interact to pick up item", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/boss.png"), "text": "Tough enemy weak to swords", "type": "glyph"},
		#],
		#"entryCount" : 12
	#},
	#"Trap Glyphs" : {
		#"description" : "These Glyphs will prevent movement until activated, usually to the player's detriment.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/mimic_warning.png"), "text": "Empty room with active mimic nearby", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/teleporter_warning.png"), "text": "Empty room with active teleporter nearby", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/mimic.png"), "text": "Mimic trap revealed. Click to kill it (or get item)", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/teleporter_entrance.png"), "text": "Teleporter trap entrance - Click this symbol teleport to the teleporter exit", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/teleporter_exit.png"), "text": "Teleporter exit - Click this symbol disable all teleporter traps", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/swapper.png"), "text": "Swap room trap - Two rooms will swap properties with each other somewhere", "type": "glyph"}
		#],
		#"entryCount" : 14
	#},
	#"Item Glyphs" : {
		#"description" : "Glyphs showing items you can pick up. Interact with the Room Glyph to pick up. Items will trigger as soon as they are picked up. Information about the item will display on the top bar IF the class is able to understand it.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/health_potion.png"), "text": "+HP", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/coin.png"), "text": "Kings Currency", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/whetstone.png"), "text": "+1ATK (capped at weapon's max damage)", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/armor.png"), "text": "+1DEF", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/agility.png"), "text": "+1AGI", "type": "glyph"}
		#],
		#"entryCount" : 10
	#},
	#"Weapon Glyphs" : {
		#"description" : "Glyphs showing weapons you can pick up. Interact with the Room Glyph to pick up weapons. Picking up a weapon item will swap the adventurer's weapon with the item, as only one weapon can be carried at a time. Information about the weapon will display on the top bar IF the class is able to understand it. Weapon attack is reduced by 1 for each enemy killed.",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/sword.png"), "text": "󱥵󱥚󱥖󱤭󱥮", "type": "sitelen"},
			#{"icon": preload("res://TemporaryIcons/weapon_axe.png"), "text": "󱥵󱥚󱥖󱤭󱥳", "type": "sitelen"},
			#{"icon": preload("res://TemporaryIcons/weapon_hammer.png"), "text": "󱥵󱥚󱥖󱤭󱥳", "type": "sitelen"},
			#{"icon": preload("res://TemporaryIcons/weapon_pickaxe.png"), "text": "󱥵󱥚󱥖󱥮󱥮, 󱤃󱤉󱤌󱥭󱤌󱤂", "type": "sitelen"},
			#{"icon": preload("res://TemporaryIcons/weapon_shortsword.png"), "text": "󱥵󱥚󱥖󱤭,   󱥵󱥝󱤧󱥣󱥮", "type": "sitelen"}
		#],
		#"entryCount" : 10
	#},
	#"Info Glyphs" : {
		#"description" : "Glyphs information about the game",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/hurt.png"), "text": "For each one displayed, player has taken 1 damage", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/dodge.png"), "text": "Player has dodged an incoming attack", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/enemy_health.png"), "text": "Each displayed represents 1HP", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/enemy_health2.png"), "text": "Each displayed represents 2HP", "type": "glyph"},
			#{"icon": preload("res://TemporaryIcons/enemy_health3.png"), "text": "Each displayed represents 3HP", "type": "glyph"}
		#],
		#"entryCount" : 14
	#},
	#"Advanced Tips" : {
		#"description" : "Helpful extra information",
		#"entries" : [
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Rooms near start will always be empty", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Enemies never spawn next to each other or teleporters", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "On VERY HARD+, a powerful foe appears next to the artifact", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "Severences generate in a square grid", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The grid size is fixed per difficulty", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "There is a fixed max amount of rooms per type per Severance, based on difficulty", "type": "dotpoint"},
			#{"icon": preload("res://TemporaryIcons/arrowE.png"), "text": "The start room will never generate on the edge of the grid", "type": "dotpoint"}
		#],
		#"entryCount" : 14
	#}
#}

var chapters = {}
@export_file("*.json") var glossaryFile: String = "res://GlossaryBook/glyph_glossary.json"

func _ready():
	
	openGlossaryFile()
	
	get_node("MarginContainer").custom_minimum_size = Vector2(get_window().size)
	get_node("MarginContainer").size = Vector2(get_window().size)
	# Page Count
	for heading in chapters:
		var numberOfEntries = 0
		var maximumEntriesPerPage = 14
		var headingData = chapters[heading]
		headingData.pageNumber = pageCount
		if "entryCount" in headingData:
			maximumEntriesPerPage = headingData["entryCount"]
		
		if "entries" in headingData:
			for entry in headingData["entries"]:
				numberOfEntries += 1
		
		if numberOfEntries > maximumEntriesPerPage:
			pageCount += numberOfEntries / maximumEntriesPerPage
		else:
			pageCount += 1
			
		
	displayHeading()
	
	# Bottom Page
	displayPageNumber()
	nextButton.connect("pressed", func(): goToPage(currentPage + 1))
	backButton.connect("pressed", func(): goToPage(currentPage - 1))
	homeButton.connect("pressed", goToPage.bind(0))
	

	pass

func openGlossaryFile():
	var file = FileAccess.open(glossaryFile, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var raw_data = JSON.parse_string(content)
		if raw_data:
			# Convert image paths to preloaded Textures
			for chapter in raw_data.keys():
				for entry in raw_data[chapter]["entries"]:
					for part in entry:
						if "small_icon" in part:
							part["small_icon"] = load(part["small_icon"])
						elif "icon" in part:
							part["icon"] = load(part["icon"])
			chapters = raw_data

func displayHeading():
	for heading in chapters:
		var headingData = chapters[heading]
		if headingData.pageNumber == currentPage:
			headingLabel.text = heading
			descriptionLabel.text = headingData["description"]
			
	for child in column1.get_children():
			child.queue_free()
			
	for child in column2.get_children():
			child.queue_free()
			
	if currentPage == 0:
		
		var skippedFirstPage = false
		for heading in chapters:
			if(!skippedFirstPage):
				skippedFirstPage = true
			else:
				var headingData = chapters[heading]
				var hBox = HBoxContainer.new()


				var skipToChapter = TextureButton.new()
				skipToChapter.texture_normal = preload("res://TemporaryIcons/arrowE.png")
				skipToChapter.texture_hover = preload("res://TemporaryIcons/arrowE_hovered.png")
				skipToChapter.stretch_mode = TextureButton.STRETCH_SCALE
				skipToChapter.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				skipToChapter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				skipToChapter.custom_minimum_size = Vector2(8, 8)
				skipToChapter.size = Vector2(8, 8)
				skipToChapter.pressed.connect(goToPage.bind(headingData.pageNumber))
				hBox.add_child(skipToChapter)
				
				var text = Label.new()
				var labelSettings = load("res://Label Settings/description.tres")
				var chapterHeading = Label.new()
				chapterHeading.autowrap_mode = TextServer.AUTOWRAP_WORD
				chapterHeading.text = heading
				chapterHeading.label_settings = labelSettings
				#chapterHeading.add_theme_font_size_override("font_size", 16)
				chapterHeading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				hBox.add_child(chapterHeading)
				
				column1.add_child(hBox)
	else:
		for heading in chapters:
			var headingData = chapters[heading]
			if headingData.pageNumber == currentPage:
				var entryCounter = 0
				for entryLine in headingData["entries"]:
					entryCounter += 1
					var hBoxMargin = MarginContainer.new()
					hBoxMargin.add_theme_constant_override("margin_bottom", 20)
					if(entryCounter < (headingData["entryCount"]+2) / 2):
						column1.add_child(hBoxMargin)
					else:
						column2.add_child(hBoxMargin)
					var hBox = HBoxContainer.new()
					for entry in entryLine:
						if "small_icon" in entry:
							var icon = TextureRect.new()
							icon.texture = entry["small_icon"]
							icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
							icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
							icon.custom_minimum_size = Vector2(32, 32)
							icon.size = Vector2(32, 32)
							hBox.add_child(icon)
						elif "icon" in entry:
							var icon = TextureRect.new()
							icon.texture = entry["icon"]
							icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
							icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
							icon.custom_minimum_size = Vector2(64, 64)
							icon.size = Vector2(64, 64)
							hBox.add_child(icon)
						elif "text" in entry:
							var text = Label.new()
							var labelSettings = load("res://Label Settings/description.tres")
							text.text = entry["text"]
							text.autowrap_mode = TextServer.AUTOWRAP_WORD
							text.label_settings = labelSettings
							text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
							hBox.add_child(text)
						elif "sitelen" in entry:
							var text = Label.new()
							var labelSettings = load("res://Label Settings/sitelen.tres")
							text.text = entry["sitelen"]
							text.autowrap_mode = TextServer.AUTOWRAP_WORD
							text.label_settings = labelSettings
							text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
							text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
							hBox.add_child(text)

						hBoxMargin.add_child(hBox)
			

func goToPage(page):
	currentPage = max(min(page, pageCount-1), 0)
	get_node("AudioTurnPage").play()
	displayHeading()
	displayPageNumber()
	
	
func displayPageNumber():
	pageNumber.text = "Page %d/%d" % [(currentPage + 1), pageCount]
