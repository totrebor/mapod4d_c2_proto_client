# tool

# class_name

# extends
extends CharacterBody3D

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:            http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com


# ----- signals

# ----- enums

# ----- constants

# ----- exported variables
@export var mouse_sensitivity = 0.01
@export var defaultSpeed = 30.0

# ----- public variables


# ----- private variables
var _speed = null
#var _camera = $Camera3D


# ----- onready variables
#@onready var _camera = $Camera3D

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.



var _space = Vector3(0, 0, 0)
var _space_travelled = Vector3(0, 0, 0)
var inc = 0
var _lerp_weight = 1.1
var _move_enabled = true

var _rotate_y = 0
var _rotare_ado = 0
var _rotate_lerp_weight = 1.1
var rotate_inc = 0

func _physics_process(delta):
	# travels space in (1/_lerp_weight) * 0.016667 s
	# _lerp_weight=0.05 travels 333,34 ms
	if _lerp_weight <= 1.0:
		_lerp_weight += 0.05
		var space_lerp = Vector3(0, 0, 0).lerp(_space, _lerp_weight)
		var space_step = space_lerp - _space_travelled
		_space_travelled += space_step
		print(str(inc) + " space_lerp " + str(space_lerp));
		print(str(inc) + " _lerp_weight " + str(_lerp_weight));
		print(str(inc) + " space_step " + str(space_step));
		print(str(inc) + " _space " + str(_space));
		print(str(inc) + " _space_travelled " + str(_space_travelled));
		inc += 1
		move_and_collide(space_step)
	else:
		_move_enabled = true
	
	if _rotate_lerp_weight <= 1.1:
		_rotate_lerp_weight += 0.05
		_rotate_lerp_weight += 5
		rotate_inc += 1
		rotate_y(_rotate_y)


# ----- public methods
func mapod_rotate(rotate_vector: Vector2):
	#rotate_y(rotate_vector.y)
	_rotate_y = rotate_vector.y

	#_camera.rotate_x(rotate_vector.x)
	#rotate_y(-event.relative.x * mouse_sensitivity)
	#_camera.rotate_x(-rotate_vector.x * mouse_sensitivity)
	_rotate_lerp_weight = 0.0


func mapod_thrust(speed: Vector3):
	var delta = get_physics_process_delta_time()
	if delta != 0:
		if _move_enabled == true:
			_move_enabled = false
			_speed = transform.basis * speed * defaultSpeed
			_space = _speed * delta
			_space_travelled = Vector3(0.0, 0.0, 0.0)
			inc = 0
			_lerp_weight = 0
		
	
func fw_thrust():
	var delta = get_physics_process_delta_time()
	#linear_velocity.z += (acceleration * delta)
	if _move_enabled == true:
		_move_enabled = false
		_speed = transform.basis * Vector3(0, 0, 30.0)
		print("velocity " + str(_speed))
		_space = _speed * delta
		_space_travelled = Vector3(0.0, 0.0, 0.0)
		inc = 0
		_lerp_weight = 0
		print("_space " + str(_space))
		


func bk_thrust():
	var delta = get_physics_process_delta_time()
	#linear_velocity.z += (-acceleration * delta)
	if _move_enabled == true:
		_move_enabled = false
		_speed = transform.basis * Vector3(0, 0, -15.0)
		print("velocity " + str(_speed))
		_space = _speed * delta
		_space_travelled = Vector3(0.0, 0.0, 0.0)
		inc = 0
		_lerp_weight = 0
		print("_space " + str(_space))


func lf_thrust():
	var delta = get_physics_process_delta_time()
	#linear_velocity.x += (acceleration * delta)
	if _move_enabled == true:
		_move_enabled = false
		_speed = transform.basis * Vector3(15.0, 0, 0)
		print("speed " + str(_speed))
		_space = _speed * delta
		_space_travelled = Vector3(0.0, 0.0, 0.0)
		inc = 0
		_lerp_weight = 0
		print("_space " + str(_space))


func rg_thrust():
	var delta = get_physics_process_delta_time()
	#linear_velocity.x += (-acceleration * delta)
	if _move_enabled == true:
		_move_enabled = false
		_speed = transform.basis * Vector3(-15.0, 0, 0)
		print("speed " + str(_speed))
		_space = _speed * delta
		_space_travelled = Vector3(0.0, 0.0, 0.0)
		inc = 0
		_lerp_weight = 0
		print("_space " + str(_space))


func up_thrust():
	var delta = get_physics_process_delta_time()
	#linear_velocity.y += (acceleration * delta)


func dw_thrust():
	var delta = get_physics_process_delta_time()
	#linear_velocity.y += (-acceleration * delta)


# ----- private methods





