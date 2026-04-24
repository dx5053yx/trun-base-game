extends Node2D

func _ready():
	# Pastikan player ada di group "player" agar hitbox enemy bisa mendeteksi
	var player = $Player
	if player and not player.is_in_group("player"):
		player.add_to_group("player")
