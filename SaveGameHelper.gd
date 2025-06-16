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

func loadGame(slot: int, outputVariables):
	var path = "user://save_slot_%d.save" % slot
	if not FileAccess.file_exists(path):
		print("Save file not found for slot %d" % slot)
		outputVariables = startDefaultSave(slot)
		return outputVariables
	
	var file = FileAccess.open(path, FileAccess.READ)
	var saveData = JSON.parse_string(file.get_as_text())
	file.close()

	if saveData:
		outputVariables.saveSlot = saveData.get("saveSlot", -1)
		outputVariables.gold = saveData.get("gold", 0)
		outputVariables.artifactCount = saveData.get("artifactCount", 0)
		outputVariables.weapons = saveData.get("weapons", [])
		for i in outputVariables.weapons.size():
			outputVariables.weapons[i] = int(outputVariables.weapons[i])  # ensures they’re clean ints
		outputVariables.weaponStrengths = saveData.get("weaponStrengths", [])
		outputVariables.winCount = saveData.get("winCount", 0)
	else:
		outputVariables = startDefaultSave(slot)
		#print("Failed to load save data from slot %d" % slot)
	
	return outputVariables
	
func startDefaultSave(slot):
	print("loading default save!")
	var outputVariables = {}
	outputVariables.saveSlot = slot
	outputVariables.gold = 15
	outputVariables.artifactCount = 0
	outputVariables.weapons = []
	outputVariables.weaponStrengths = []
	outputVariables.winCount = 0
	return outputVariables


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
