extends Node


func saveGame(slot):
	
	var saveData = updateSaveData(slot)
	
	var file = FileAccess.open("user://save_slot_%d.save" % slot, FileAccess.WRITE)
	file.store_string(JSON.stringify(saveData))
	file.close()
	
	# Save slot metadata
	var metadata = {
		"name": saveData.get("character_name", "Unknown"),
		"gold": saveData.get("gold", 0),
		"artifactCount": saveData.get("artifactCount", 0),
	}

	saveSlotMetadata(slot, metadata)

func loadGame(slot: int):
	var path = "user://save_slot_%d.save" % slot
	if not FileAccess.file_exists(path):
		print("Save file not found for slot %d" % slot)
		startDefaultSave(slot)
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	var saveData = JSON.parse_string(file.get_as_text())
	file.close()

	if saveData:
		StoredElements.saveSlot = saveData.get("saveSlot", -1)
		StoredElements.gold = saveData.get("gold", 0)
		StoredElements.artifactCount = saveData.get("artifactCount", 0)
		StoredElements.weapons = saveData.get("weapons", [])
		for i in StoredElements.weapons.size():
			StoredElements.weapons[i] = int(StoredElements.weapons[i])  # ensures they’re clean ints
		StoredElements.weaponStrengths = saveData.get("weaponStrengths", [])
		StoredElements.highestDifficultyWinCount = saveData.get("winCount", 0)
	else:
		startDefaultSave(slot)
		#print("Failed to load save data from slot %d" % slot)
	

	StoredElements.updateUnlocks()
	#print("load game output variables are", outputVariables)
	return
	
	
func startDefaultSave(slot):
	print("loading default save!")
	#var outputVariables = {}
	StoredElements.saveSlot = slot
	StoredElements.gold = 15
	StoredElements.artifactCount = 0
	StoredElements.weapons = []
	StoredElements.weaponStrengths = []
	StoredElements.highestDifficultyWinCount = 0
	StoredElements.updateUnlocks()


func saveSlotMetadata(slot: int, metadata: Dictionary):
	var meta_path = "user://save_metadata.json"
	var all_metadata: Dictionary = {}

	if FileAccess.file_exists(meta_path):
		var file = FileAccess.open(meta_path, FileAccess.READ)
		var parse_result = JSON.parse_string(file.get_as_text())
		all_metadata = parse_result
		file.close()

	all_metadata["%d" % slot] = metadata
	all_metadata["lastSave"] = slot

	var file = FileAccess.open(meta_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(all_metadata))
	file.close()
	
func loadAllSlotMetadata() -> Dictionary:
	var meta_path = "user://save_metadata.json"
	var metaDataDictionary: Dictionary = {}

	if FileAccess.file_exists(meta_path):
		var file = FileAccess.open(meta_path, FileAccess.READ)
		metaDataDictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		return metaDataDictionary
	else:
		return {}

func getLastSaveSlot():
	var metadata = loadAllSlotMetadata()
	
	return metadata.get("lastSave", -1)

func updateSaveData(slot):
	var saveData = {
		"saveSlot" : slot,
		"gold": StoredElements.gold,
		"artifactCount": StoredElements.artifactCount,
		"weapons": StoredElements.weapons,
		"weaponStrengths": StoredElements.weaponStrengths,
		"winCount" : StoredElements.highestDifficultyWinCount
	}
	
	return saveData
