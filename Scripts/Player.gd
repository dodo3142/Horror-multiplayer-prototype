extends CharacterBody3D

@export var PlayerName : String  = "TAITOKI"
@export var Steam_Id : int = 0


var CurrentSpeed = 5
@export var WalkSpeed = 5
@export var SprintSpeed = 9
@export var JumpForce = 5
@export var Accleration = .9
@export var Decleration = .6
@export var graity = 25

@export var MouseSenstivity = 0.2
@export var HeadBobFreq = 2
@export var HeadBobAMP =0.08
var t_bob = 0

var MoveDir = Vector3.ZERO
var InputDir = Vector3.ZERO

var MouseLock = true

@onready var PlayerMesh = $PlayerMesh
@onready var PlayerHead = $Head
@onready var PlayerCamera = $Head/Camera3D
@onready var FlashLight = $Head/Camera3D/FlashLight
@onready var InteractRay = $Head/Camera3D/InteractRay
@onready var HintText = $UI/HintText
@onready var Name: Label3D = $Name

func _enter_tree():
	pass

func _ready():
	if not is_multiplayer_authority(): return
	PlayerMesh.visible = false
	Name.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerCamera.current = true

func _process(delta):
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("FlashLight"):
		if FlashLight.visible == true:
			FlashLight.visible = false
		else:
			FlashLight.visible = true
	
	if Input.is_action_just_pressed("Exit"):
		if MouseLock == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			MouseLock = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			MouseLock = true
	
	
	#HeadBobing
	t_bob += delta * velocity.length() * float(is_on_floor())
	PlayerCamera.transform.origin = HeadBob(t_bob)
	
	PlayerInteract()
	Movement(delta)
	
	move_and_slide()

func HeadBob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * HeadBobFreq) * HeadBobAMP
	#pos.x = sin(time * HeadBobFreq/2) * HeadBobAMP
	return pos

func Movement(delta):
	if not is_on_floor():
		velocity.y -= graity * delta 
	
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JumpForce
	
	
	if Input.is_action_pressed("Sprint"):
		CurrentSpeed = SprintSpeed
	else:
		CurrentSpeed = WalkSpeed
	
	InputDir = Input.get_vector("MoveLeft","MoveRight","MoveForward","MoveBackWard")
	MoveDir = (transform.basis * Vector3(InputDir.x,0,InputDir.y)).normalized()
	
	if MoveDir:
		velocity.x = move_toward(velocity.x, MoveDir.x * CurrentSpeed, Accleration)
		velocity.z = move_toward(velocity.z, MoveDir.z * CurrentSpeed, Accleration)
	else:
		velocity.x = move_toward(velocity.x, 0, Decleration)
		velocity.z = move_toward(velocity.z, 0, Decleration)

func _input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MouseSenstivity))
		PlayerHead.rotate_x(deg_to_rad(-event.relative.y * MouseSenstivity))
		PlayerHead.rotation_degrees.x = clamp(PlayerHead.rotation_degrees.x,-89,89)

func PlayerInteract():
	var tween = create_tween()
	if InteractRay.is_colliding():
		if InteractRay.get_collider() != null and InteractRay.get_collider().is_in_group("Interactable"):
			tween.tween_property($UI/CrossHair,"modulate", Color(1, 1, 1,1),0.2)
		else:
			tween.tween_property($UI/CrossHair,"modulate", Color(1, 1, 1, 0.3),0.2)
	else:
		tween.tween_property($UI/CrossHair,"modulate", Color(1, 1, 1, 0.3),0.2)
	
	if Input.is_action_just_pressed("Interact"):
		if InteractRay.is_colliding():
			if InteractRay.get_collider().is_in_group("Interactable"):
				InteractRay.get_collider().Interact(self)


func HintTextUpdate(Hint):
	HintText.text = Hint
	$Timers/HintTimer.start()


func _on_hint_timer_timeout():
	HintText.text = ""
