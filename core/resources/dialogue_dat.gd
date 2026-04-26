extends Resource
class_name DialogueDat

# Satu entri dialog = satu balon ucapan
class DialogueLine:
	var speaker: String  # Nama karakter yang ngomong
	var text: String     # Isi dialog
	var portrait: Texture2D  # Foto/sprite karakter (boleh null)

	func _init(s: String, t: String, p: Texture2D = null):
		speaker = s
		text = t
		portrait = p

# Semua baris dialog dalam satu percakapan
@export var lines: Array[Dictionary] = []
# Format tiap Dictionary: { "speaker": String, "text": String }

# Helper: tambah baris baru lewat kode
func tambah(speaker: String, text: String):
	lines.append({"speaker": speaker, "text": text})
