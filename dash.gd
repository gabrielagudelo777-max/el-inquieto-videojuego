extends Node

enum Estado { LISTA, ACTIVA, RECARGA }

@export var tecla = "dash"
@export var duracion = 0.2
@export var recarga = 1.5
@export var rapidez = 15.0
@onready var pj = get_parent()

var estado = Estado.LISTA
var tiempo = 0.0

func _physics_process(delta):
	tiempo -= delta
	match estado:
		Estado.LISTA:
			if Input.is_action_just_pressed(tecla) and puede():
				empezar()
		Estado.ACTIVA:
			if tiempo <= 0.001:
				terminar()
		Estado.RECARGA:
			if tiempo <= 0.001:
				estado = Estado.LISTA

func puede():
	# Regla: solo se puede usar si el personaje está en el suelo
	return pj.is_on_floor() if pj.has_method("is_on_floor") else true

func empezar():
	estado = Estado.ACTIVA
	tiempo = duracion
	# Enchufes de personaje.gd
	pj.empuje = -pj.basis.z * rapidez   # Dispara al personaje hacia adelante
	pj.multiplicador = 0.0              # Bloquea la velocidad manual de las teclas
	pj.accion = "crouch"                # Aplica la animación crouch
	print("empieza: ", tecla)

func terminar():
	estado = Estado.RECARGA
	tiempo = recarga
	# Restaura los enchufes por defecto
	pj.empuje = Vector3.ZERO
	pj.multiplicador = 1.0
	pj.accion = ""
	print("termina: ", tecla)
