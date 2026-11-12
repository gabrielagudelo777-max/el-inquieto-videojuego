extends Area3D

@export var valor: int = 1

func _ready() -> void:
	add_to_group("objetivos")
	body_entered.connect(_al_entrar)
	
func _al_entrar(cuerpo: Node3D) -> void:
	if not cuerpo.is_in_group("jugador"):
		return

	print(name, " recogido cuadro ", Engine.get_physics_frames())
	queue_free()
