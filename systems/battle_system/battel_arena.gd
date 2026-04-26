extends Control

@onready var turn_order_bar   = $TurnOrderBar
@onready var action_menu      = $booton/acction
@onready var skill_menu       = $booton/SkillMenu
@onready var party_positions  = $posisi_plyr
@onready var enemy_positions  = $posisi_enmy
@onready var sp_label         = $SP
@onready var target_menu      = $booton/TargetMenu
@onready var battle_log       = $BattleLog
@onready var result_panel     = $ResultPanel
@onready var result_label     = $ResultPanel/VBox/ResultLabel

# --- SISTEM SHARED SP TIM ---
var max_team_sp: int = 5
var team_sp: int = 3

var battler_ui_scene = preload("res://systems/battle_system/BattelUi.tscn")

# Dictionary: data_stats -> UI node
var ui_nodes = {}
var current_battler = null
var turn_queue: Array = []
var active_enemies: Array = []
var active_heroes: Array = []

# =============================================================
#  SETUP
# =============================================================

func _ready():
	result_panel.hide()
	setup_battle()

func setup_battle():
	active_heroes = PartyDat.active_party.duplicate()

	# Baca musuh dari GameDat jika ada, fallback ke kroco1+2 untuk testing
	if GameDat.has_pending_encounter():
		active_enemies = GameDat.consume_encounter()
	else:
		var musuh_1 = preload("res://data/enemies/kroco1.tres")
		var musuh_2 = preload("res://data/enemies/keroco2.tres")
		active_enemies.append(musuh_1.duplicate())
		active_enemies.append(musuh_2.duplicate())

	for hero in active_heroes:
		turn_queue.append(hero)
		spawn_ui(hero, true)
	for enemy in active_enemies:
		turn_queue.append(enemy)
		spawn_ui(enemy, false)

	sort_turn_queue()
	update_sp_ui()

func spawn_ui(battler_stats, is_hero: bool):
	var ui_instance = battler_ui_scene.instantiate()
	ui_nodes[battler_stats] = ui_instance
	if is_hero:
		party_positions.add_child(ui_instance)
	else:
		enemy_positions.add_child(ui_instance)
	ui_instance.setup(battler_stats)

# =============================================================
#  UI HELPERS
# =============================================================

func tambah_log(teks: String):
	battle_log.append_text("\n" + teks)

func update_sp_ui():
	sp_label.text = "SP: " + str(team_sp) + "/" + str(max_team_sp)

func update_turn_bar():
	for child in turn_order_bar.get_children():
		child.queue_free()
	if turn_queue.size() == 0:
		return
	for i in range(7):
		var battler = turn_queue[i % turn_queue.size()]
		var icon = TextureRect.new()
		icon.texture = battler.sprite_texture
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(50, 50)
		if battler is enemystat:
			icon.modulate = Color(1, 0.4, 0.4)
		turn_order_bar.add_child(icon)

# =============================================================
#  TURN SYSTEM
# =============================================================

func sort_turn_queue():
	turn_queue.sort_custom(func(a, b): return a.speed > b.speed)
	update_turn_bar()
	start_turn()

func start_turn():
	current_battler = turn_queue[0]
	tambah_log("[color=yellow]>>> Giliran " + current_battler.character_name + " <<<[/color]")

	# Proses status effect (loop dari belakang agar aman saat item dihapus)
	for i in range(current_battler.active_statuses.size() - 1, -1, -1):
		var status = current_battler.active_statuses[i]

		if status.stat == 1: # HP_DOT
			current_battler.current_hp -= status.jumlah
			tambah_log("  [color=orange]☠ " + current_battler.character_name + " -" + str(status.jumlah) + " HP dari [" + status.nama + "][/color]")
		elif status.stat == 2: # HP_REGEN
			current_battler.current_hp += status.jumlah
			if current_battler.current_hp > current_battler.max_hp:
				current_battler.current_hp = current_battler.max_hp
			tambah_log("  [color=green]+ " + current_battler.character_name + " +" + str(status.jumlah) + " HP dari [" + status.nama + "][/color]")

		if ui_nodes.has(current_battler):
			ui_nodes[current_battler].update_hp()

		cek_kematian(current_battler)
		if current_battler.current_hp <= 0:
			# Battler sudah diremove dari turn_queue oleh cek_kematian.
			# Jangan panggil end_turn() biasa karena itu akan pop_front battler yg sudah tidak ada.
			await get_tree().create_timer(0.5).timeout
			if active_heroes.size() == 0:
				_tampil_hasil(false)
			elif active_enemies.size() == 0:
				_tampil_hasil(true)
			else:
				update_turn_bar()
				start_turn()
			return

		status.durasi -= 1
		if status.durasi <= 0:
			tambah_log("  Efek [" + status.nama + "] pada " + current_battler.character_name + " habis")
			if status.stat == 3: current_battler.attack_power -= status.jumlah
			elif status.stat == 4: current_battler.speed -= status.jumlah
			elif status.stat == 5: current_battler.defense -= status.jumlah
			current_battler.active_statuses.remove_at(i)

	if current_battler is CharacterStats:
		action_menu.show()
	else:
		action_menu.hide()
		enemy_turn()

func end_turn():
	if active_heroes.size() == 0:
		_tampil_hasil(false)
		return
	elif active_enemies.size() == 0:
		_tampil_hasil(true)
		return

	var selesai = turn_queue.pop_front()
	turn_queue.push_back(selesai)

	await get_tree().create_timer(1.0).timeout
	update_turn_bar()
	start_turn()

# =============================================================
#  HASIL BATTLE
# =============================================================

func _tampil_hasil(menang: bool):
	action_menu.hide()
	skill_menu.hide()
	target_menu.hide()
	if menang:
		result_label.text = "VICTORY!"
		tambah_log("[color=green]Semua musuh telah dikalahkan![/color]")
		# Setelah menang: restore HP semua hero ke kondisi sebelum battle
		_restore_party_hp()
	else:
		result_label.text = "GAME OVER"
		tambah_log("[color=red]Party telah hancur...[/color]")
		# Setelah kalah: reset HP ke max (respawn)
		_restore_party_hp(true)
	result_panel.show()

func _restore_party_hp(full_reset: bool = false):
	for hero in PartyDat.active_party:
		if full_reset:
			hero.current_hp = hero.max_hp
			hero.current_energy = 0
		else:
			# Victory: pulihkan sebagian HP (30% dari max) agar ada konsekuensi
			var heal = int(hero.max_hp * 0.3)
			hero.current_hp = min(hero.current_hp + heal, hero.max_hp)
		hero.active_statuses.clear()

func _on_result_button_pressed():
	if GameDat.return_scene != "":
		get_tree().change_scene_to_file(GameDat.return_scene)
	else:
		get_tree().reload_current_scene()

# =============================================================
#  ENEMY AI
# =============================================================

func enemy_turn():
	await get_tree().create_timer(1.0).timeout
	if active_heroes.size() > 0:
		var target = active_heroes.pick_random()
		perform_attack(current_battler, target)

# =============================================================
#  BASIC ATTACK
# =============================================================

func _on_basic_atk_pressed() -> void:
	action_menu.hide()
	if active_enemies.size() > 0:
		buka_menu_target(active_enemies, _eksekusi_basic_attack)

func _eksekusi_basic_attack(target):
	if team_sp < max_team_sp:
		team_sp += 1
	update_sp_ui()

	current_battler.current_energy += 20
	if current_battler.current_energy > current_battler.max_energy:
		current_battler.current_energy = current_battler.max_energy
	if ui_nodes.has(current_battler):
		ui_nodes[current_battler].update_energy()

	perform_attack(current_battler, target)

func _animasi_serang_fisik(node_penyerang: Control, node_target: Control):
	var posisi_awal   = node_penyerang.global_position
	var posisi_target = node_target.global_position
	var arah          = 1 if posisi_awal.x < posisi_target.x else -1
	var titik_pukul   = posisi_target + Vector2(80 * -arah, 0)
	var tween         = get_tree().create_tween()
	tween.tween_property(node_penyerang, "global_position", titik_pukul, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node_penyerang, "global_position", posisi_awal, 0.3).set_delay(0.2).set_trans(Tween.TRANS_SINE)
	await tween.finished

func perform_attack(attacker, target):
	await _animasi_serang_fisik(ui_nodes[attacker], ui_nodes[target])

	var damage = attacker.attack_power - (target.defense / 2)
	if damage < 1: damage = 1
	target.current_hp -= damage

	if ui_nodes.has(target):
		ui_nodes[target].update_hp()

	tambah_log("⚔ " + attacker.character_name + " -> " + target.character_name
		+ "  [" + str(damage) + " dmg]  HP: "
		+ str(target.current_hp) + "/" + str(target.max_hp))

	cek_kematian(target)
	end_turn()

# =============================================================
#  SKILL SYSTEM
# =============================================================

func _on_skill_pressed():
	action_menu.hide()
	skill_menu.show()

	for child in skill_menu.get_children():
		child.queue_free()

	if current_battler.normal_skill != null:
		var skill = current_battler.normal_skill
		var btn = Button.new()
		btn.text = skill.skill_name + "  (SP: " + str(skill.sp_cost) + ")"
		btn.pressed.connect(func(): _siapkan_skill(skill))
		skill_menu.add_child(btn)

	if current_battler.ultimate_skill != null:
		var ulti = current_battler.ultimate_skill
		var btn = Button.new()
		btn.text = ulti.skill_name + "  (Energy: " + str(ulti.energy_cost) + ")"
		btn.pressed.connect(func(): _siapkan_skill(ulti))
		skill_menu.add_child(btn)

	var back = Button.new()
	back.text = "<- Kembali"
	back.pressed.connect(func():
		skill_menu.hide()
		action_menu.show()
	)
	skill_menu.add_child(back)

func _siapkan_skill(skill_data: SkillDat):
	# Cek & bayar biaya — kalau gagal, skill menu tetap terbuka
	if skill_data.is_ultimate:
		if current_battler.current_energy < skill_data.energy_cost:
			tambah_log("[color=red]Energy " + current_battler.character_name + " tidak cukup![/color]")
			return
		current_battler.current_energy -= skill_data.energy_cost
	else:
		if team_sp < skill_data.sp_cost:
			tambah_log("[color=red]SP Tim tidak cukup! (butuh " + str(skill_data.sp_cost) + ")[/color]")
			return
		team_sp -= skill_data.sp_cost
		current_battler.current_energy += skill_data.energy_gained
		if current_battler.current_energy > current_battler.max_energy:
			current_battler.current_energy = current_battler.max_energy

	update_sp_ui()
	if ui_nodes.has(current_battler):
		ui_nodes[current_battler].update_energy()
	skill_menu.hide()

	# Routing target berdasarkan enum (bukan angka magic)
	match skill_data.target_type:
		SkillDat.TargetType.SINGLE_ENEMY:
			buka_menu_target(active_enemies, func(t): _eksekusi_efek_skill(skill_data, t))
		SkillDat.TargetType.ALL_ENEMIES:
			_eksekusi_skill_aoe(skill_data, active_enemies)
		SkillDat.TargetType.SINGLE_ALLY:
			buka_menu_target(active_heroes, func(t): _eksekusi_efek_skill(skill_data, t))
		SkillDat.TargetType.ALL_ALLIES:
			_eksekusi_skill_aoe(skill_data, active_heroes)
		SkillDat.TargetType.SELF:
			_eksekusi_efek_skill(skill_data, current_battler)

# Single target: terapkan efek lalu end_turn
func _eksekusi_efek_skill(skill_data: SkillDat, target):
	tambah_log("★ " + current_battler.character_name
		+ " -> [" + skill_data.skill_name + "] -> " + target.character_name)
	_terapkan_efek(skill_data, target)
	end_turn()

# AOE: loop semua target, end_turn hanya sekali
func _eksekusi_skill_aoe(skill_data: SkillDat, daftar_target: Array):
	tambah_log("★ " + current_battler.character_name
		+ " -> [" + skill_data.skill_name + "] -> SEMUA!")
	for target in daftar_target.duplicate(): # duplicate() agar aman kalau ada yg mati di loop
		_terapkan_efek(skill_data, target)
	end_turn()

# Logika efek murni — TIDAK memanggil end_turn
func _terapkan_efek(skill_data: SkillDat, target):
	match skill_data.effect_type:
		SkillDat.SkillEffect.DAMAGE:
			var damage = skill_data.power - (target.defense / 2)
			if damage < 1: damage = 1
			target.current_hp -= damage
			tambah_log("  [color=red]-" + str(damage) + " HP[/color] pada " + target.character_name)
			if ui_nodes.has(target):
				ui_nodes[target].update_hp()
			cek_kematian(target)

		SkillDat.SkillEffect.HEAL:
			target.current_hp += skill_data.power
			if target.current_hp > target.max_hp:
				target.current_hp = target.max_hp
			tambah_log("  [color=green]+" + str(skill_data.power) + " HP[/color] pada " + target.character_name)
			if ui_nodes.has(target):
				ui_nodes[target].update_hp()

		SkillDat.SkillEffect.BUFF, SkillDat.SkillEffect.DEBUFF:
			var jumlah = skill_data.effect_amount if skill_data.effect_type == SkillDat.SkillEffect.BUFF \
						else -skill_data.effect_amount
			var status = {
				"nama":   skill_data.skill_name,
				"stat":   skill_data.stat_affected,
				"jumlah": jumlah,
				"durasi": skill_data.effect_duration
			}
			target.active_statuses.append(status)
			tambah_log("  Efek [" + skill_data.skill_name + "] pada "
				+ target.character_name + " (" + str(skill_data.effect_duration) + " giliran)")
			if status.stat == 3: target.attack_power += jumlah
			elif status.stat == 4: target.speed += jumlah
			elif status.stat == 5: target.defense += jumlah

# =============================================================
#  TARGET MENU
# =============================================================

func buka_menu_target(daftar_target: Array, fungsi_eksekusi: Callable):
	target_menu.show()
	for child in target_menu.get_children():
		child.queue_free()

	for target in daftar_target:
		var btn = Button.new()
		btn.text = target.character_name + "  HP: " + str(target.current_hp) + "/" + str(target.max_hp)
		btn.pressed.connect(func():
			target_menu.hide()
			fungsi_eksekusi.call(target)
		)
		target_menu.add_child(btn)

	var back = Button.new()
	back.text = "<- Kembali"
	back.pressed.connect(func():
		target_menu.hide()
		action_menu.show()
	)
	target_menu.add_child(back)

# =============================================================
#  CEK KEMATIAN
# =============================================================

func cek_kematian(target):
	if target.current_hp > 0:
		return

	target.current_hp = 0
	tambah_log("[color=red]✖ " + target.character_name + " gugur![/color]")

	turn_queue.erase(target)
	if target is CharacterStats:
		active_heroes.erase(target)
	else:
		active_enemies.erase(target)

	# Hapus UI node dari layar
	if ui_nodes.has(target):
		ui_nodes[target].queue_free()
		ui_nodes.erase(target)

	update_turn_bar()
