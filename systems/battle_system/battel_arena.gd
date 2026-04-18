extends Control

@onready var action_menu = $booton/acction
@onready var skill_menu = $booton/SkillMenu 
@onready var party_positions = $posisi_plyr
@onready var enemy_positions = $posisi_enmy
@onready var sp_label = $SP # Pastikan namanya sesuai
@onready var target_menu = $booton/TargetMenu
# --- SISTEM SHARED SP TIM ---
var max_team_sp: int = 5
var team_sp: int = 3 # Modal awal saat battle mulai

# (Nanti kamu bisa bikin UI Label khusus di layar untuk nampilin angka ini)
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

func update_sp_ui():
	sp_label.text = "SP Tim: " + str(team_sp) + " / " + str(max_team_sp)

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
	update_sp_ui()

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
	
# Fungsi dinamis untuk memunculkan daftar target
func buka_menu_target(daftar_target: Array, fungsi_eksekusi: Callable):
	target_menu.show()
	
	# Bersihkan tombol bekas giliran sebelumnya
	for child in target_menu.get_children():
		child.queue_free()
		
	# Buat tombol untuk setiap target (misal: "Kroco (HP: 50)")
	for target in daftar_target:
		var btn = Button.new()
		btn.text = target.character_name + " (HP: " + str(target.current_hp) + ")"
		
		# Saat tombol diklik, sembunyikan menu dan jalankan fungsi serangannya!
		btn.pressed.connect(func():
			target_menu.hide()
			fungsi_eksekusi.call(target)
		)
		target_menu.add_child(btn)
		
	# Tambahkan tombol Kembali/Batal
	var back_btn = Button.new()
	back_btn.text = "Kembali"
	back_btn.pressed.connect(func():
		target_menu.hide()
		action_menu.show()
	)
	target_menu.add_child(back_btn)

func sort_turn_queue():
	turn_queue.sort_custom(func(a, b): return a.speed > b.speed)
	
	print("=== URUTAN GILIRAN ===")
	for i in range(turn_queue.size()):
		var battler = turn_queue[i]
		# Langsung panggil character_name tanpa if-else!
		print(str(i + 1) + ". " + battler.character_name + " (Speed: " + str(battler.speed) + ")")
		
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
	action_menu.hide()
	# Alihkan ke menu target musuh, dan bawa fungsi eksekusi basic attack-nya
	if active_enemies.size() > 0:
		buka_menu_target(active_enemies, _eksekusi_basic_attack)

# Ini adalah fungsi yang benar-benar melakukan pengurangan darah dan penambahan SP
func _eksekusi_basic_attack(target):
	# 1. Tambah SP Tim
	if team_sp < max_team_sp:
		team_sp += 1
	update_sp_ui()
	
	# 2. Tambah Energy Ultimate
	current_battler.current_energy += 20
	if current_battler.current_energy > current_battler.max_energy:
		current_battler.current_energy = current_battler.max_energy
		
	if ui_nodes.has(current_battler):
		ui_nodes[current_battler].update_energy()
		
	# 3. Eksekusi damage ke target yang barusan di-klik!
	perform_attack(current_battler, target)

func perform_attack(attacker, target):
	var damage = attacker.attack_power - (target.defense / 2)
	if damage < 1: damage = 1 
	
	target.current_hp -= damage
	if ui_nodes.has(target):
		ui_nodes[target].update_hp()
		
	print("⚔️ " + attacker.character_name + " menyerang " + target.character_name + " sebesar " + str(damage) + " damage!")
	print("❤️ Sisa HP " + target.character_name + ": " + str(target.current_hp) + "/" + str(target.max_hp))
	
	# Panggil fungsi yang sudah kamu buat dengan susah payah!
	cek_kematian(target)
			
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
func _siapkan_skill(skill_data):
	# Bayar SP atau Energy dulu
	if skill_data.is_ultimate:
		if current_battler.current_energy < skill_data.energy_cost:
			print("🔥 Energy tidak cukup!")
			return
		current_battler.current_energy -= skill_data.energy_cost
	else:
		if team_sp < skill_data.sp_cost:
			print("🔋 SP Tim tidak cukup!")
			return 
		team_sp -= skill_data.sp_cost
		
		# Nambah energy karena pakai skill biasa
		current_battler.current_energy += skill_data.energy_gained
		if current_battler.current_energy > current_battler.max_energy:
			current_battler.current_energy = current_battler.max_energy
			
	# Update tampilan bar energi dan teks SP
	update_sp_ui()
	if ui_nodes.has(current_battler):
		ui_nodes[current_battler].update_energy()
		
	skill_menu.hide()
	
	# === PINTAR MEMILIH TARGET ===
	# Kalau targetnya teman (buat Heal/Buff)
	if skill_data.target_type == 2 or skill_data.target_type == 3: # 2 = SINGLE_ALLY, 3 = ALL_ALLIES (Cek enum di skill_dat)
		buka_menu_target(active_heroes, func(target): _eksekusi_efek_skill(skill_data, target))
	else:
		# Kalau targetnya musuh (buat Damage/Debuff)
		buka_menu_target(active_enemies, func(target): _eksekusi_efek_skill(skill_data, target))
		
func _eksekusi_efek_skill(skill_data, target):
	print("\n🌟 " + current_battler.character_name + " menggunakan [" + skill_data.skill_name + "] pada " + target.character_name + "!")
	
	# Cek tipe efeknya! (0 = DAMAGE, 1 = HEAL, 2 = BUFF, 3 = DEBUFF)
	if skill_data.effect_type == 0: # DAMAGE
		var damage = skill_data.power - (target.defense / 2)
		if damage < 1: damage = 1 
		target.current_hp -= damage
		print("💥 " + target.character_name + " terkena " + str(damage) + " damage!")
		
	elif skill_data.effect_type == 1: # HEAL
		target.current_hp += skill_data.power
		# Jangan sampai nyawa melebihi batas (Overheal)
		if target.current_hp > target.max_hp:
			target.current_hp = target.max_hp
		print("💚 " + target.character_name + " di-Heal sebesar " + str(skill_data.power) + " HP!")
		
	elif skill_data.effect_type == 2: # BUFF (Contoh: Nambah Speed sementara)
		print("✨ " + target.character_name + " mendapatkan Buff!")
		# Nanti kita bisa kembangkan logika buff-nya di sini
		
	# Update bar HP di layar
	if ui_nodes.has(target):
		ui_nodes[target].update_hp()
		
	# Cek apakah musuh mati (fungsi yang sudah kamu buat sebelumnya)
	cek_kematian(target)
	
	# Akhiri giliran
	end_turn()

func _on_skill_btn_pressed():
	action_menu.hide()
	skill_menu.show()
	
	# Bersihkan tombol lama
	for child in skill_menu.get_children():
		child.queue_free()
		
	# 1. TOMBOL NORMAL SKILL
	if current_battler.normal_skill != null:
		var skill = current_battler.normal_skill
		var btn_skill = Button.new()
		btn_skill.text = skill.skill_name + " (SP: " + str(skill.sp_cost) + ")"
		btn_skill.pressed.connect(func(): _siapkan_skill(skill))
		skill_menu.add_child(btn_skill)
		
	# 2. TOMBOL ULTIMATE
	if current_battler.ultimate_skill != null:
		var ulti = current_battler.ultimate_skill
		var btn_ulti = Button.new()
		btn_ulti.text = ulti.skill_name + " (Energy: " + str(ulti.energy_cost) + ")"
		btn_ulti.pressed.connect(func(): _siapkan_skill(ulti))
		skill_menu.add_child(btn_ulti)
		
	# Tombol Kembali
	var back_btn = Button.new()
	back_btn.text = "Kembali"
	back_btn.pressed.connect(func():
		skill_menu.hide()
		action_menu.show()
	)
	skill_menu.add_child(back_btn)

# Fungsi sementara untuk mengecek apakah skill berhasil dipanggil
func _use_skill(skill_data):
	# 1. Cek apakah ini skill biasa atau Ultimate
	if skill_data.is_ultimate:
		# Pengecekan Energy untuk Ultimate
		if current_battler.current_energy < skill_data.energy_cost:
			print("🔥 Energy " + current_battler.character_name + " tidak cukup untuk Ultimate!")
			return
		
		# Kurangi Energy
		current_battler.current_energy -= skill_data.energy_cost
		print("\n🌟 " + current_battler.character_name + " mengeluarkan ULTIMATE: [" + skill_data.skill_name + "]!")
		ui_nodes[current_battler].update_energy()
		
	else:
		# Pengecekan SP Tim untuk Skill Biasa
		if team_sp < skill_data.sp_cost:
			print("🔋 SP Tim (" + str(team_sp) + ") tidak cukup untuk pakai skill!")
			return 
			
		# Kurangi SP Tim
		team_sp -= skill_data.sp_cost
		update_sp_ui()
		print("\n🌟 " + current_battler.character_name + " merapalkan [" + skill_data.skill_name + "]! (Sisa SP: " + str(team_sp) + ")")
		
		# Memakai skill juga akan mengisi sedikit Energy untuk Ultimate (dari blueprint)
		current_battler.current_energy += skill_data.energy_gained
		if current_battler.current_energy > current_battler.max_energy:
			current_battler.current_energy = current_battler.max_energy
		ui_nodes[current_battler].update_energy()
	
	skill_menu.hide()
	
	# ... (kode logika efek skill damage/heal di bawahnya tetap sama seperti sebelumnya) ...6

# Fungsi baru agar rapi (tambahkan di bagian bawah script)
func cek_kematian(target):
	if target.current_hp <= 0:
		print("💀 " + target.character_name + " MATI!")
		turn_queue.erase(target)
		if target is CharacterStats:
			active_heroes.erase(target)
		else:
			active_enemies.erase(target)
	
