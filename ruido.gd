extends Node

@export var tecla: StringName = &"hacer_ruido"
@export var radio: float = 6.0

@onready var jugador: CharacterBody3D = get_parent()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(tecla):
		sonar()


func sonar() -> void:
	var cuantos: int = 0
	for oyente: Node3D in get_tree().get_nodes_in_group("oyentes"):
		if jugador.global_position.distance_to(oyente.global_position) <= radio:
			oyente.oir(jugador.global_position)
			cuantos += 1

	print("ruido de ", radio, " m: lo oyen ", cuantos)
