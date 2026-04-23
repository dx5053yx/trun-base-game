extends Node

# Format: { ItemData : jumlah(int) }
var isi_tas: Dictionary = {}

func _ready():
	pass

func tambah_item(item: ItemData, jumlah: int):
	if isi_tas.has(item):
		isi_tas[item] += jumlah
	else:
		isi_tas[item] = jumlah

func kurangi_item(item: ItemData, jumlah: int = 1) -> bool:
	if isi_tas.has(item) and isi_tas[item] >= jumlah:
		isi_tas[item] -= jumlah
		if isi_tas[item] <= 0:
			isi_tas.erase(item)
		return true
	return false
