extends Node

@export var tecla: StringName = &"disparar"
@export var alcance: float = 20.0

@onready var pj: CharacterBody3D = get_parent()

var origen: Vector3 = Vector3.ZERO


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(tecla):
		var golpe: Dictionary = lanzar_rayo()
		if golpe.is_empty():
			print("no le dio a nada en ", alcance, " m")
		else:
			var distancia: float = snappedf(origen.distance_to(golpe.position), 0.01)
			print("le dio a ", golpe.collider.name, " a ", distancia, " m")


func lanzar_rayo() -> Dictionary:
	origen = pj.global_position + Vector3(0.0, 0.8, 0.0)
	var final: Vector3 = origen - pj.global_basis.z * alcance
	var consulta := PhysicsRayQueryParameters3D.create(origen, final)
	consulta.exclude = [pj.get_rid()]
	return pj.get_world_3d().direct_space_state.intersect_ray(consulta)
