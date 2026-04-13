extends VBoxContainer

# Mengambil referensi ke Label dan ProgressBar
@onready var name_label = $Label
@onready var hp_bar = $ProgressBar

var stats = null # Menyimpan data statistik milik karakter ini

# Fungsi ini akan dipanggil saat karakter ini muncul di arena
func setup(data_stats):
	stats = data_stats
	
	# Karena di musuh dan hero kita menamai variabelnya sama (character_name, max_hp, current_hp),
	# kita bisa langsung panggil seperti ini:
	name_label.text = stats.character_name
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.current_hp

# Fungsi untuk memperbarui bar darah saat kena damage
func update_hp():
	hp_bar.value = stats.current_hp
