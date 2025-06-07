extends Node3D

@export var Door : Node3D 

func Interact(PlayerRef): 
	DoorOpen.rpc()

@rpc("any_peer","call_local")
func DoorOpen():
	Door.isLocked = false
