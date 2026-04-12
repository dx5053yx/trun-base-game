extends Resource
class_name SkillData

# Membuat opsi Dropdown 
enum TargetType { SINGLE_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF }
enum SkillEffect { DAMAGE, HEAL, BUFF, DEBUFF }

@export var skill_name: String = "Nama Skill"
@export_multiline var description: String = "Deskripsi efek skill."

@export var effect_type: SkillEffect = SkillEffect.DAMAGE
@export var target_type: TargetType = TargetType.SINGLE_ENEMY

# jumlah Damage, atau jumlah HP yang di-heal
@export var power: int = 15 
@export var mp_cost: int = 5

# Khusus untuk Buff
@export var buff_amount: int = 0
@export var buff_duration: int = 0 # Bertahan berapa giliran (turn)
