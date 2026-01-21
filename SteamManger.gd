extends Node

var SteamAppID : int = 480
var SteamUserName : String = ""
var Steam_ID : int = 0 

var isLobbyHost : bool
var Lobby_ID : int
var LobbyMembers: Array

var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()


func _init() -> void:
	OS.set_environment("SteamAppId", str(SteamAppID))
	OS.set_environment("SteamGameId", str(SteamAppID))

func  _ready() -> void:
	Steam.steamInitEx()
	
	Steam_ID = Steam.getSteamID()
	
	SteamUserName = Steam.getPersonaName()
	print(SteamUserName)
	
	

func _process(delta: float) -> void:
	Steam.run_callbacks()
