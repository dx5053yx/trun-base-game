extends Node2D

@onready var pause_panel = $PausePanel
@onready var hp_party_label = $HUD/PartyHP

func _ready():
	get_tree().paused = false
	pause_panel.hide()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause()
	_update_hud()

func _toggle_pause():
	var paused = !pause_panel.visible
	pause_panel.visible = paused
	get_tree().paused = paused

func _update_hud():
	if hp_party_label == null:
		return
	var teks = ""
	for c in PartyDat.active_party:
		teks += c.character_name + ": " + str(c.current_hp) + "/" + str(c.max_hp) + "  "
	hp_party_label.text = teks

func _on_btn_save_pressed():
	SaveDat.simpan()
	$PausePanel/VBox/SaveInfo.text = "✔ Game disimpan!"

func _on_btn_resume_pressed():
	_toggle_pause()

func _on_btn_main_menu_pressed():
	get_tree().paused = false
	SceneTransition.go_to("res://scenes/main_menu/main_menu.tscn")
