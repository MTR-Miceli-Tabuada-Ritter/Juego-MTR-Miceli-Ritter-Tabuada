extends Node2D
signal cambioDia()
@export var colorDeNoche: CanvasModulate
var dia =1
var mes = 1
var bajadaDeNoche = false
var bajadaDeNocheDuracion = 5
var tiempoTranscurrido = 0.0

func _process(_delta: float) -> void:
	#simulacion para la bajada del sol je
	if bajadaDeNoche:
		if tiempoTranscurrido < bajadaDeNocheDuracion:
			tiempoTranscurrido += 0.05
			#lerp es la interpolacion. va desde el 1.0 hasta el 0.5. 
			# el tiempo transcurrido se va sumando por cada frame del _process
			#lo que hace que la pantalla se vaya oscureciendo
			var colorNuevo= lerp(1.0, 0.5, tiempoTranscurrido/bajadaDeNocheDuracion)
			colorDeNoche.color = Color(colorNuevo,colorNuevo,colorNuevo)
	else:
		bajadaDeNoche = false
		tiempoTranscurrido = 0.0

func _arrancarNoche():
	bajadaDeNoche = true
	
func _terminarNoche():
	dia += 1
	if dia > 28:
		dia = 1
		mes += 1
	colorDeNoche.color = Color(1,1,1)
	cambioDia.emit()
