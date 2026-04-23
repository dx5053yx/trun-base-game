extends Node

var roster: Array[CharacterStats] = []
var active_party: Array[CharacterStats] = []

const MAX_PARTY_SIZE: int = 4

func _ready():
	var mc_data  = preload("res://data/characters/mc.tres")
	var teman_1  = preload("res://data/characters/kirara.tres")
	add_to_roster(teman_1)
	add_to_active_party(teman_1)
	add_to_roster(mc_data)
	add_to_active_party(mc_data)

func add_to_roster(character: CharacterStats):
	if not character in roster:
		roster.append(character)

func add_to_active_party(character: CharacterStats) -> bool:
	if active_party.size() >= MAX_PARTY_SIZE:
		return false
	if character in active_party:
		return false
	active_party.append(character)
	return true

func remove_from_active_party(character: CharacterStats):
	if character.is_mc:
		return
	active_party.erase(character)
