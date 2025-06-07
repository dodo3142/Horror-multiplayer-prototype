extends Node3D


func Interact(PlayerRef): 
	KeyTake.rpc()

@rpc("any_peer","call_local")
func KeyTake():
	self.queue_free()
