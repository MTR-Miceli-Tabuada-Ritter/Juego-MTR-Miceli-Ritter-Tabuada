extends Node

var reproductorSonidoCaminar: AudioStreamPlayer
var reproductorSonidoCortar: AudioStreamPlayer
var reproductorSonidoRegar: AudioStreamPlayer
var reproductorSonidoLogro: AudioStreamPlayer
var reproductorSonidoSeleccionar: AudioStreamPlayer
var reproductorSonidoPlantar: AudioStreamPlayer

var sonidoSeleccionar1 = preload("res://recursos/audio/sonidos/Seleccionar1.mp3")
var sonidoSeleccionar2 = preload("res://recursos/audio/sonidos/Seleccionar2.mp3")

func _ready() -> void:
	reproductorSonidoCaminar = AudioStreamPlayer.new()
	add_child(reproductorSonidoCaminar)
	reproductorSonidoCaminar.stream = preload("res://recursos/audio/sonidos/Caminar1.mp3")
	reproductorSonidoCaminar.set_bus("SFX")

	reproductorSonidoCortar = AudioStreamPlayer.new()
	add_child(reproductorSonidoCortar)
	reproductorSonidoCortar.stream = preload("res://recursos/audio/sonidos/Cortar1.mp3")
	reproductorSonidoCortar.set_bus("SFX")

	reproductorSonidoRegar = AudioStreamPlayer.new()
	add_child(reproductorSonidoRegar)
	reproductorSonidoRegar.stream = preload("res://recursos/audio/sonidos/Regar.mp3")
	reproductorSonidoRegar.set_bus("SFX")

	reproductorSonidoLogro = AudioStreamPlayer.new()
	add_child(reproductorSonidoLogro)
	reproductorSonidoLogro.stream = preload("res://recursos/audio/sonidos/Logro.mp3")
	reproductorSonidoLogro.set_bus("SFX")

	reproductorSonidoSeleccionar = AudioStreamPlayer.new()
	add_child(reproductorSonidoSeleccionar)
	reproductorSonidoSeleccionar.set_bus("SFX")

	reproductorSonidoPlantar = AudioStreamPlayer.new()
	add_child(reproductorSonidoPlantar)
	reproductorSonidoPlantar.stream = preload("res://recursos/audio/sonidos/Plantar.mp3")
	reproductorSonidoPlantar.set_bus("SFX")

func reproducirSonidoCaminar() -> void:
	if not reproductorSonidoCaminar.playing:
		reproductorSonidoCaminar.play()

func detenerSonidoCaminar() -> void:
	reproductorSonidoCaminar.stop()

func reproducirSonidoCortar() -> void:
	reproductorSonidoCortar.play()

func reproducirSonidoRegar() -> void:
	reproductorSonidoRegar.play()

func detenerSonidoRegar() -> void:
	reproductorSonidoRegar.stop()

func reproducirSonidoPlantar() -> void:
	reproductorSonidoPlantar.play()

func reproducirSonidoLogro() -> void:
	reproductorSonidoLogro.play()

func reproducirSonidoSeleccionar() -> void:
	reproductorSonidoSeleccionar.stream = [sonidoSeleccionar1, sonidoSeleccionar2][randi() % 2]
	reproductorSonidoSeleccionar.play()
