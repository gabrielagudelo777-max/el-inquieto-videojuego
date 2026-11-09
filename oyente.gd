extends CharacterBody3D

enum Estado { EN_PUESTO, INVESTIGAR, MIRAR, VOLVER }

@export var rapidez: float = 2.0
@export var tiempo_mirar: float = 2.0
# Deja espacio para que el Oyente no choque con el jugador en el origen del ruido.
@export var llega_a: float = 1.0
@export var radio_aviso: float = 5.0

var estado: Estado = Estado.EN_PUESTO
var puesto: Vector3 = Vector3.ZERO
var ruido_en: Vector3 = Vector3.ZERO
var reloj: float = 0.0

@onready var anim: AnimationPlayer = $Modelo/AnimationPlayer


func _ready() -> void:
	add_to_group("oyentes")
	puesto = global_position
	_reproducir("idle")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	reloj = maxf(reloj - delta, 0.0)
	var nuevo_estado: Estado = decidir()
	if nuevo_estado != estado:
		cambiar_a(nuevo_estado)

	match estado:
		Estado.EN_PUESTO, Estado.MIRAR:
			frenar()
		Estado.INVESTIGAR:
			ir_a(ruido_en)
		Estado.VOLVER:
			ir_a(puesto)

	move_and_slide()


func decidir() -> Estado:
	match estado:
		Estado.INVESTIGAR:
			if distancia_a(ruido_en) < llega_a:
				return Estado.MIRAR
		Estado.MIRAR:
			if reloj <= 0.001:
				return Estado.VOLVER
		Estado.VOLVER:
			if distancia_a(puesto) < 0.1:
				return Estado.EN_PUESTO
	return estado


func cambiar_a(nuevo_estado: Estado) -> void:
	estado = nuevo_estado
	print(name, " -> ", Estado.keys()[estado], " cuadro ",
		Engine.get_physics_frames(), " en ", global_position.snappedf(0.01))
	if estado == Estado.MIRAR:
		reloj = tiempo_mirar


func oir(punto: Vector3) -> void:
	# Se guarda antes del cambio para cortar la recursión entre vecinos.
	var estaba_en_puesto: bool = estado == Estado.EN_PUESTO
	ruido_en = punto
	if estado != Estado.INVESTIGAR:
		cambiar_a(Estado.INVESTIGAR)
	if estaba_en_puesto:
		avisar_a_vecinos(punto)


func avisar_a_vecinos(punto: Vector3) -> void:
	for otro: Node3D in get_tree().get_nodes_in_group("oyentes"):
		if otro == self:
			continue
		if global_position.distance_to(otro.global_position) <= radio_aviso:
			print(name, " avisa a ", otro.name)
			otro.oir(punto)


func ir_a(destino: Vector3) -> void:
	var hacia: Vector3 = destino - global_position
	hacia.y = 0.0
	var distancia: float = hacia.length()
	if distancia < 0.05:
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


func distancia_a(punto: Vector3) -> float:
	var origen: Vector3 = global_position
	return Vector2(punto.x - origen.x, punto.z - origen.z).length()


func _reproducir(nombre: StringName) -> void:
	if anim.current_animation != nombre:
		anim.play(nombre)
