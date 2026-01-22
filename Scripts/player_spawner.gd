extends MultiplayerSpawner

@export var PlayerScene : PackedScene

var Players = {}

func _ready() -> void:
	spawn_function = spawn_player
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(remove_player)
		call_deferred("spawn_host")

func spawn_host():
	if is_multiplayer_authority():
		spawn(1)

func spawn_player(data):
	print(data)
	var p = PlayerScene.instantiate()
	p.set_multiplayer_authority(data)
	Players[data] = p
	return p

func remove_player(data):
	Players[data].queue_free()
	Players.erase(data)


func _process(delta: float) -> void:
	pass
