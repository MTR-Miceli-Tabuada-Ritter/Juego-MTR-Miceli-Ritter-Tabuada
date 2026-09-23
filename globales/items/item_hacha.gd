class_name ItemHacha
extends ItemHerramienta

func usar(jugador, agujero, _stack: ItemStack) -> void:
	if agujero != null:
		return
	var tilemap: TileMapLayer = jugador.tilemap
	var pos_tile = tilemap.local_to_map(tilemap.to_local(jugador.direccionVistaMarker.global_position))
	print("suelo fertilizado")
	var agujero_instancia = jugador.agujeroPreload.instantiate()
	agujero_instancia.position = jugador.direccionVistaMarker.global_position
	agujero_instancia.name = bloqueCultivable.obtenerNombre(pos_tile)
	agujero_instancia.z_index = -1
	jugador.escenaPrincipal.get_node("escenario").call_deferred("add_child", agujero_instancia)

func sonido_al_usar() -> void:
	SonidosGlobales.reproducirSonidoCortar()
