extends Node

var lobby_id : int = 0
var peer : SteamMultiplayerPeer
@export var player_scene : PackedScene

# --- NEW VARIABLES ---
@onready var multiplayer_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var spawn_point: Marker3D = $PlayerSpawner/Marker3D

@onready var host: Button = $CanvasLayer/SteamMulti/MarginContainer/VBoxContainer/HostButton
@onready var join: Button = $CanvasLayer/SteamMulti/MarginContainer/VBoxContainer/JoinButton
@onready var address: LineEdit = $CanvasLayer/SteamMulti/MarginContainer/VBoxContainer/AddresEntery

func _ready() -> void:
	# 1. Setup the Spawner Function
	multiplayer_spawner.spawn_function = _spawn_player
	
	print("Steam initialized: ", Steam.steamInit(480, true))
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_join)

# 2. This is the ONLY place a player is instantiated
func _spawn_player(data):
	var player = player_scene.instantiate()
	player.name = str(data.peer_id)
	player.set_multiplayer_authority(data.peer_id)
	return player

func host_lobby():
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 16)

func _on_lobby_created(result: int, lobby_id: int):
	if result == Steam.Result.RESULT_OK:
		self.lobby_id = lobby_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		multiplayer.multiplayer_peer = peer
		
		# 3. Connect signals
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
		# 4. Spawn the Host manually (ID 1)
		_on_peer_connected(1)
		
		$CanvasLayer/SteamMulti.visible = false
		print("lobby created, lobby id:", lobby_id)

func join_lobby(lobby_id : int):
	Steam.joinLobby(lobby_id)

func _on_lobby_join(lobby_id : int, permissions : int, locked : bool, response : int):
	self.lobby_id = lobby_id
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer
	
	# 5. CLIENTS DO NOTHING HERE. 
	# They wait for the server's Spawner to automatically create the player.
	$CanvasLayer/SteamMulti.visible = false

func _on_peer_connected(id: int):
	# 6. Only the Server is allowed to request a spawn
	if multiplayer.is_server():
		multiplayer_spawner.spawn({ "peer_id": id })

func _on_peer_disconnected(id: int):
	if multiplayer.is_server():
		if spawn_point.has_node(str(id)):
			spawn_point.get_node(str(id)).queue_free()

func _on_host_button_pressed() -> void:
	host_lobby()

func _on_join_button_pressed() -> void:
	join_lobby(address.text.to_int())

func _on_addres_entery_text_changed(new_text: String) -> void:
	join.disabled = (new_text.length() <= 0)
