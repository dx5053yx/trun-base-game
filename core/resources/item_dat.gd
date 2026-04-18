extends Resource
class_name ItemData

enum ItemType { HEAL_HP, HEAL_SP, REVIVE, BUFF }
enum TargetType { SINGLE_ALLY, ALL_ALLIES }

# --- BATASAN PENGGUNAAN ---
enum Usability { OVERWORLD_ONLY, BATTLE_ONLY, ANYWHERE }
@export var usability: Usability = Usability.ANYWHERE

@export var item_name: String = "Nama Item"
@export var type: ItemType = ItemType.HEAL_HP
@export var target: TargetType = TargetType.SINGLE_ALLY
@export var amount: int = 50
