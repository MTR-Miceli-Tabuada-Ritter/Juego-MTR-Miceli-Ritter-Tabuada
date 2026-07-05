extends CanvasLayer
@export var horaTexto: RichTextLabel
@export var mesTexto: RichTextLabel
@export var diaTexto: RichTextLabel
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
var velocidadMultiplicador = 10000.0
var centrar = "[center]"
var escenaPrincipal

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	escenaPrincipal.connect("cambioDia",_cambiarFecha)
	_cambiarFecha()
	setearTemporal()

func setearTemporal():
	slot5.setearSlot("icono_semilla", 0, 1)
	slot6.setearSlot("icono_semilla", 1, 1)
	slot7.setearSlot("icono_semilla", 2, 1)
	slot8.setearSlot("icono_semilla", 3, 1)
	slot9.setearSlot("icono_herramienta", 0, 1)
	slot10.setearSlot("icono_herramienta", 1, 1)

func _cambiarFecha():
	diaTexto.text = centrar + "%02d" % [escenaPrincipal.dia]
	mesTexto.text = centrar + "%02d" % [escenaPrincipal.mes]

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

func cropRecolectado(rutaObjeto, idObjeto, cantidad):
	var slots = [slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9, slot10]
	for slot in slots:
		if slot.estaEnUso and slot.texturaNombre == rutaObjeto and slot.texturaId == idObjeto:
			slot.cambiarTexto(cantidad)
			return
	for slot in slots:
		if not slot.estaEnUso:
			slot.setearSlot(rutaObjeto, idObjeto, cantidad)
			return
