extends CanvasLayer
## Pantalla de derrota provisoria: pausa la partida y ofrece empezar otra.

signal nueva_partida_pedida

@onready var _boton_nueva_partida: Button = $Contenido/NuevaPartida


func _ready() -> void:
	hide()
	_boton_nueva_partida.pressed.connect(_pedir_nueva_partida)


func mostrar() -> void:
	show()
	get_tree().paused = true
	_boton_nueva_partida.grab_focus()


func _pedir_nueva_partida() -> void:
	hide()
	get_tree().paused = false
	nueva_partida_pedida.emit()
