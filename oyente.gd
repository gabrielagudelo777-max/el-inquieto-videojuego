extends CharacterBody3D

@onready var anim: AnimationPlayer = $Modelo/AnimationPlayer


func _ready() -> void:
	add_to_group("oyentes")
	_reproducir("idle")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0
	_reproducir("idle")
	move_and_slide()


func oir(punto: Vector3) -> void:
	var distancia: float = global_position.distance_to(punto)
	print(name, " oyó algo a ", snappedf(distancia, 0.01), " m")


func _reproducir(nombre: StringName) -> void:
	if anim.current_animation != nombre:
		anim.play(nombre)
