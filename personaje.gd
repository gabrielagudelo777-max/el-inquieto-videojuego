extends CharacterBody3D

enum TipoPrueba {
	NINGUNA,
	AVANZAR_Y_LA_ACCION_DESDE_EL_CUADRO_30,
	MANTENER_LA_ACCION_2_S
}

enum Estado {
	QUIETO,
	CAMINAR,
	CORRER,
	AIRE
}

const RUIDO = [0.0, 2.0, 6.0, 0.0]

@export var camara: Camera3D
@export var speed_correr = 6.0
@export var speed_caminar = 3.0
@export var tiempo_arranque = 0.25
@export var multiplicador = 1.0
@export var empuje = Vector3.ZERO
@export var accion = ""
@export var prueba: TipoPrueba = TipoPrueba.NINGUNA
@export var accion_prueba = "dash"

var _ultimo_estado_dash = 0
var avance = Vector3.ZERO
var estado = Estado.QUIETO
var ruido = 0.0


func _ready():
	if prueba != TipoPrueba.NINGUNA:
		_ejecutar_prueba.call_deferred()


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	var input_dir = Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)
	var entrada = Vector3(input_dir.x, 0.0, input_dir.y)
	var giro_cam = camara.global_rotation.y
	var direction = entrada.rotated(Vector3.UP, giro_cam).normalized()

	var corre = Input.is_action_pressed("correr")
	var speed = speed_correr if corre else speed_caminar

	var objetivo = direction * speed * multiplicador
	var paso = speed / tiempo_arranque * delta
	avance = avance.move_toward(objetivo, paso)

	velocity.x = avance.x + empuje.x
	velocity.z = avance.z + empuje.z

	move_and_slide()

	var estado_anterior = estado
	estado = elegir_estado()
	ruido = RUIDO[estado]

	if estado != estado_anterior:
		print("estado ", Estado.keys()[estado], " · ruido ", ruido, " m")

	_imprimir_estado_dash()


func elegir_estado():
	if not is_on_floor():
		return Estado.AIRE

	var rapidez = Vector2(velocity.x, velocity.z).length()

	if rapidez < 0.1:
		return Estado.QUIETO
	if rapidez > speed_caminar + 0.1:
		return Estado.CORRER

	return Estado.CAMINAR


func _ejecutar_prueba():
	await get_tree().physics_frame

	match prueba:
		TipoPrueba.AVANZAR_Y_LA_ACCION_DESDE_EL_CUADRO_30:
			Input.action_press("move_up")

			for _cuadro in range(30):
				await get_tree().physics_frame

			Input.action_press(accion_prueba)
			await get_tree().physics_frame
			Input.action_release(accion_prueba)

			for _cuadro in range(60):
				await get_tree().physics_frame

			Input.action_release("move_up")

		TipoPrueba.MANTENER_LA_ACCION_2_S:
			Input.action_press(accion_prueba)

			for _cuadro in range(120):
				await get_tree().physics_frame

			Input.action_release(accion_prueba)

	prueba = TipoPrueba.NINGUNA


func _imprimir_estado_dash():
	var dash = get_node_or_null("Dash")
	if dash == null:
		return

	var estado_actual = dash.get("estado")
	if estado_actual == null:
		return

	if estado_actual != _ultimo_estado_dash:
		_ultimo_estado_dash = estado_actual
		var nombres = ["LISTA", "ACTIVA", "RECARGA"]

		print(
			"cuadro ",
			Engine.get_physics_frames(),
			": Dash.estado cambia a ",
			nombres[estado_actual]
		)
