class_name MisionActiva
extends RefCounted
## Registro de ejecución, conservado también después de finalizar la misión.
## Los valores numéricos del estado los decide el enum del gestor (sin dependencia
## circular del autoload). No se escriben propiedades del recurso definicion.

var definicion: Mision
var estado: int
var _contadores: Dictionary = {}
var _derrotas_procesadas: Dictionary = {}
var _progreso_final: Dictionary = {}


func _init(mision: Mision, estado_inicial: int) -> void:
	definicion = mision
	estado = estado_inicial


func obtener_progreso(inventario: Inventario) -> Dictionary:
	if not _progreso_final.is_empty():
		return _progreso_final.duplicate(true)
	var resultado: Dictionary = {}
	var requisitos := definicion.obtener_requisitos_entrega()
	for objetivo in definicion.objetivos:
		resultado[objetivo.id] = objetivo.obtener_progreso(inventario, _contadores.get(objetivo.id, 0), requisitos)
	return resultado


func registrar_conversacion(npc_id: String, conversacion_id: String) -> bool:
	var cambio := false
	for objetivo in definicion.objetivos:
		var anterior: int = _contadores.get(objetivo.id, 0)
		var actual := objetivo.aplicar_conversacion(anterior, npc_id, conversacion_id)
		if anterior != actual:
			_contadores[objetivo.id] = actual
			cambio = true
	return cambio


func registrar_derrota(tipo_enemigo: String, evento_id: String) -> bool:
	if _derrotas_procesadas.has(evento_id):
		return false
	_derrotas_procesadas[evento_id] = true
	var cambio := false
	for objetivo in definicion.objetivos:
		var anterior: int = _contadores.get(objetivo.id, 0)
		var actual := objetivo.aplicar_derrota(anterior, tipo_enemigo)
		if anterior != actual:
			_contadores[objetivo.id] = actual
			cambio = true
	return cambio


func completar(estado_completado: int, progreso: Dictionary) -> void:
	estado = estado_completado
	# Comprobante de la entrega: no mostrar 0/3 tras haber consumido los objetos.
	_progreso_final = progreso.duplicate(true)