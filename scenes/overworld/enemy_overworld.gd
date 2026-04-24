extends CharacterBody2D

# Data musuh yang akan dikirim ke battle saat player menyentuhnya
@export var enemy_data_1: enemystat
@export var enemy_data_2: enemystat  # opsional, bisa null

# Sudah ketemu player dan sedang proses pindah scene? Jangan trigger dua kali
var _triggered: bool = false

func _on_hitbox_body_entered(body: Node) -> void:
	# Hanya bereaksi ke player, dan hanya sekali
	if _triggered:
		return
	if not body.is_in_group("player"):
		return

	_triggered = true

	# Kumpulkan musuh yang valid (skip yang null)
	var enemies: Array[enemystat] = []
	if enemy_data_1 != null:
		enemies.append(enemy_data_1)
	if enemy_data_2 != null:
		enemies.append(enemy_data_2)

	if enemies.is_empty():
		push_warning("EnemyOverworld: tidak ada enemy_data yang diset di Inspector!")
		_triggered = false
		return

	# Simpan data ke GameDat, lalu pindah ke battle
	GameDat.set_encounter(enemies, get_tree().current_scene.scene_file_path)
	SceneTransition.go_to("res://systems/battle_system/battel_arena.tscn")
