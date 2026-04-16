extends Resource
class_name CharacterStats

# Info Dasar
@export var character_name: String
@export var is_mc: bool = false

# Statistik
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var max_mp: int = 50
@export var current_mp: int = 50

# Speed sangat penting buat game kamu!
@export var speed: int = 10 
@export var attack_power: int = 15
@export var defense: int = 5

# Array untuk menyimpan skill apa saja yang dimiliki karakter ini nantinya
# (Sementara kita biarkan kosong/tipe String dulu untuk placeholder)
@export var skills: Array[SkillData] = []
