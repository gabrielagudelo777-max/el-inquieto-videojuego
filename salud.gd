extends Node

@export var vida: int = 3
@export var invulnerable: float = 1.5

var reloj: float = 0.0


func _physics_process(delta: float) -> void:
	reloj = maxf(reloj - delta, 0.0)


func recibir_golpe(danio: int) -> void:
	if reloj > 0.001:
		print("invulnerable: no cuenta")
		return

	vida = maxi(vida - danio, 0)
	reloj = invulnerable
	print("vida del jugador: ", vida)

	if vida == 0:
		print("el jugador perdió")
