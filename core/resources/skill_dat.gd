extends Resource
class_name SkillDat
# --- SISTEM BUFF / DEBUFF ---
# 0: Tidak Ada, 1: Racun/Burn, 2: Regen Darah, 3: Attack, 4: Speed, 5: Defense
enum StatAffected { NONE, HP_DOT, HP_REGEN, ATTACK, SPEED, DEFENSE }

@export var stat_affected: StatAffected = StatAffected.NONE
@export var effect_amount: int = 0   # Jumlah stat yang ditambah/dikurangi/damage racun
@export var effect_duration: int = 0 # Bertahan berapa giliran?
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
