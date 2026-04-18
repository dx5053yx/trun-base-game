extends Node

# Dictionary untuk menyimpan item dan jumlahnya. 
# Format: { ItemData : Jumlah(int) }
var isi_tas: Dictionary = {}

func _ready():
	# Beri modal awal untuk ngetes battle nanti
	var potion_awal = preload("res://data/items/potion.tres")
	var ether_awal = preload("res://data/items/ether.tres")
	
	tambah_item(potion_awal, 5) # Dikasih modal 5 Potion
	tambah_item(ether_awal, 2)  # Dikasih modal 2 Ether

func tambah_item(item: ItemData, jumlah: int):
	if isi_tas.has(item):
		isi_tas[item] += jumlah
	else:
		isi_tas[item] = jumlah
	print("Mendapatkan " + str(jumlah) + "x " + item.item_name)

func kurangi_item(item: ItemData, jumlah: int = 1) -> bool:
	if isi_tas.has(item) and isi_tas[item] >= jumlah:
		isi_tas[item] -= jumlah
		if isi_tas[item] <= 0:
			isi_tas.erase(item) # Buang dari tas kalau habis
		return true
	return false
