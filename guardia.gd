extends CharacterBody3D

@export var objetivo: Node3D
@onready var anim: AnimationPlayer = $Modelo/AnimationPlayer


func _ready() -> void:
	anim.play("idle")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	# En el Nivel 1 el enemigo mide, pero todavía no persigue.
	velocity.x = 0.0
	velocity.z = 0.0
	move_and_slide()

	if objetivo == null:
		return

	var hacia: Vector3 = objetivo.global_position - global_position
	hacia.y = 0.0

	if Engine.get_physics_frames() % 30 == 0:
		print("distancia ", snappedf(hacia.length(), 0.01))
