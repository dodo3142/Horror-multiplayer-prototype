extends Node3D

@onready var door_hing = $DoorHing

var  isOpen = false
@export var  isLocked = false
@export var NeedKey = false
@export var KeyForDoor : Node3D

func _ready():
	if NeedKey:
		isLocked = NeedKey

func Interact(PlayerRef): 
	if isLocked == true and NeedKey:
		if !is_instance_valid(KeyForDoor):
			isLocked = false
			DoorOpening.rpc()
		else:
			$AnimationPlayer.play("Locked")
			PlayerRef.HintTextUpdate("You Need Door Key")
	elif isLocked:
			$AnimationPlayer.play("Locked")
			PlayerRef.HintTextUpdate("locked")
	elif isLocked == false:
		DoorOpening.rpc()


@rpc("any_peer","call_local")
func DoorOpening():
	if isOpen == false:
		$AnimationPlayer.play("Open")
		isOpen = true
	else:
		$AnimationPlayer.play_backwards("Open")
		isOpen = false
