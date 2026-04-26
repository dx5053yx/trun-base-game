extends StaticBody2D

# Assign di Inspector
@export var dialogue: DialogueDat
@export var npc_name: String = "NPC"

# Indikator "!" muncul saat player dekat
@onready var indicator = $Indicator
var player_nearby: bool = false

func _ready():
	indicator.hide()

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("konfirmasi"):
		_mulai_dialog()

func _mulai_dialog():
	if dialogue == null:
		return
	# Hindari trigger ganda saat dialog sedang jalan
	if not get_tree().paused:
		DialogueBox.mulai(dialogue)

func _on_area_body_entered(body: Node):
	if body.is_in_group("player"):
		player_nearby = true
		indicator.show()

func _on_area_body_exited(body: Node):
	if body.is_in_group("player"):
		player_nearby = false
		indicator.hide()
