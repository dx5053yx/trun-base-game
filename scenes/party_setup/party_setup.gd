extends Control

# =============================================================
#  PARTY SETUP SCENE
#  Pemain memilih 4 karakter dari roster sebelum masuk overworld.
#  MC selalu ada di slot 0 dan tidak bisa diubah.
# =============================================================

@onready var slot_container   = $Main/Top/Left/SlotContainer
@onready var roster_container = $Main/Top/Right/ScrollContainer/RosterContainer
@onready var start_button     = $Main/Bottom/StartButton
@onready var info_label       = $Main/Bottom/InfoLabel

# Slot yang sedang dipilih untuk diganti (-1 = tidak ada)
var selected_slot: int = -1

# Warna state
const COLOR_SLOT_NORMAL   = Color(0.2, 0.2, 0.3)
const COLOR_SLOT_SELECTED = Color(0.3, 0.5, 0.8)
const COLOR_SLOT_MC       = Color(0.5, 0.3, 0.1)
const COLOR_SLOT_EMPTY    = Color(0.15, 0.15, 0.15)

func _ready():
	refresh_ui()

# =============================================================
#  REFRESH SELURUH UI
# =============================================================

func refresh_ui():
	_refresh_slots()
	_refresh_roster()
	_update_start_button()
	selected_slot = -1

func _refresh_slots():
	for child in slot_container.get_children():
		child.queue_free()

	for i in range(PartyDat.MAX_PARTY_SIZE):
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(160, 180)

		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		var slot_label = Label.new()
		slot_label.text = "Slot " + str(i + 1)
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		var sprite = TextureRect.new()
		sprite.custom_minimum_size = Vector2(64, 64)
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		var name_label = Label.new()
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		var stats_label = Label.new()
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_label.add_theme_font_size_override("font_size", 10)

		var remove_btn = Button.new()
		remove_btn.text = "Keluarkan"
		remove_btn.visible = false

		if i < PartyDat.active_party.size():
			var char_data = PartyDat.active_party[i]
			name_label.text = char_data.character_name.capitalize()
			stats_label.text = "HP:%d  ATK:%d\nSPD:%d  DEF:%d" % [
				char_data.max_hp, char_data.attack_power,
				char_data.speed, char_data.defense
			]
			if char_data.sprite_texture:
				sprite.texture = char_data.sprite_texture

			if char_data.is_mc:
				slot_label.text = "Slot 1 (MC)"
				_set_panel_color(panel, COLOR_SLOT_MC)
			else:
				_set_panel_color(panel, COLOR_SLOT_NORMAL)
				remove_btn.visible = true
				var idx = i
				remove_btn.pressed.connect(func():
					PartyDat.remove_from_active_party(PartyDat.active_party[idx])
					refresh_ui()
				)

			# Klik slot untuk memilihnya (ganti karakter)
			if not char_data.is_mc:
				var btn_select = Button.new()
				btn_select.text = "Ganti"
				var idx = i
				btn_select.pressed.connect(func(): _pilih_slot(idx))
				vbox.add_child(slot_label)
				vbox.add_child(sprite)
				vbox.add_child(name_label)
				vbox.add_child(stats_label)
				vbox.add_child(btn_select)
				vbox.add_child(remove_btn)
			else:
				vbox.add_child(slot_label)
				vbox.add_child(sprite)
				vbox.add_child(name_label)
				vbox.add_child(stats_label)
		else:
			# Slot kosong
			name_label.text = "[ Kosong ]"
			stats_label.text = "Klik untuk\nisi slot"
			_set_panel_color(panel, COLOR_SLOT_EMPTY)
			var idx = i
			var btn_isi = Button.new()
			btn_isi.text = "Isi Slot"
			btn_isi.pressed.connect(func(): _pilih_slot(idx))
			vbox.add_child(slot_label)
			vbox.add_child(sprite)
			vbox.add_child(name_label)
			vbox.add_child(stats_label)
			vbox.add_child(btn_isi)

		panel.add_child(vbox)
		slot_container.add_child(panel)

	# Highlight slot yang sedang dipilih
	if selected_slot >= 0 and selected_slot < slot_container.get_child_count():
		_set_panel_color(slot_container.get_child(selected_slot), COLOR_SLOT_SELECTED)

func _refresh_roster():
	for child in roster_container.get_children():
		child.queue_free()

	var tersedia = PartyDat.get_roster_not_in_party()

	if tersedia.is_empty():
		var lbl = Label.new()
		lbl.text = "Semua karakter\nsudah di party"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		roster_container.add_child(lbl)
		return

	for char_data in tersedia:
		var row = HBoxContainer.new()

		var sprite = TextureRect.new()
		sprite.custom_minimum_size = Vector2(40, 40)
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if char_data.sprite_texture:
			sprite.texture = char_data.sprite_texture

		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_lbl = Label.new()
		name_lbl.text = char_data.character_name.capitalize()

		var stat_lbl = Label.new()
		stat_lbl.add_theme_font_size_override("font_size", 10)
		stat_lbl.text = "HP:%d  ATK:%d  SPD:%d  DEF:%d" % [
			char_data.max_hp, char_data.attack_power,
			char_data.speed, char_data.defense
		]

		vbox.add_child(name_lbl)
		vbox.add_child(stat_lbl)

		var btn = Button.new()
		btn.text = "Pilih"
		btn.custom_minimum_size = Vector2(60, 0)
		var c = char_data
		btn.pressed.connect(func(): _pilih_dari_roster(c))

		# Disable kalau tidak ada slot yang dipilih
		btn.disabled = (selected_slot == -1)

		row.add_child(sprite)
		row.add_child(vbox)
		row.add_child(btn)

		roster_container.add_child(row)

		# Separator tipis
		var sep = HSeparator.new()
		roster_container.add_child(sep)

func _update_start_button():
	var jumlah = PartyDat.active_party.size()
	if jumlah >= 1:
		start_button.disabled = false
		start_button.text = "Mulai Petualangan! (%d/4)" % jumlah
	else:
		start_button.disabled = true
		start_button.text = "Party kosong!"

# =============================================================
#  INTERAKSI
# =============================================================

func _set_panel_color(panel: PanelContainer, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", style)

func _pilih_slot(slot_idx: int):
	selected_slot = slot_idx
	info_label.text = "Pilih karakter dari daftar kanan untuk mengisi Slot %d" % (slot_idx + 1)
	# Re-render roster supaya tombol Pilih jadi aktif
	_refresh_slots()
	_refresh_roster()

func _pilih_dari_roster(char_data: CharacterStats):
	if selected_slot == -1:
		info_label.text = "Pilih slot dulu!"
		return

	# Kalau slot itu sudah ada isinya → swap
	if selected_slot < PartyDat.active_party.size():
		PartyDat.swap_party_member(selected_slot, char_data)
	else:
		# Slot kosong → tambahkan saja
		PartyDat.active_party.insert(selected_slot, char_data)

	info_label.text = char_data.character_name.capitalize() + " masuk ke Slot " + str(selected_slot + 1)
	selected_slot = -1
	refresh_ui()

func _on_start_button_pressed():
	SceneTransition.go_to("res://scenes/overworld/overworld.tscn")
