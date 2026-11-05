extends StaticBody3D

@export var vida: int = 100


func recibir_golpe(danio: int) -> void:
	vida -= danio
	print(name, ": vida ", vida)
	if vida <= 0:
		print(name, " destruida")
		queue_free()
