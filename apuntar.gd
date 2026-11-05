extends Node

@export var tecla: StringName = &"disparar"
@export var alcance: float = 20.0
@export_enum("Personaje", "Centro de la cámara", "Mouse") var desde: int = 0
@export var danio: int = 25
@export var cadencia: float = 0.25

@onready var pj: CharacterBody3D = get_parent()

var origen: Vector3 = Vector3.ZERO
var espera: float = 0.0


func _physics_process(delta: float) -> void:
	espera -= delta
	if Input.is_action_pressed(tecla) and espera <= 0.001:
		espera = cadencia
		var golpe: Dictionary = lanzar_rayo()
		if golpe.is_empty():
			print("no le dio a nada en ", alcance, " m")
			return

		var distancia: float = snappedf(origen.distance_to(golpe.position), 0.01)
		print("le dio a ", golpe.collider.name, " a ", distancia, " m")
		if golpe.collider.has_method("recibir_golpe"):
			golpe.collider.recibir_golpe(danio)


func lanzar_rayo() -> Dictionary:
	var final: Vector3
	if desde == 0:
		origen = pj.global_position + Vector3(0.0, 0.8, 0.0)
		final = origen - pj.global_basis.z * alcance
	else:
		var camara: Camera3D = get_viewport().get_camera_3d()
		var punto: Vector2 = get_viewport().get_visible_rect().size / 2.0
		if desde == 2:
			punto = get_viewport().get_mouse_position()
		origen = camara.project_ray_origin(punto)
		final = origen + camara.project_ray_normal(punto) * alcance

	var consulta := PhysicsRayQueryParameters3D.create(origen, final)
	consulta.exclude = [pj.get_rid()]
	return pj.get_world_3d().direct_space_state.intersect_ray(consulta)
