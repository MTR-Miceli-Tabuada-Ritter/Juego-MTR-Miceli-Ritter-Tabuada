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

const ITEM_HACHA = preload("res://recursos/items/hacha.tres")
const ITEM_REGADERA = preload("res://recursos/items/regadera.tres")
const ITEM_SEMILLA_0 = preload("res://recursos/items/semilla_0.tres")
const ITEM_SEMILLA_1 = preload("res://recursos/items/semilla_1.tres")
const ITEM_SEMILLA_2 = preload("res://recursos/items/semilla_2.tres")
const ITEM_SEMILLA_3 = preload("res://recursos/items/semilla_3.tres")

var esDeNoche = false
var tiempoEnSegundos = 21600.0
var velocidadMultiplicador = 1000.0
var centrar = "[center]"
var escenaPrincipal

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	escenaPrincipal.connect("cambioDia",_cambiarFecha)
	escenaPrincipal.connect("plataGanada", _cambiarPlata)
	_cambiarFecha()
	setearTemporal()

func setearTemporal():
	slot5.set_stack(ItemStack.new(ITEM_SEMILLA_0, 14))
	slot6.set_stack(ItemStack.new(ITEM_SEMILLA_1, 15))
	slot7.set_stack(ItemStack.new(ITEM_SEMILLA_2, 15))
	slot8.set_stack(ItemStack.new(ITEM_SEMILLA_3, 1))
	slot9.set_stack(ItemStack.new(ITEM_HACHA, 1))
	slot10.set_stack(ItemStack.new(ITEM_REGADERA, 100))

func _cambiarFecha():
	diaTexto.text = centrar + "%02d" % [escenaPrincipal.dia]
	mesTexto.text = centrar + "%02d" % [escenaPrincipal.mes]

func _cambiarPlata():
	plataTexto.text = "%03d" % [escenaPrincipal.plata]

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

func cropRecolectado(item: Item, cantidad: int):
	var slots = [slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9, slot10]
	for slot in slots:
		if slot.stack != null and slot.stack.item == item:
			slot.stack.agregar(cantidad)
			slot.actualizar_visual()
			return
	for slot in slots:
		if slot.stack == null:
			slot.set_stack(ItemStack.new(item, cantidad))
			return
