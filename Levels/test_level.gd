extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var addres_entery = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddresEntery

@export var Player = preload("res://Sceens/player.tscn")
const  PORT = 9999
var EnetPeer = ENetMultiplayerPeer.new()

func _on_host_button_pressed():
	main_menu.hide()
	
	EnetPeer.create_server(PORT)
	multiplayer.multiplayer_peer = EnetPeer
	multiplayer.peer_connected.connect(AddPlayer)
	multiplayer.peer_disconnected.connect(RemovePlayer)
	
	AddPlayer(multiplayer.get_unique_id())


func _on_join_button_pressed():
	main_menu.hide()
	
	EnetPeer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = EnetPeer


func AddPlayer(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

func RemovePlayer(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
