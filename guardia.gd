extends CharacterBody3D

enum Estado { PATRULLAR, ESPERAR, PERSEGUIR }

@export var rapidez: float = 2.0
@export var espera: float = 1.0
@export var rango_vision: float = 4.0
@export var vida: int = 100
@export var ruta: Array[Vector3] = [
	Vector3.ZERO,
	Vector3(0, 0, -6)
]

var estado: Estado = Estado.PATRULLAR
var puntos: Array[Vector3] = []
var indice: int = 0
var reloj: float = 0.0
var jugador: Node3D

@onready var anim: AnimationPlayer = $Modelo/AnimationPlayer
@onready var vision: RayCast3D = $Vision


func _ready() -> void:
	jugador = get_tree().get_first_node_in_group("jugador")

	for desplazamiento in ruta:
		puntos.append(global_position + desplazamiento)

	_reproducir("idle")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	reloj = maxf(reloj - delta, 0.0)

	if jugador == null:
		frenar()
		move_and_slide()
		return

	var distancia: float = distancia_a(jugador.global_position)
	var lo_ve: bool = _lo_ve()

	var nuevo_estado: Estado = decidir(distancia, lo_ve)
	if nuevo_estado != estado:
		estado = nuevo_estado
		print(name, " -> ", Estado.keys()[estado], " cuadro ",
			Engine.get_physics_frames(), " a ",
			snappedf(distancia, 0.01), " m")

	match estado:
		Estado.PATRULLAR:
			patrullar()
		Estado.ESPERAR:
			frenar()
		Estado.PERSEGUIR:
			ir_a(jugador.global_position)

	move_and_slide()


func decidir(distancia: float, lo_ve: bool) -> Estado:
	if distancia <= rango_vision and lo_ve:
		return Estado.PERSEGUIR
	if reloj > 0.001:
		return Estado.ESPERAR
	return Estado.PATRULLAR


func _lo_ve() -> bool:
	var pecho: Vector3 = jugador.global_position + Vector3(0, 0.9, 0)
	vision.target_position = vision.to_local(pecho)
	vision.force_raycast_update()

	if vision.is_colliding():
		return vision.get_collider() == jugador

	return true


func patrullar() -> void:
	if puntos.is_empty():
		frenar()
		return

	var destino: Vector3 = puntos[indice]
	if distancia_a(destino) < 0.1:
		indice = (indice + 1) % puntos.size()
		reloj = espera
		frenar()
		return

	ir_a(destino)


func ir_a(p: Vector3) -> void:
	var hacia: Vector3 = p - global_position
	hacia.y = 0.0

	if hacia.length() < 0.05:
		frenar()
		return

	var dir: Vector3 = hacia.normalized()
	velocity.x = dir.x * rapidez
	velocity.z = dir.z * rapidez
	basis = Basis.looking_at(dir)
	_reproducir("walk")


func frenar() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	_reproducir("idle")


func distancia_a(p: Vector3) -> float:
	var origen: Vector3 = global_position
	return Vector2(p.x - origen.x, p.z - origen.z).length()


func _reproducir(nombre: String) -> void:
	if anim.current_animation != nombre:
		anim.play(nombre)


func recibir_golpe(danio: int) -> void:
	vida -= danio
	print(name, ": vida ", vida)
	if vida <= 0:
		print(name, " destruida")
		queue_free()
