extends Node2D

# ini buat definisin giliran
enum TrunState {player,mob, win, los}
var giliran = TrunState.player
@onready var char_node = $char
@onready var mob_node = $mob
# data hp/ stat plaayer sama mob
var hp_plyer = 100
var hp_mob = 70
var max_hp_plyer = 100

@onready var hp_bar_char = $UI/hp_char
@onready var hp_bar_mob = $UI/hp_mob
#buat reefern UI
@onready var keterngan = $UI/Panel/keterngaan
@onready var serang = $UI/bar

func _ready() -> void:
	atur_posisi()
	# set HP bar
	hp_bar_char.max_value = hp_plyer
	hp_bar_mob.max_value = hp_mob
	hp_bar_char.value = hp_plyer
	hp_bar_mob.value = hp_mob
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
func _on_serang_pressed() -> void:
	if giliran != TrunState.player :return
	serang.visible = false # biar gak ganggu ui (ngumpetin)
	
	#algoritma serang 
	var damage = 10
	char_node.position = Vector2(mob_node.position.x - 150,mob_node.position.y)
	hp_mob -=damage
	hp_bar_mob.value = hp_mob
	update_ui_text("keruskaan" + str(damage) + "dameng")
	$mob.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$mob.modulate = Color.WHITE
	await get_tree().create_timer(1.5).timeout # biaar gk nimmpa
	atur_posisi()
	
	
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
	var damaage = 10
	mob_node.position = Vector2(char_node.position.x + 150, char_node.position.y)
	hp_plyer -= damaage
	hp_bar_char.value = hp_plyer
	update_ui_text("keruskaan" + str(damaage) + "dameng")
	$char.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$char.modulate = Color.WHITE
	await get_tree().create_timer(1.5).timeout # biaar gk nimmpa
	atur_posisi()
	
	if hp_plyer <= 0:
		los_battel()
	else:
		start_player_trun()
# End game
func win_battle():
	giliran = TrunState.win
	update_ui_text("boleh-boleh")
func los_battel():
	giliran = TrunState.los
	update_ui_text("skill isu!!")
	
func update_ui_text(text_baru: String):
	keterngan.text = text_baru
	
func atur_posisi():
	char_node.position = Vector2(200,400)
	mob_node.position = Vector2(900,400)
	hp_bar_char.position = Vector2(char_node.position.x -50, char_node.position.y - 150)
	hp_bar_mob.position = Vector2(mob_node.position.x -50, mob_node.position.y - 150)
	keterngan.position = Vector2(500,50)
	serang.position = Vector2(200,550)

func heal() -> void:
	if hp_plyer <= 100:
		update_ui_text("udah penuh jirr")
		_on_serang_pressed()
	serang.visible = false # biar gak ganggu ui (ngumpetin)
	
	var hieal = 10 
	hp_plyer += hieal
	hp_bar_char.value = hp_plyer
	update_ui_text("memulihkan " + str(hieal) + " HP")
	$char.modulate = Color.GREEN
	await get_tree().create_timer(0.2).timeout
	$char.modulate = Color.WHITE
	await get_tree().create_timer(1.5).timeout # biaar gk nimmpa
	
	# cek musuh mati
	if hp_mob <= 0:
		win_battle()
	else:
		giliran_mob()
