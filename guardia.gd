extends CharacterBody3D

enum Estado { PATRULLA, PERSEGUIR }

@export var objetivo: Node3D
@export var rapidez: float = 2.0
@export var radio_ver: float = 6.0
@export var radio_perder: float = 9.0
@export var vida: int = 100
@export var puntos: Array[Vector3] = [
	Vector3(-6, 0, -3),
	Vector3(6, 0, -3)
]
@onready var anim: AnimationPlayer = $Modelo/AnimationPlayer

var estado: Estado = Estado.PATRULLA
var punto: int = 0


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

	var distancia: float = global_position.distance_to(objetivo.global_position)

	match estado:
		Estado.PATRULLA:
			if distancia < radio_ver:
				estado = Estado.PERSEGUIR
				print("lo vio a ", snappedf(distancia, 0.01), " m")

			if puntos.is_empty():
				velocity.x = 0.0
				velocity.z = 0.0
				_reproducir("idle")
			else:
				ir_a(puntos[punto])
				if global_position.distance_to(puntos[punto]) < 0.3:
					punto = (punto + 1) % puntos.size()

		Estado.PERSEGUIR:
			if distancia > radio_perder:
				estado = Estado.PATRULLA
				print("lo perdió a ", snappedf(distancia, 0.01), " m")
			ir_a(objetivo.global_position)

	move_and_slide()


func ir_a(p: Vector3) -> void:
	var hacia: Vector3 = p - global_position
	hacia.y = 0.0

	if hacia.length() < 0.05:
		velocity.x = 0.0
		velocity.z = 0.0
		_reproducir("idle")
		return

	var dir: Vector3 = hacia.normalized()
	velocity.x = dir.x * rapidez
	velocity.z = dir.z * rapidez
	basis = Basis.looking_at(dir)
	_reproducir("walk")


func _reproducir(nombre: String) -> void:
	if anim.current_animation != nombre:
		anim.play(nombre)


func recibir_golpe(danio: int) -> void:
	vida -= danio
	print(name, ": vida ", vida)
	if vida <= 0:
		print(name, " destruida")
		queue_free()
