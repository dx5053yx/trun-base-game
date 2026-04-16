extends Control

@onready var action_menu = $booton/acction
@onready var skill_menu = $booton/SkillMenu 
@onready var party_positions = $posisi_plyr
@onready var enemy_positions = $posisi_enmy

# Memuat cetakan UI yang baru kita buat
var battler_ui_scene = preload("res://systems/battle_system/BattelUi.tscn")

# Dictionary untuk melacak UI milik siapa (agar darah yang berkurang tidak salah orang)
var ui_nodes = {}
# Array untuk menampung semua petarung (Party + Musuh) di arena ini
var current_battler = null # Menyimpan data siapa yang sedang jalan sekarang
var turn_queue: Array = []

# Array terpisah untuk memudahkan perhitungan 
var active_enemies: Array = []
var active_heroes: Array = []
func _ready():
	print("--- MEMULAI BATTLE ---")
	setup_battle()
	start_turn()
	

func setup_battle():
	# 1. Panggil data tim dari Autoload PartyManager
	active_heroes = PartyDat.active_party.duplicate()
	
	# 2. Tarik data musuh 
	var musuh_1 = preload("res://data/enemies/kroco1.tres")
	var musuh_2 = preload("res://data/enemies/keroco2.tres")
	
	active_enemies.append(musuh_1.duplicate()) 
	active_enemies.append(musuh_2.duplicate())
	# 3. Gabungkan pahlawan dan musuh sekaligus memunculkan visualnya!
	for hero in active_heroes:
		turn_queue.append(hero)
		spawn_ui(hero, true) # true artinya ini hero
	for enemy in active_enemies:
		turn_queue.append(enemy)
		spawn_ui(enemy, false) # false artinya ini musuh
	
	# 4. Susun giliran berdasarkan SPEED!
	sort_turn_queue()
func spawn_ui(battler_stats, is_hero: bool):
	var ui_instance = battler_ui_scene.instantiate()
	
	# Simpan ke dictionary agar nanti mudah dicari saat kena damage
	ui_nodes[battler_stats] = ui_instance 
	
	# Taruh di sisi layar yang benar
	if is_hero:
		party_positions.add_child(ui_instance)
	else:
		enemy_positions.add_child(ui_instance)
		
	# Jalankan setup untuk memunculkan nama dan HP Bar
	ui_instance.setup(battler_stats)

func sort_turn_queue():
	turn_queue.sort_custom(func(a, b): return a.speed > b.speed)
	
	print("=== URUTAN GILIRAN ===")
	for i in range(turn_queue.size()):
		var battler = turn_queue[i]
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
	current_battler = turn_queue[0]
	print("\n>>> Giliran " + current_battler.character_name + " sekarang! <<<")
	
	if current_battler is CharacterStats:
		# Giliran Hero! Munculkan menu tombol
		action_menu.show()
	else:
		# Giliran Musuh! Sembunyikan menu dan biarkan AI jalan
		action_menu.hide()
		enemy_turn()

func enemy_turn():
	print(current_battler.character_name + " (Musuh) bersiap menyerang...")
	# Jeda 1 detik agar tidak terlalu cepat
	await get_tree().create_timer(1.0).timeout
	
	# Pilih target hero secara acak
	if active_heroes.size() > 0:
		var target = active_heroes.pick_random()
		perform_attack(current_battler, target)

# Ini fungsi yang tadi otomatis dibuat saat kamu connect sinyal
func _on_basic_atk_pressed() -> void:
	action_menu.hide() # Sembunyikan menu agar tidak di-klik 2x
	
	# Untuk tes awal, kita otomatis menyerang musuh urutan pertama dulu
	if active_enemies.size() > 0:
		var target = active_enemies[0] 
		perform_attack(current_battler, target)

func perform_attack(attacker, target):
	# Rumus damage sederhana: Attack Power - Defense Target
	var damage = attacker.attack_power - (target.defense / 2)
	if damage < 1: damage = 1 # Minimal damage selalu 1
	
	# Kurangi HP
	target.current_hp -= damage
	# Update visual bar darahnya di layar!
	if ui_nodes.has(target):
		ui_nodes[target].update_hp()
	print("⚔️ " + attacker.character_name + " menyerang " + target.character_name + " sebesar " + str(damage) + " damage!")
	print("❤️ Sisa HP " + target.character_name + ": " + str(target.current_hp) + "/" + str(target.max_hp))
	
	# Cek apakah target mati
	if target.current_hp <= 0:
		print("💀 " + target.character_name + " MATI!")
		turn_queue.erase(target) # Hapus dari antrean
		if target is CharacterStats:
			active_heroes.erase(target)
		else:
			active_enemies.erase(target)
			
	end_turn()

func end_turn():
	# Cek apakah game sudah selesai
	if active_heroes.size() == 0:
		print("--- GAME OVER! Party Hancur ---")
		return
	elif active_enemies.size() == 0:
		print("--- VICTORY! Semua Musuh Kalah ---")
		return
		
	# Pindahkan karakter yang baru selesai beraksi ke urutan paling belakang
	var battler_selesai = turn_queue.pop_front()
	turn_queue.push_back(battler_selesai)
	
	# Jeda 1 detik sebelum giliran selanjutnya
	await get_tree().create_timer(1.0).timeout
	start_turn()


func _on_skill_pressed() -> void:
	action_menu.hide()
	skill_menu.show()
	
	# 1. Bersihkan tombol skill bekas giliran karakter sebelumnya
	for child in skill_menu.get_children():
		child.queue_free()
		
	# 2. Baca data skill dari karakter yang sedang jalan
	if current_battler.skills.size() == 0:
		print("Karakter ini tidak punya skill!")
		
	for skill in current_battler.skills:
		if skill == null: continue # Lewati jika ada slot kosong
		
		var btn = Button.new()
		# Format teks: "Nama Skill (MP: 10)"
		btn.text = skill.skill_name + " (MP: " + str(skill.mp_cost) + ")" 
		
		# Hubungkan tombol ini ke fungsi penggunaan skill
		btn.pressed.connect(func(): _use_skill(skill))
		skill_menu.add_child(btn)
		
	# 3. Tambahkan tombol "Kembali" di paling bawah
	var back_btn = Button.new()
	back_btn.text = "Kembali"
	back_btn.pressed.connect(func():
		skill_menu.hide()
		action_menu.show()
	)
	skill_menu.add_child(back_btn)

# Fungsi sementara untuk mengecek apakah skill berhasil dipanggil
func _use_skill(skill_data):
	# 1. Cek apakah MP cukup
	if current_battler.current_mp < skill_data.mp_cost:
		print("MP " + current_battler.character_name + " tidak cukup!")
		return # Batal pakai skill, biarkan pemain milih aksi lain
		
	# 2. Kurangi MP
	current_battler.current_mp -= skill_data.mp_cost
	print("\n🌟 " + current_battler.character_name + " merapalkan [" + skill_data.skill_name + "]!")
	
	skill_menu.hide()
	
	# 3. Logika Efek Skill (Sementara kita auto-target dulu agar gampang dites)
	if skill_data.effect_type == SkillData.SkillEffect.DAMAGE:
		if active_enemies.size() > 0:
			var target = active_enemies[0] # Otomatis serang musuh pertama
			
			# Rumus damage: Power Skill + Attack Hero - Defense Musuh
			var damage = skill_data.power + current_battler.attack_power - (target.defense / 2)
			if damage < 1: damage = 1
			
			target.current_hp -= damage
			print("💥 Memberikan " + str(damage) + " damage ke " + target.character_name + "!")
			
			if ui_nodes.has(target):
				ui_nodes[target].update_hp()
				
			cek_kematian(target)
			
	elif skill_data.effect_type == SkillData.SkillEffect.HEAL:
		if active_heroes.size() > 0:
			var target = active_heroes[0] # Otomatis heal hero pertama (MC)
			
			target.current_hp += skill_data.power
			if target.current_hp > target.max_hp:
				target.current_hp = target.max_hp # Cegah HP bocor melebihi batas maksimal
				
			print("✨ Memulihkan " + str(skill_data.power) + " HP untuk " + target.character_name + "!")
			
			if ui_nodes.has(target):
				ui_nodes[target].update_hp()

	# Akhiri giliran setelah pakai skill
	end_turn()

# Fungsi baru agar rapi (tambahkan di bagian bawah script)
func cek_kematian(target):
	if target.current_hp <= 0:
		print("💀 " + target.character_name + " MATI!")
		turn_queue.erase(target)
		if target is CharacterStats:
			active_heroes.erase(target)
		else:
			active_enemies.erase(target)
	
