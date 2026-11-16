extends CanvasLayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar") and not PausaDialogo.dialogo_activo and not InventarioJugador.ventana_abierta:
		# Solo quita la pausa propia: otra pantalla (p. ej. la derrota) puede haber pausado.
		if get_tree().paused and not visible:
			return
		alternar_pausa()

func alternar_pausa():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
