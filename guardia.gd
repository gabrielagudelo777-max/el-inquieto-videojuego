extends CharacterBody3D

@export var objetivo: Node3D
@export var rapidez: float = 2.0
@export var distancia_detener: float = 1.0
@onready var anim: AnimationPlayer = $Modelo/AnimationPlayer


func _ready() -> void:
	_reproducir("idle")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	if objetivo == null:
		velocity.x = 0.0
		velocity.z = 0.0
		_reproducir("idle")
		move_and_slide()
		return

	var hacia: Vector3 = objetivo.global_position - global_position
	hacia.y = 0.0
	var distancia: float = hacia.length()

	if distancia > distancia_detener:
		var dir: Vector3 = hacia.normalized()
		velocity.x = dir.x * rapidez
		velocity.z = dir.z * rapidez
		basis = Basis.looking_at(dir)
		_reproducir("walk")
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		_reproducir("idle")

	move_and_slide()

	if Engine.get_physics_frames() % 30 == 0:
		print("distancia ", snappedf(distancia, 0.01))


func _reproducir(nombre: String) -> void:
	if anim.current_animation != nombre:
		anim.play(nombre)
