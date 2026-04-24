extends CharacterBody2D

const SPEED = 150

# Arah terakhir yang dihadapi — untuk sprite facing nanti
var last_direction: Vector2 = Vector2.DOWN

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("kiri"):
		direction.x += 1
	if Input.is_action_pressed("kanan"):
		direction.x -= 1
	if Input.is_action_pressed("mundur"):
		direction.y += 1
	if Input.is_action_pressed("maju"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		last_direction = direction

	velocity = direction * SPEED
	move_and_slide()
