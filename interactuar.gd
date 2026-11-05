extends Node

@export var tecla = "interactuar"
@export var alcance = 1.5
@export var tiempo_necesario = 1.5
@onready var pj = get_parent()

var objeto_en_progreso = null
var progreso = 0.0
var ultimo_mensaje = 0
var cuadros_en_progreso = 0
var completado = false


func _physics_process(_delta):
	if not Input.is_action_pressed(tecla):
		reiniciar_progreso()
		return

	var obj = mas_cercano()
	if obj == null:
		reiniciar_progreso()
		return

	if obj != objeto_en_progreso:
		objeto_en_progreso = obj
		progreso = 0.0
		ultimo_mensaje = 0
		cuadros_en_progreso = 0
		completado = false

	if completado:
		return

	cuadros_en_progreso += 1
	progreso += _delta / tiempo_necesario

	if progreso >= 0.25 and ultimo_mensaje < 25:
		imprimir_progreso(25)
	if progreso >= 0.50 and ultimo_mensaje < 50:
		imprimir_progreso(50)
	if progreso >= 0.75 and ultimo_mensaje < 75:
		imprimir_progreso(75)

	if progreso >= 0.9999:
		progreso = 1.0
		print("cuadro ", cuadros_en_progreso, ": completado")
		if obj.has_method("usar"):
			obj.usar()
		completado = true


func imprimir_progreso(porcentaje):
	ultimo_mensaje = porcentaje
	print("cuadro ", cuadros_en_progreso, ": ", porcentaje, " %")


func reiniciar_progreso():
	objeto_en_progreso = null
	progreso = 0.0
	ultimo_mensaje = 0
	cuadros_en_progreso = 0
	completado = false


func mas_cercano():
	var mejor = null
	for obj in get_tree().get_nodes_in_group("interactivos"):
		var distancia = distancia_a(obj)
		if distancia <= alcance and (mejor == null or distancia < distancia_a(mejor)):
			mejor = obj
	return mejor


func distancia_a(obj):
	var a = Vector2(pj.global_position.x, pj.global_position.z)
	var b = Vector2(obj.global_position.x, obj.global_position.z)
	return a.distance_to(b)
