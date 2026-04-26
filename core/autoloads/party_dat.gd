extends Node

var roster: Array[CharacterStats] = []
var active_party: Array[CharacterStats] = []

const MAX_PARTY_SIZE: int = 4

# Semua path karakter terdaftar di sini
const ALL_CHARACTERS = [
	"res://data/characters/mc.tres",
	"res://data/characters/kirara.tres",
	"res://data/characters/keren.tres",
	"res://data/characters/kipli.tres",
	"res://data/characters/malik.tres",
	"res://data/characters/nunung.tres",
	"res://data/characters/yanto.tres",
]

func _ready():
	# Load semua karakter ke roster
	for path in ALL_CHARACTERS:
		var char_data = load(path) as CharacterStats
		if char_data:
			roster.append(char_data)

	# Party default: MC selalu masuk, sisanya kosong dulu
	var mc = get_mc()
	if mc:
		active_party.append(mc)

# -------------------------------------------------------

func get_mc() -> CharacterStats:
	for c in roster:
		if c.is_mc:
			return c
	return null

func is_in_party(character: CharacterStats) -> bool:
	return character in active_party

func add_to_active_party(character: CharacterStats) -> bool:
	if active_party.size() >= MAX_PARTY_SIZE:
		return false
	if is_in_party(character):
		return false
	active_party.append(character)
	return true

func remove_from_active_party(character: CharacterStats):
	if character.is_mc:
		return  # MC tidak bisa dikeluarkan
	active_party.erase(character)

func swap_party_member(slot_index: int, new_char: CharacterStats):
	# Keluarkan yang lama (kalau bukan MC)
	if slot_index < active_party.size():
		var old_char = active_party[slot_index]
		if old_char.is_mc:
			return
		active_party.remove_at(slot_index)

	# Kalau new_char sudah ada di slot lain, pindahkan
	var existing_idx = active_party.find(new_char)
	if existing_idx != -1:
		active_party.remove_at(existing_idx)

	# Insert di posisi yang diminta
	active_party.insert(slot_index, new_char)

func get_roster_not_in_party() -> Array[CharacterStats]:
	var result: Array[CharacterStats] = []
	for c in roster:
		if not is_in_party(c):
			result.append(c)
	return result
