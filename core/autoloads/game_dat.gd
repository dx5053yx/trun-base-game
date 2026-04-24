extends Node

#  ENCOUNTER DATA
#  Diisi oleh overworld sebelum pindah ke battle scene.
#  Dikosongkan kembali oleh battle arena setelah selesai dibaca.

# Array of enemystat — musuh yang akan muncul di battle berikutnya
var pending_enemies: Array[enemystat] = []

# Lokasi/scene overworld yang harus dikembalikan setelah battle selesai
var return_scene: String = ""

# Apakah battle yang akan datang adalah boss fight?
var is_boss_battle: bool = false

#  FUNGSI PENGISIAN (dipanggil dari overworld)

# Pakai ini untuk encounter musuh biasa (bisa 1 atau lebih)
func set_encounter(enemies: Array[enemystat], from_scene: String):
	pending_enemies.clear()
	for e in enemies:
		pending_enemies.append(e.duplicate()) # duplicate() agar HP-nya fresh
	return_scene = from_scene
	is_boss_battle = false

# ini untuk boss fight
func set_boss_encounter(boss: enemystat, from_scene: String):
	pending_enemies.clear()
	pending_enemies.append(boss.duplicate())
	return_scene = from_scene
	is_boss_battle = true

#  FUNGSI PEMBACAAN (dipanggil dari battel_arena.gd)

# Kembalikan list musuh dan langsung kosongkan pending
func consume_encounter() -> Array[enemystat]:
	var result = pending_enemies.duplicate()
	pending_enemies.clear()
	return result

# Cek apakah ada encounter yang menunggu (safety check)
func has_pending_encounter() -> bool:
	return pending_enemies.size() > 0

#  PROGRESS & FLAG CERITA
#  Gunakan ini untuk menyimpan kejadian penting dalam cerita.
#  Contoh: GameDat.set_flag("sudah_ketemu_kirara", true)

var _flags: Dictionary = {}

func set_flag(key: String, value):
	_flags[key] = value

func get_flag(key: String, default = false):
	return _flags.get(key, default)

func has_flag(key: String) -> bool:
	return _flags.has(key)
