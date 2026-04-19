extends Node

# Array untuk menampung semua karakter yang sudah direkrut (Maksimal 6 atau lebih)
var roster: Array[CharacterStats] = []

# Array untuk menampung karakter yang ikut bertarung (Maksimal 4)
var active_party: Array[CharacterStats] = []

const MAX_PARTY_SIZE: int = 4

# Fungsi ini otomatis berjalan saat game pertama kali dimulai
func _ready():
	# Memasukkan MC sebagai anggota pertama secara otomatis
	var mc_data = preload("res://data/characters/mc.tres")
	var teman_1 = preload("res://data/characters/kirara.tres")
	add_to_roster(teman_1)
	add_to_active_party(teman_1)
	add_to_roster(mc_data)
	add_to_active_party(mc_data)

# Fungsi untuk merekrut karakter baru ke dalam gudang/roster
func add_to_roster(character: CharacterStats):
	if not character in roster:
		roster.append(character)
		print(character.character_name + " bergabung dengan party!")

# Fungsi untuk memasukkan karakter ke tim utama (yang ikut battle)
func add_to_active_party(character: CharacterStats) -> bool:
	# Cek apakah tim sudah penuh atau karakter sudah ada di tim
	if active_party.size() >= MAX_PARTY_SIZE:
		print("Party sudah penuh! Maksimal 4 orang.")
		return false
		
	if character in active_party:
		return false
		
	active_party.append(character)
	return true

# Fungsi untuk mengeluarkan karakter dari tim utama
func remove_from_active_party(character: CharacterStats):
	# Aturan khusus: MC tidak boleh dikeluarkan dari party!
	if character.is_mc:
		print("Tidak bisa mengeluarkan Karakter Utama dari party!")
		return
		
	active_party.erase(character)
