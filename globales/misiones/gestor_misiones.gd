extends Node
## Autoload GestorMisiones (sin class_name, para no colisionar con ese nombre).
## Toda operación es síncrona. No requiere escenas del juego ni _process.

enum Estado { DISPONIBLE, ACTIVA, COMPLETADA }

signal mision_aceptada(mision_id: String)
signal progreso_actualizado(mision_id: String, progreso: Dictionary)
signal disponibilidad_finalizacion_cambiada(mision_id: String, disponible: bool)
signal mision_completada(mision_id: String)

const CATALOGO_INICIAL: Array[Mision] = [
	preload("res://recursos/misiones/gallo_papas.tres"),
	preload("res://recursos/misiones/gallo_vaca.tres"),
	preload("res://recursos/misiones/gallo_esqueleto.tres"),
]

var _catalogo: Dictionary = {}
var _registros: Dictionary = {}
var _disponibilidad_cache: Dictionary = {}
var _inventario: Inventario
var _recompensar_dinero: Callable
var _ocupado: bool = false
var _inventario_pendiente: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for mision in CATALOGO_INICIAL:
		registrar_mision(mision)
	configurar(InventarioJugador.inventario, InventarioJugador.agregar_plata)


func _exit_tree() -> void:
	_desconectar_inventario()


func configurar(inventario: Inventario, recompensar_dinero: Callable) -> void:
	if _ocupado or inventario == null or not recompensar_dinero.is_valid():
		return
	_desconectar_inventario()
	_inventario = inventario
	_recompensar_dinero = recompensar_dinero
	_inventario.inventario_cambiado.connect(_al_cambiar_inventario)
	_ocupado = true
	_publicar_actualizaciones(_ids_activos())
	_terminar_operacion()


func registrar_mision(mision: Mision) -> bool:
	if _ocupado or mision == null or not mision.es_valida() or _catalogo.has(mision.id):
		return false
	_catalogo[mision.id] = mision
	return true


func aceptar_mision(id: String) -> bool:
	if _ocupado or obtener_estado(id) != Estado.DISPONIBLE:
		return false
	var definicion: Mision = _catalogo[id]
	if not definicion.es_valida():
		return false
	_ocupado = true
	_registros[id] = MisionActiva.new(definicion, Estado.ACTIVA)
	mision_aceptada.emit(id)
	_publicar_actualizaciones([id])
	_terminar_operacion()
	return true


func obtener_estado(id: String) -> int:
	if not _catalogo.has(id):
		return -1
	if not _registros.has(id):
		return Estado.DISPONIBLE
	var registro: MisionActiva = _registros[id]
	return registro.estado


func obtener_progreso(id: String) -> Dictionary:
	if not _catalogo.has(id):
		return {}
	if _registros.has(id):
		var registro: MisionActiva = _registros[id]
		return registro.obtener_progreso(_inventario)
	# Consultar una oferta no crea un registro ni cuenta eventos previos.
	return MisionActiva.new(_catalogo[id], Estado.DISPONIBLE).obtener_progreso(_inventario)


func puede_finalizar(id: String, npc_id: String) -> bool:
	if not _catalogo.has(id):
		return false
	var mision: Mision = _catalogo[id]
	return npc_id == mision.npc_receptor_id and _esta_lista(id)


func intentar_finalizar(id: String, npc_id: String) -> bool:
	if _ocupado or not puede_finalizar(id, npc_id):
		return false
	_ocupado = true
	var registro: MisionActiva = _registros[id]
	var mision := registro.definicion
	var progreso := registro.obtener_progreso(_inventario)
	var recompensas := mision.crear_recompensas()
	# El modelo simula sobre una copia y confirma todo o nada. Nunca quitar
	# primero y agregar después: un premio sin lugar no debe consumir requisitos.
	if not _inventario.intentar_intercambio(mision.obtener_requisitos_entrega(), recompensas, false):
		_terminar_operacion()
		return false
	registro.completar(Estado.COMPLETADA, progreso)
	if mision.recompensa_dinero > 0:
		_recompensar_dinero.call(mision.recompensa_dinero)
	# Estado, dinero e inventario ya son consistentes antes de notificar.
	# La guardia sigue tomada incluso dentro de señales de inventario/dinero.
	_inventario.notificar_cambio()
	_inventario_pendiente = false
	var afectados := _ids_activos()
	afectados.append(id)
	_publicar_actualizaciones(afectados)
	mision_completada.emit(id)
	_terminar_operacion()
	return true


func registrar_conversacion(npc_id: String, conversacion_id: String) -> void:
	if _ocupado or npc_id.strip_edges().is_empty() or conversacion_id.strip_edges().is_empty():
		return
	_ocupado = true
	var afectados: Array[String] = []
	for id in _ids_activos():
		var registro: MisionActiva = _registros[id]
		if registro.registrar_conversacion(npc_id, conversacion_id):
			afectados.append(id)
	if not afectados.is_empty():
		_publicar_actualizaciones(afectados)
	_terminar_operacion()


func registrar_derrota(tipo_enemigo: String, evento_id: String, responsable: Node) -> void:
	if _ocupado or tipo_enemigo.strip_edges().is_empty() or evento_id.strip_edges().is_empty():
		return
	if not is_instance_valid(responsable) or not responsable.is_in_group("jugador"):
		return
	_ocupado = true
	var afectados: Array[String] = []
	for id in _ids_activos():
		var registro: MisionActiva = _registros[id]
		if registro.registrar_derrota(tipo_enemigo, evento_id):
			afectados.append(id)
	if not afectados.is_empty():
		_publicar_actualizaciones(afectados)
	_terminar_operacion()


func reiniciar() -> void:
	if _ocupado:
		return
	_ocupado = true
	var anteriores: Array[String] = []
	for id in _registros:
		anteriores.append(id)
	_registros.clear()
	# No reiniciar catálogo, dinero ni el modelo del propietario.
	_publicar_actualizaciones(anteriores)
	_disponibilidad_cache.clear()
	_terminar_operacion()


func _esta_lista(id: String) -> bool:
	# La cache sirve únicamente para detectar cambios de señal: nunca autoriza
	# una entrega. Se consulta nuevamente el modelo completo en cada operación.
	if obtener_estado(id) != Estado.ACTIVA or _inventario == null or not _recompensar_dinero.is_valid():
		return false
	var mision: Mision = _catalogo[id]
	if not mision.es_valida():
		return false
	var progreso := obtener_progreso(id)
	for objetivo_id in progreso:
		if not progreso[objetivo_id]["completo"]:
			return false
	return _inventario.puede_intercambiar(mision.obtener_requisitos_entrega(), mision.crear_recompensas())


func _ids_activos() -> Array[String]:
	var resultado: Array[String] = []
	for id in _registros:
		var registro: MisionActiva = _registros[id]
		if registro.estado == Estado.ACTIVA:
			resultado.append(id)
	return resultado


func _publicar_actualizaciones(ids: Array[String]) -> void:
	var cambios: Dictionary = {}
	for id in _catalogo:
		var lista := _esta_lista(id)
		if lista != bool(_disponibilidad_cache.get(id, false)):
			cambios[id] = lista
		_disponibilidad_cache[id] = lista
	for id in ids:
		progreso_actualizado.emit(id, obtener_progreso(id))
	for id in cambios:
		disponibilidad_finalizacion_cambiada.emit(id, cambios[id])


func _al_cambiar_inventario() -> void:
	_inventario_pendiente = true
	if _ocupado:
		return
	_ocupado = true
	_terminar_operacion()


func _terminar_operacion() -> void:
	# Señales síncronas pueden modificar el inventario desde otro observador.
	# Drenar esa invalidación sin recursión, esperas, timers ni polling por frame.
	while _inventario_pendiente:
		_inventario_pendiente = false
		_publicar_actualizaciones(_ids_activos())
	_ocupado = false


func _desconectar_inventario() -> void:
	if _inventario != null and _inventario.inventario_cambiado.is_connected(_al_cambiar_inventario):
		_inventario.inventario_cambiado.disconnect(_al_cambiar_inventario)