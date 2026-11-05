extends Node

@export var tecla: StringName = &"interactuar"
@export var alcance: float = 1.5
@export var tiempo_necesario: float = 1.5
@onready var pj: Node3D = get_parent()

var objeto_en_progreso: Node3D = null
var progreso: float = 0.0
var ultimo_hito: int = 0
var cuadros_en_progreso: int = 0
var completado: bool = false
var cuadros_para_busqueda: int = 0


func _physics_process(delta: float) -> void:
	cuadros_para_busqueda += 1
	if cuadros_para_busqueda >= 30:
		cuadros_para_busqueda = 0
		imprimir_mas_cercano()

	if not Input.is_action_pressed(tecla):
		reiniciar_progreso()
		return

	var obj: Node3D = mas_cercano(true)
	if obj == null:
		if Input.is_action_just_pressed(tecla):
			print("nada a menos de ", alcance, " m")
		reiniciar_progreso()
		return

	if obj != objeto_en_progreso:
		objeto_en_progreso = obj
		progreso = 0.0
		ultimo_hito = 0
		cuadros_en_progreso = 0
		completado = false

	if completado:
		return

	cuadros_en_progreso += 1
	if tiempo_necesario <= 0.0:
		progreso = 1.0
	else:
		progreso = minf(progreso + delta / tiempo_necesario, 1.0)

	while ultimo_hito < 75 and progreso >= float(ultimo_hito + 25) / 100.0:
		ultimo_hito += 25
		print("cuadro ", cuadros_en_progreso, ": ", ultimo_hito, " %")

	if progreso >= 1.0:
		print("cuadro ", cuadros_en_progreso, ": completado")
		if obj.has_method("usar"):
			obj.usar()
		completado = true


func imprimir_mas_cercano() -> void:
	var obj: Node3D = mas_cercano(false)
	if obj == null:
		print("no hay nada en el grupo interactivos")
		return

	print("objeto mas cercano: ", obj.name, " a ", snappedf(distancia_a(obj), 0.01), " m")


func reiniciar_progreso() -> void:
	objeto_en_progreso = null
	progreso = 0.0
	ultimo_hito = 0
	cuadros_en_progreso = 0
	completado = false


func mas_cercano(limitar_al_alcance: bool = true) -> Node3D:
	var mejor: Node3D = null
	for nodo in get_tree().get_nodes_in_group("interactivos"):
		if not nodo is Node3D:
			continue
		var obj := nodo as Node3D
		var distancia := distancia_a(obj)
		if limitar_al_alcance and distancia > alcance:
			continue
		if mejor == null or distancia < distancia_a(mejor):
			mejor = obj
	return mejor


func distancia_a(obj: Node3D) -> float:
	var a := Vector2(pj.global_position.x, pj.global_position.z)
	var b := Vector2(obj.global_position.x, obj.global_position.z)
	return a.distance_to(b)
