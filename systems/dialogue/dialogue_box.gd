extends CanvasLayer

# =============================================================
#  DialogueBox — Autoload
#  Cara pakai:
#    DialogueBox.mulai(dialogue_dat_resource)
#  Sinyal:
#    selesai — dipancarkan ketika semua dialog habis
# =============================================================

signal selesai

@onready var panel        = $Panel
@onready var speaker_label= $Panel/VBox/Speaker
@onready var text_label   = $Panel/VBox/Text
@onready var lanjut_hint  = $Panel/VBox/LanjutHint

var _lines: Array = []
var _index: int = 0
var _sedang_ketik: bool = false
var _teks_penuh: String = ""

# Kecepatan ketik (karakter per detik)
const KETIK_SPEED = 40.0

func _ready():
	panel.hide()
	set_process_input(false)

# Mulai dialog dari DialogueDat resource
func mulai(dat: DialogueDat):
	if dat == null or dat.lines.is_empty():
		return
	_lines = dat.lines.duplicate()
	_index = 0
	panel.show()
	set_process_input(true)
	# Pause overworld/game sementara dialog berjalan
	get_tree().paused = true
	_tampil_baris()

func _tampil_baris():
	if _index >= _lines.size():
		_selesai()
		return
	var baris = _lines[_index]
	speaker_label.text = baris.get("speaker", "")
	_teks_penuh = baris.get("text", "")
	text_label.text = ""
	lanjut_hint.hide()
	_sedang_ketik = true
	_ketik_teks()

func _ketik_teks():
	# Animasi teks muncul karakter per karakter
	var i = 0
	while i <= _teks_penuh.length():
		text_label.text = _teks_penuh.left(i)
		i += 1
		await get_tree().create_timer(1.0 / KETIK_SPEED).timeout
		if not _sedang_ketik:
			# Pemain skip → langsung tampil semua
			text_label.text = _teks_penuh
			break
	_sedang_ketik = false
	lanjut_hint.show()

func _input(event):
	if not panel.visible:
		return
	if event.is_action_pressed("konfirmasi") or event.is_action_pressed("ui_accept"):
		if _sedang_ketik:
			# Skip animasi, langsung tampil semua
			_sedang_ketik = false
		else:
			_index += 1
			_tampil_baris()
		get_viewport().set_input_as_handled()

func _selesai():
	panel.hide()
	set_process_input(false)
	get_tree().paused = false
	emit_signal("selesai")
