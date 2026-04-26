extends Node

# =============================================================
#  SaveDat — Autoload
#  Cara pakai:
#    SaveDat.simpan()   → tulis ke file
#    SaveDat.muat()     → baca dari file, return true jika ada save
#    SaveDat.ada_save() → cek apakah file save ada
# =============================================================

const SAVE_PATH = "user://savegame.json"

func ada_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func simpan():
	var data = {}

	# 1. Simpan komposisi party (pakai path file resource-nya)
	var party_paths: Array = []
	for char_data in PartyDat.active_party:
		party_paths.append(char_data.resource_path)
	data["active_party"] = party_paths

	# 2. Simpan HP & Energy tiap karakter di roster
	var char_states: Dictionary = {}
	for char_data in PartyDat.roster:
		char_states[char_data.resource_path] = {
			"current_hp":     char_data.current_hp,
			"current_energy": char_data.current_energy,
		}
	data["char_states"] = char_states

	# 3. Simpan flag cerita
	data["flags"] = GameDat._flags.duplicate()

	# 4. Simpan scene terakhir
	data["last_scene"] = get_tree().current_scene.scene_file_path

	# Tulis ke file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func muat() -> bool:
	if not ada_save():
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_text) != OK:
		return false

	var data: Dictionary = json.get_data()

	# 1. Pulihkan HP & Energy tiap karakter
	var char_states: Dictionary = data.get("char_states", {})
	for char_data in PartyDat.roster:
		var path = char_data.resource_path
		if char_states.has(path):
			char_data.current_hp     = int(char_states[path]["current_hp"])
			char_data.current_energy = int(char_states[path]["current_energy"])

	# 2. Pulihkan komposisi party
	var party_paths: Array = data.get("active_party", [])
	PartyDat.active_party.clear()
	for path in party_paths:
		for char_data in PartyDat.roster:
			if char_data.resource_path == path:
				PartyDat.active_party.append(char_data)
				break

	# 3. Pulihkan flags
	var flags = data.get("flags", {})
	for key in flags:
		GameDat.set_flag(key, flags[key])

	return true

func hapus_save():
	if ada_save():
		DirAccess.remove_absolute(SAVE_PATH)
