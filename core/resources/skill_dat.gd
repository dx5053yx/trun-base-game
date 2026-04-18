extends Resource
class_name SkillDat

enum TargetType { SINGLE_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF }
enum SkillEffect { DAMAGE, HEAL, BUFF, DEBUFF }

@export var skill_name: String = "Nama Skill"
@export_multiline var description: String = "Deskripsi skill."

@export var effect_type: SkillEffect = SkillEffect.DAMAGE
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
@export var power: int = 15 

# --- SISTEM BIAYA BARU ---
@export var is_ultimate: bool = false # Centang ini di Inspector jika ini skill Ultimate
@export var sp_cost: int = 1          # Biaya SP jika ini skill biasa
@export var energy_cost: int = 100    # Biaya Energy jika ini Ultimate

# Berapa energi yang didapat karakter saat memakai skill ini?
@export var energy_gained: int = 30
