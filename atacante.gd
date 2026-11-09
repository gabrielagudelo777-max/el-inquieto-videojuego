extends CharacterBody3D

enum Estado { ACERCARSE, AVISO, GOLPE, RECARGA, HUIR }

@export var rapidez: float = 2.0
@export var rango_ataque: float = 1.8
@export var tiempo_aviso: float = 0.5
@export var tiempo_recarga: float = 1.0
@export var vida: float = 80.0
@export var vida_huida: float = 30.0
@export var danio_prueba: float = 25.0
@export var alcance_golpe: float = 1.8
@export var danio: int = 1

var estado: Estado = Estado.ACERCARSE
var reloj: float = 0.0
var jugador: Node3D

@onready var anim: AnimationPlayer = $Modelo/AnimationPlayer


func _ready() -> void:
	jugador = get_tree().get_first_node_in_group("jugador") as Node3D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	reloj = maxf(reloj - delta, 0.0)

	var nuevo_estado = decidir()
	if nuevo_estado != estado:
		cambiar_a(nuevo_estado)

	match estado:
		Estado.ACERCARSE:
			ir_a(jugador.global_position)
		Estado.AVISO:
			frenar("interact-right")
		Estado.GOLPE:
			frenar("attack-melee-right")
			golpear()
		Estado.RECARGA:
			frenar("idle")
		Estado.HUIR:
			var lejos = global_position - jugador.global_position
			lejos.y = 0.0
			ir_a(global_position + lejos)

	move_and_slide()


func decidir() -> Estado:
	# La huida tiene prioridad sobre cualquier otro estado.
	if vida <= vida_huida:
		return Estado.HUIR

	match estado:
		Estado.ACERCARSE:
			if distancia() <= rango_ataque:
				return Estado.AVISO

		Estado.AVISO:
			if reloj <= 0.001:
				return Estado.GOLPE

		Estado.GOLPE:
			return Estado.RECARGA

		Estado.RECARGA:
			if reloj <= 0.001:
				return Estado.ACERCARSE

	return estado


func cambiar_a(nuevo_estado: Estado) -> void:
	estado = nuevo_estado
	print(
		name, " -> ", Estado.keys()[estado],
		" cuadro ", Engine.get_physics_frames(),
		" a ", snappedf(distancia(), 0.01), " m"
	)

	if estado == Estado.AVISO:
		reloj = tiempo_aviso
	elif estado == Estado.RECARGA:
		reloj = tiempo_recarga


func golpear() -> void:
	var distancia_actual = distancia()

	if distancia_actual > alcance_golpe:
		print(name, " falla a ", snappedf(distancia_actual, 0.01), " m")
		return

	var salud = jugador.get_node_or_null("Salud")
	if salud != null:
		salud.recibir_golpe(danio)


func recibir_golpe(cuanto: float) -> void:
	vida -= cuanto
	print(name, " vida ", vida)

	if vida <= 0.0:
		print(name, " vencido")
		queue_free()


func ir_a(destino: Vector3) -> void:
	var hacia = destino - global_position
	hacia.y = 0.0
	var direccion = hacia.normalized()

	velocity.x = direccion.x * rapidez
	velocity.z = direccion.z * rapidez
	basis = Basis.looking_at(direccion)

	if anim.current_animation != "walk":
		anim.play("walk")


func frenar(nombre_animacion: String) -> void:
	velocity.x = 0.0
	velocity.z = 0.0

	if anim.current_animation != nombre_animacion:
		anim.play(nombre_animacion)


func distancia() -> float:
	var p = jugador.global_position
	var o = global_position
	return Vector2(p.x - o.x, p.z - o.z).length()
