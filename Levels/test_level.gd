extends Node3D

@onready var lobbies_list: VBoxContainer = %LobbiesList
@onready var multiplayer_ui: CanvasLayer = $CanvasLayer
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var lobby_id_text: LineEdit = $CanvasLayer/SteamMulti/MarginContainer/VBoxContainer/AddresEntery

@export var player_scene : PackedScene
@export var spawn_loc : Node3D

var lobby_ID : int = 0

var lobby_created : bool = false

var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()

func _ready() -> void:
	Steam.lobby_created.connect(_on_lobby_created.bind())

func become_host():
	print("Starting host!")
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 4)

func join_as_client(lobby_id):
	print("Joining lobby %s" % lobby_id)
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.joinLobby(int(lobby_id))

func _on_lobby_created(connect: int, lobby_id):
	print("On lobby created")
	if connect == 1:
		lobby_ID = lobby_id
		print("Created lobby: %s" % lobby_ID)
		
		Steam.setLobbyJoinable(lobby_ID, true)
		
		Steam.setLobbyData(lobby_ID, "name", "Lol123")
		
		_create_host()

func _create_host():
	print("Create Host")
	
	var error = peer.create_host(0)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		
		if not OS.has_feature("dedicated_server"):
			_add_player_to_game(1)
	else:
		print("error creating host: %s" % str(error))

func _on_lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
	print("On lobby joined: %s" % response)
	
	if response == 1:
		var id = Steam.getLobbyOwner(lobby)
		if id != Steam.getSteamID():
			print("Connecting client to socket...")
			connect_socket(id)
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			2:  FAIL_REASON = "This lobby no longer exists."
			3:  FAIL_REASON = "You don't have permission to join this lobby."
			4:  FAIL_REASON = "The lobby is now full."
			5:  FAIL_REASON = "Uh... something unexpected happened!"
			6:  FAIL_REASON = "You are banned from this lobby."
			7:  FAIL_REASON = "You cannot join due to having a limited account."
			8:  FAIL_REASON = "This lobby is locked or disabled."
			9:  FAIL_REASON = "This lobby is community locked."
			10: FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: FAIL_REASON = "A user you have blocked is in the lobby."
		print(FAIL_REASON)

func connect_socket(steam_id: int):
	var error = peer.create_client(steam_id, 0)
	if error == OK:
		print("Connecting peer to host...")
		multiplayer.set_multiplayer_peer(peer)
	else:
		print("Error creating client: %s" % str(error))

func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	Steam.requestLobbyList()

func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	
	var player_to_add = player_scene.instantiate()
	player_to_add.set_multiplayer_authority(id)
	player_to_add.name = str(id)
	
	spawn_loc.add_child(player_to_add, true)

func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not spawn_loc.has_node(str(id)):
		return
	spawn_loc.get_node(str(id)).queue_free()


func _on_host_button_pressed() -> void:
	become_host()
	$CanvasLayer/SteamMulti.visible = false

func _on_join_button_pressed() -> void:
	join_as_client(int(lobby_id_text.text))
	$CanvasLayer/SteamMulti.visible = false

func _on_refresh_lobbies_pressed() -> void:
	list_lobbies()
	$CanvasLayer/SteamMulti.visible = false
