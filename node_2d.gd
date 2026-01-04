extends Node2D

# ini buat definisin giliran
enum TrunState {player,mob, win, los}
var giliran = TrunState

# data hp/ stat plaayer sama mob
var hp_plyer = 100
var hp_mob = 70

#buat reefern UI
@onready var keterngan = $UI/Panel/keterngaan
@onready var serang = $UI/bar

func _ready() -> void:
	#updat ui kaali mulaai game nyaa
	update_ui_text("kalah = skill isu")
	# nunggu biar ga nimpa nimpaa ui nya
	await get_tree().create_timer(1.5).timeout
	start_player_trun()
	
# algoritma player
func start_player_trun() -> void:
	giliran = TrunState.player
	update_ui_text("serang yuk")
	serang.visible = true
	
# ngirim sinyaal kalo neken tomboll serang
func _on_attack_button_pressed() -> void :
	if giliran != TrunState.player :return
	
	serang.visible = false # biar gak ganggu ui (ngumpetin)
	
	#algoritma serang 
	var damage = 10
	hp_mob -=damage
	update_ui_text("keruskaan" + str(damage) + "dameng")
	$mob.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$mob.modulate = Color.WHITE
	
	await get_tree().create_timer(1.5).timeout # biaar gk nimmpa
	
	# cek musuh mati
	if hp_mob <= 0:
		win_battle()
	else:
		giliran_mob()
		
		
# algor mob
func giliran_mob():
	giliran = TrunState.mob
	update_ui_text("giliran musuh!!💀")
	await get_tree().create_timer(1.5).timeout
	
	# Ai mob
	var damaage = 7
	hp_plyer -= damaage
	update_ui_text("keruskaan" + str(damage) + "dameng")
	$char.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$char.modulate = Color.WHITE
	
	await get_tree().create_timer(1.5).timeout # biaar gk nimmpa
	if hp_plyer <= 0:
		los_battel()
	else:
		giliran_player()
# End game
func win_battel():
	giliran = TrunState.win
	update_iu_text("boleh-boleh")
func los_battel():
	giliran + TrunState.los
	update_ui_text("skill isu!!")
	
func update_ui_text(text_baru: String):
	keterngan.text = text_baru
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
