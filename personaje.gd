extends CharacterBody3D

enum TipoPrueba {
	NINGUNA,
	AVANZAR_Y_LA_ACCION_DESDE_EL_CUADRO_30,
	MANTENER_LA_ACCION_2_S
}

@export var speed_caminar = 3.0
@export var multiplicador = 1.0
@export var empuje = Vector3.ZERO
@export var accion = ""
@export var prueba: TipoPrueba = TipoPrueba.NINGUNA
@export var accion_prueba = "dash"

var _ultimo_estado_dash = 0

func _ready():
	if prueba != TipoPrueba.NINGUNA:
		_ejecutar_prueba.call_deferred()

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(input_dir.x, 0.0, input_dir.y).normalized()
	velocity.x = direction.x * speed_caminar * multiplicador + empuje.x
	velocity.z = direction.z * speed_caminar * multiplicador + empuje.z
	move_and_slide()
	_imprimir_estado_dash()

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
		print("cuadro ", Engine.get_physics_frames(), ": Dash.estado cambia a ", nombres[estado_actual])
