extends Resource
class_name enemystat

@export var character_name: String
@export var is_mc: bool = false

@export var max_hp: int = 100
@export var current_hp: int = 100

# --- SISTEM BARU: SP & ENERGY ---

@export var max_energy: int = 100 # Batas Energy untuk Ultimate
@export var current_energy: int = 0
@export var energy_regen_rate: float = 1.0 # Pengali pengisian Energy (contoh: 1.2 = 20% lebih cepat)

@export var speed: int = 10 
@export var attack_power: int = 15
@export var defense: int = 5


@export var normal_skill: SkillDat
@export var ultimate_skill: SkillDat
