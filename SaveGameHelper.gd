extends Node


func saveGame(saveData, slot):
	var file = FileAccess.open("user://save_slot_%d.save" % slot, FileAccess.WRITE)
	file.store_string(JSON.stringify(saveData))
	file.close()

func loadGame(slot: int, outputVariables):
	var path = "user://save_slot_%d.save" % slot
	if not FileAccess.file_exists(path):
		#print("Save file not found for slot %d" % slot)
		outputVariables = startDefaultSave()
		return outputVariables
	
	var file = FileAccess.open(path, FileAccess.READ)
	var saveData = JSON.parse_string(file.get_as_text())
	file.close()

	if saveData:
		outputVariables.gold = saveData.get("gold", 0)
		outputVariables.artifactCount = saveData.get("artifactCount", 0)
		outputVariables.weapons = saveData.get("weapons", [])
		for i in outputVariables.weapons.size():
			outputVariables.weapons[i] = int(outputVariables.weapons[i])  # ensures they’re clean ints
		outputVariables.weaponStrengths = saveData.get("weaponStrengths", [])
		outputVariables.winCount = saveData.get("winCount", 0)
	else:
		outputVariables = startDefaultSave()
		#print("Failed to load save data from slot %d" % slot)
	
	return outputVariables
	
func startDefaultSave():
	var outputVariables = {}
	outputVariables.gold = 15
	outputVariables.artifactCount = 0
	outputVariables.weapons = []
	outputVariables.weaponStrengths = []
	return outputVariables
