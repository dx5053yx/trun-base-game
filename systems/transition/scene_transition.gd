extends CanvasLayer

#  SceneTransition — Autoload
#  Cara pakai: SceneTransition.go_to("res://path/ke/scene.tscn")

@onready var overlay = $Overlay
@onready var anim    = $AnimationPlayer

var _target_scene: String = ""

func _ready():
	overlay.modulate.a = 0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func go_to(scene_path: String):
	if _target_scene != "":
		return  # Sedang dalam transisi, abaikan panggilan ganda
	_target_scene = scene_path
	anim.play("fade_out")

func _on_fade_out_finished():
	get_tree().change_scene_to_file(_target_scene)
	_target_scene = ""
	# Tunggu 1 frame agar scene baru selesai load, lalu fade in
	await get_tree().process_frame
	anim.play("fade_in")

func _on_animation_finished(anim_name: StringName):
	if anim_name == "fade_out":
		_on_fade_out_finished()
	elif anim_name == "fade_in":
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
