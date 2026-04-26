extends Control

@onready var btn_new_game  = $Center/VBox/BtnNewGame
@onready var btn_continue  = $Center/VBox/BtnContinue
@onready var btn_quit      = $Center/VBox/BtnQuit

func _ready():
	get_tree().paused = false
	btn_continue.visible = SaveDat.ada_save()

func _on_btn_new_game_pressed():
	SaveDat.hapus_save()
	PartyDat.active_party.clear()
	var mc = PartyDat.get_mc()
	if mc:
		mc.current_hp = mc.max_hp
		mc.current_energy = 0
		PartyDat.active_party.append(mc)
	SceneTransition.go_to("res://scenes/party_setup/party_setup.tscn")

func _on_btn_continue_pressed():
	if SaveDat.muat():
		SceneTransition.go_to("res://scenes/overworld/overworld.tscn")
	else:
		btn_continue.visible = false

func _on_btn_quit_pressed():
	get_tree().quit()
