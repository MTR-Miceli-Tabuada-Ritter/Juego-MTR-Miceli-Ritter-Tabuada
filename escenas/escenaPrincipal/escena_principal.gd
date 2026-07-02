extends Node2D
signal cambioDia()
@export var colorDeNoche: CanvasModulate
@export var interfaz: CanvasLayer
var dia =1
var mes = 1
var bajadaDeNoche = false
var amaneciendo = false
var bajadaDeNocheDuracion = 5
var tiempoTranscurrido = 0.0
var slotEnUso = null

func _process(_delta: float) -> void:
	if bajadaDeNoche:
		tiempoTranscurrido += 0.05
		var colorNuevo= lerp(1.0, 0.5, tiempoTranscurrido/bajadaDeNocheDuracion)
		colorDeNoche.color = Color(colorNuevo,colorNuevo,colorNuevo)
		if tiempoTranscurrido >= bajadaDeNocheDuracion:
			bajadaDeNoche = false
			tiempoTranscurrido = 0.0
	elif amaneciendo:
		tiempoTranscurrido += 0.05
		var colorNuevo= lerp(0.5, 1.0, tiempoTranscurrido/bajadaDeNocheDuracion)
		colorDeNoche.color = Color(colorNuevo,colorNuevo,colorNuevo)
		if tiempoTranscurrido >= bajadaDeNocheDuracion:
			amaneciendo = false
			tiempoTranscurrido = 0.0

func arrancarNoche():
	amaneciendo = false
	bajadaDeNoche = true
	tiempoTranscurrido = 0.0

func arrancarDia():
	bajadaDeNoche = false
	amaneciendo = true
	tiempoTranscurrido = 0.0

func terminarNoche():
	dia += 1
	if dia > 28:
		dia = 1
		mes += 1
	cambioDia.emit()

func cropRecolectado(rutaObjeto, cantidad):
	interfaz.cropRecolectado(rutaObjeto, cantidad)

func setearSlotEnUso(slot):
	slotEnUso = slot
