extends Node

@onready var pj = get_parent()

var cuadro = 0


func _physics_process(_delta):
	cuadro += 1
	if cuadro % 30 == 0:
		var obj = mas_cercano()
		if obj == null:
			print("no hay nada en el grupo interactivos")
		else:
			var distancia = snappedf(distancia_a(obj), 0.01)
			print("objeto mas cercano: ", obj.name, " a ", distancia, " m")


func mas_cercano():
	var mejor = null
	for obj in get_tree().get_nodes_in_group("interactivos"):
		var distancia = distancia_a(obj)
		if mejor == null or distancia < distancia_a(mejor):
			mejor = obj
	return mejor


func distancia_a(obj):
	var a = Vector2(pj.global_position.x, pj.global_position.z)
	var b = Vector2(obj.global_position.x, obj.global_position.z)
	return a.distance_to(b)
