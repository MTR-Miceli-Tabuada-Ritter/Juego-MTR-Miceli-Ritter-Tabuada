class_name Mision
extends Resource
## Definición de contenido: se trata como inmutable durante toda la partida.
## Estado, contadores y deduplicación pertenecen exclusivamente a MisionActiva.

@export var id: String = ""
@export var titulo: String = ""
@export_multiline var descripcion: String = ""
@export var npc_otorgante_id: String = ""
@export var npc_receptor_id: String = ""
@export var objetivos: Array[ObjetivoMision] = []
@export var recompensa_dinero: int = 0
@export var recompensas_items: Array[RecompensaItem] = []

const MAX_CANTIDAD: int = 9223372036854775807


func es_valida() -> bool:
	if id.strip_edges().is_empty() or titulo.strip_edges().is_empty():
		return false
	if npc_otorgante_id.strip_edges().is_empty() or npc_receptor_id.strip_edges().is_empty():
		return false
	if objetivos.is_empty() or recompensa_dinero < 0:
		return false
	var ids: Dictionary = {}
	var requisitos: Dictionary = {}
	for objetivo in objetivos:
		if objetivo == null or not objetivo.es_valido() or ids.has(objetivo.id):
			return false
		ids[objetivo.id] = true
		var aportes := objetivo.obtener_requisitos_entrega()
		for item_id in aportes:
			var cantidad: Variant = aportes[item_id]
			if not item_id is String or String(item_id).strip_edges().is_empty():
				return false
			if not cantidad is int or cantidad <= 0:
				return false
			var anterior: int = requisitos.get(item_id, 0)
			if cantidad > MAX_CANTIDAD - anterior:
				return false
			requisitos[item_id] = anterior + cantidad
	var premios: Dictionary = {}
	for recompensa in recompensas_items:
		if recompensa == null or not recompensa.es_valida():
			return false
		var anterior: int = premios.get(recompensa.item.id, 0)
		if recompensa.cantidad > MAX_CANTIDAD - anterior:
			return false
		premios[recompensa.item.id] = anterior + recompensa.cantidad
	return true


func obtener_requisitos_entrega() -> Dictionary:
	var requisitos: Dictionary = {}
	for objetivo in objetivos:
		var aportes := objetivo.obtener_requisitos_entrega()
		for item_id in aportes:
			requisitos[item_id] = int(requisitos.get(item_id, 0)) + int(aportes[item_id])
	return requisitos


func crear_recompensas() -> Array[ItemStack]:
	var resultado: Array[ItemStack] = []
	for recompensa in recompensas_items:
		resultado.append(recompensa.crear_stack())
	return resultado