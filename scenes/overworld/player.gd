extends CharacterBody2D

const SPEED = 150
var last_direction: Vector2 = Vector2.DOWN

func _ready():
	# Set group di sini agar enemy hitbox bisa detect
	add_to_group("player")

func _physics_process(_delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("kiri"):
		direction.x -= 1   # kiri = x negatif
	if Input.is_action_pressed("kanan"):
		direction.x += 1   # kanan = x positif
	if Input.is_action_pressed("mundur"):
		direction.y += 1   # mundur = y positif (turun)
	if Input.is_action_pressed("maju"):
		direction.y -= 1   # maju = y negatif (naik)

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		last_direction = direction

	velocity = direction * SPEED
	move_and_slide()
