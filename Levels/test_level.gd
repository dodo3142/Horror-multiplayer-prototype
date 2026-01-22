extends Node3D

@onready var lobbies_list: VBoxContainer = %LobbiesList
@onready var multiplayer_ui: CanvasLayer = $CanvasLayer
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var lobby_id_text: LineEdit = $CanvasLayer/SteamMulti/MarginContainer/VBoxContainer/AddresEntery

var lobby_ID : int = 0

var lobby_created : bool = false

var peer : SteamMultiplayerPeer

func _ready() -> void:
	peer =  SteamManger.peer
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)



func _process(delta: float) -> void:
	pass

func _on_host_button_pressed() -> void:
	if lobby_created:
		return
	
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC,3)
	

func _on_join_button_pressed() -> void:
	join_lobby(int(lobby_id_text.text))

func _on_refresh_lobbies_pressed() -> void:
	var lobbies_btn = lobbies_list.get_children()
	for i in lobbies_btn:
		i.queue_free()
	
	open_lobby_list()



func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _on_lobby_created(connect: int, _lobby_id: int):
	if connect:
		lobby_ID = _lobby_id
		Steam.setLobbyData(lobby_ID,"name",str(SteamManger.SteamUserName + "'s Lobby"))
		Steam.setLobbyJoinable(lobby_ID,true)
		
		SteamManger.Lobby_ID = lobby_ID
		SteamManger.isLobbyHost = true
		print(lobby_ID)
		hide_menu()
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		player_spawner.spawn_host()


func _on_lobby_match_list(lobbies: Array):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby,"name")
		var mebers_count = Steam.getNumLobbyMembers(lobby)
		var max_players = Steam.getLobbyMemberLimit(lobby)
		
		var btn = Button.new()
		btn.text = "{0} | {1}/{2}".format([lobby_name,mebers_count,max_players])
		btn.set_size(Vector2(40,100))
		
		btn.pressed.connect(join_lobby.bind(lobby))
		lobbies_list.add_child(btn)

func join_lobby(_Lobby_id):
	Steam.joinLobby(_Lobby_id)
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	multiplayer.multiplayer_peer = peer
	player_spawner.spawn(SteamManger.Steam_ID)
	hide_menu()

func hide_menu():
	multiplayer_ui.hide()
