extends VBoxContainer

@onready var name_label = $Label
@onready var hp_bar = $ProgressBar
@onready var energy_bar = $energi # Panggil bar energi baru
@onready var sprite_karakter = $SpriteKarakter # Tambahkan ini di atas
var stats = null

func setup(data_stats):
	stats = data_stats
	name_label.text = stats.character_name
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.current_hp
	if stats.sprite_texture != null:
		sprite_karakter.texture = stats.sprite_texture
	if stats is CharacterStats:
		energy_bar.show()
		energy_bar.max_value = stats.max_energy
		energy_bar.value = stats.current_energy
	else:
		energy_bar.hide() # Musuh tidak perlu kelihatan energinya

func update_hp():
	hp_bar.value = stats.current_hp

# Fungsi baru untuk mengupdate bar energi
func update_energy():
	if stats is CharacterStats:
		energy_bar.value = stats.current_energy
