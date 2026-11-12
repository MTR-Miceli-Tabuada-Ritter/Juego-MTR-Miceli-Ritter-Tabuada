extends CanvasLayer

@export var horaTexto: RichTextLabel
@export var mesTexto: RichTextLabel
@export var diaTexto: RichTextLabel
@export var plataTexto: RichTextLabel

@export var slot1: TextureRect
@export var slot2: TextureRect
@export var slot3: TextureRect
@export var slot4: TextureRect
@export var slot5: TextureRect
@export var slot6: TextureRect
@export var slot7: TextureRect
@export var slot8: TextureRect
@export var slot9: TextureRect
@export var slot10: TextureRect

var esDeNoche = false
var tiempoEnSegundos = 21600.0
var velocidadMultiplicador = 1000.0
var centrar = "[center]"
var escenaPrincipal

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	escenaPrincipal.connect("cambioDia",_cambiarFecha)
	InventarioJugador.plata_cambiada.connect(_cambiarPlata)
	InventarioJugador.inventario.inventario_cambiado.connect(_actualizar_inventario)
	_cambiarFecha()
	_cambiarPlata()
	_actualizar_inventario()

func _actualizar_inventario() -> void:
	var slots = [slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9, slot10]
	for i in range(slots.size()):
		slots[i].set_stack(InventarioJugador.inventario.obtener_stack(i))

func _cambiarFecha():
	diaTexto.text = centrar + "%02d" % [escenaPrincipal.dia]
	mesTexto.text = centrar + "%02d" % [escenaPrincipal.mes]

func _cambiarPlata():
	plataTexto.text = "%03d" % [InventarioJugador.plata]

func _process(delta: float) -> void:
	tiempoEnSegundos += delta * velocidadMultiplicador 
	var horas = int(tiempoEnSegundos / 3600) % 24
	var minutos = int(tiempoEnSegundos / 60) % 60
	var esHoraDeNoche = horas >= 18 or horas < 5
	if esHoraDeNoche and esDeNoche == false:
		esDeNoche = true
		escenaPrincipal.arrancarNoche()
	if esHoraDeNoche == false and esDeNoche == true:
		esDeNoche = false
		escenaPrincipal.arrancarDia()
	if tiempoEnSegundos >= 86400: #lo q dura un dia
		tiempoEnSegundos = 0.0
		escenaPrincipal.terminarNoche()
	horaTexto.text = centrar + "%02d:%02d" % [horas,minutos]

