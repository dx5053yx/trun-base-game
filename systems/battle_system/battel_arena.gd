extends Control

# Array untuk menampung semua petarung (Party + Musuh) di arena ini
var turn_queue: Array = []

# Array terpisah untuk memudahkan perhitungan nanti
var active_enemies: Array = []
var active_heroes: Array = []

func _ready():
	print("--- MEMULAI BATTLE ---")
	setup_battle()

func setup_battle():
	# 1. Panggil data tim kamu dari Autoload PartyManager
	# (Pastikan di PartyManager sudah ada karakter yang di-add ke active_party)
	active_heroes = PartyDat.active_party.duplicate()
	
	# 2. Tarik data musuh (Sebagai contoh, kita load 2 Slime)
	# Pastikan kamu sudah bikin slime.tres di data/enemies/ ya!
	var musuh_1 = preload("res://data/enemies/slime.tres")
	var musuh_2 = preload("res://data/enemies/slime.tres")
	
	# Kita harus duplikat agar kalau HP slime 1 berkurang, slime 2 tidak ikut berkurang
	active_enemies.append(musuh_1.duplicate()) 
	active_enemies.append(musuh_2.duplicate())
	
	# 3. Gabungkan pahlawan dan musuh ke dalam satu arena
	turn_queue.append_array(active_heroes)
	turn_queue.append_array(active_enemies)
	
	# 4. Susun giliran berdasarkan SPEED!
	sort_turn_queue()

func sort_turn_queue():
	# Fungsi ajaib Godot untuk mengurutkan array dari speed terbesar ke terkecil
	turn_queue.sort_custom(func(a, b): return a.speed > b.speed)
	
	print("=== URUTAN GILIRAN ===")
	for i in range(turn_queue.size()):
		var battler = turn_queue[i]
		# Karena musuh kita resource-nya sama (EnemyStats), kita asumsikan variabel namanya sama
		var nama = ""
		if battler is CharacterStats:
			nama = battler.character_name
		else:
			# Sesuaikan dengan nama variabel di enemy_stats.gd kamu
			nama = battler.enemy_name 
			
		print(str(i + 1) + ". " + nama + " (Speed: " + str(battler.speed) + ")")
		
	# Setelah diurutkan, panggil giliran pertama
	start_turn()

func start_turn():
	var karakter_sekarang = turn_queue[0]
	print("\n>>> Giliran " + karakter_sekarang.character_name + " sekarang! <<<")
	
	# Nanti di sini kita buat logika: 
	# Jika ini giliran hero, munculkan ActionMenu.
	# Jika ini giliran musuh, jalankan AI musuh secara otomatis.
