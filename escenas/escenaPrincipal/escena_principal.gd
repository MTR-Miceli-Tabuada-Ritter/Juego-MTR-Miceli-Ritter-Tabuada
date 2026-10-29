extends Node2D
signal cambioDia()
signal plataGanada()

@export var colorDeNoche: CanvasModulate
@export var interfaz: CanvasLayer

var dia = 1
var mes = 1
var plata: int:
	get:
		return InventarioJugador.plata

var bajadaDeNoche = false
var amaneciendo = false
var bajadaDeNocheDuracion = 5
var tiempoTranscurrido = 0.0

func _ready() -> void:
	InventarioJugador.plata_cambiada.connect(_notificar_plata)

func _notificar_plata() -> void:
	plataGanada.emit()

func iniciar_nueva_partida() -> void:
	InventarioJugador.reiniciar()
	dia = 1
	mes = 1
	cambioDia.emit()


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

func cropRecolectado(item: Item, cantidad: int) -> int:
	var sobrante := InventarioJugador.inventario.agregar_item(item, cantidad)
	if sobrante < cantidad:
		SonidosGlobales.reproducirSonidoLogro()
	return sobrante

func agregarPlata(monto):
	InventarioJugador.agregar_plata(monto)
