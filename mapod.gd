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
@export var defaultSpeed = 1.0

# ----- public variables
var thrust_event_buffer
var rotate_event_buffer
var srv_thrust_event_buffer
var srv_rotate_event_buffer

# ----- private variables
var _speed = null

var _space = Vector3(0, 0, 0)
var _space_travelled = Vector3(0, 0, 0)
var inc = 0
var _lerp_weight = 1.1
var _thrust_enabled = true

var _rotate_y = 0
var _rotate_y_ado = 0
var _rotate_y_lerp_weight = 1.1
var rotate_y_inc = 0
var _rotate_x = 0
var _rotate_x_ado = 0
var _rotate_x_lerp_weight = 1.1
var rotate_x_inc = 0
var _rotate_enabled = true

# ----- onready variables
@onready var _camera = $Camera3D



# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	thrust_event_buffer = MapodEventBuffer.new(1000)
	rotate_event_buffer = MapodEventBuffer.new(1000)
	srv_thrust_event_buffer = MapodEventBuffer.new(1000)
	srv_rotate_event_buffer = MapodEventBuffer.new(1000)

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.


func _physics_process(_delta):
	# travels space in (1/_lerp_weight) * 0.016667 s
	# _lerp_weight=0.05 travels 333,34 ms
	if _lerp_weight <= 1.0:
		_lerp_weight += 0.05
		var space_lerp = Vector3(0, 0, 0).lerp(_space, _lerp_weight)
		var space_step = space_lerp - _space_travelled
		_space_travelled += space_step
		#print(str(inc) + " space_lerp " + str(space_lerp));
		#print(str(inc) + " _lerp_weight " + str(_lerp_weight));
		#print(str(inc) + " space_step " + str(space_step));
		#print(str(inc) + " _space " + str(_space));
		#print(str(inc) + " _space_travelled " + str(_space_travelled));
		inc += 1
		move_and_collide(space_step)
		if _lerp_weight >= 1.0: # it's a float
			#print("arrivato " + str(position))
			pass
	else:
		_thrust_enabled = true
		call_deferred("_next_thrust_envent")
	
	if _rotate_y_lerp_weight <= 1.0:
		_rotate_y_lerp_weight += 0.05
		var rotate_y_lerp = lerp(0.0, _rotate_y, _rotate_y_lerp_weight)
		var rotate_y_step = rotate_y_lerp - _rotate_y_ado
		_rotate_y_ado += rotate_y_step
		rotate_y_inc += 1
		rotate_y(rotate_y_step)
		if _rotate_y_lerp_weight > 1.0:
			pass
			#print("ruotato y " + str(rotation))
	elif _rotate_x_lerp_weight <= 1.0:
		_rotate_x_lerp_weight += 0.05
		var rotate_x_lerp = lerp(0.0, _rotate_x, _rotate_x_lerp_weight)
		var rotate_x_step = rotate_x_lerp - _rotate_x_ado
		_rotate_x_ado += rotate_x_step
		rotate_x_inc += 1
		_camera.rotate_x(rotate_x_step)
		if _rotate_x_lerp_weight > 1.0:
			pass
			#print("ruotato x " + str(_camera.rotation))
	else:
		_rotate_enabled = true
		call_deferred("_next_rotate_envent")


# ----- public methods
func can_rotate():
	return _rotate_enabled


func mapod_rotate(rotate_vector: Vector2):
	#rotate_y(rotate_vector.y)
	#_camera.rotate_x(rotate_vector.x)
	#rotate_y(-event.relative.x * mouse_sensitivity)
	#_camera.rotate_x(-rotate_vector.x * mouse_sensitivity)
	if _rotate_enabled == true:
		if rotate_vector.y != 0:
			_rotate_y = rotate_vector.y
			_rotate_y_lerp_weight = 0.0
			_rotate_y_ado = 0.0
			_rotate_enabled = false
		elif rotate_vector.x != 0:
			_rotate_x = rotate_vector.x
			_rotate_x_lerp_weight = 0.0
			_rotate_x_ado = 0.0
			_rotate_enabled = false


func can_thrust():
	return _thrust_enabled


func mapod_thrust(speed: Vector3):
	var thrust_time = 0.4
	if thrust_time != 0:
		if _thrust_enabled == true:
			_thrust_enabled = false
			_speed = transform.basis * speed * defaultSpeed
			_space = _speed * thrust_time
			_space_travelled = Vector3(0.0, 0.0, 0.0)
			inc = 0
			#print(_space + " " + position)
			_lerp_weight = 0
		
	
#func fw_thrust():
	#var delta = get_physics_process_delta_time()
	##linear_velocity.z += (acceleration * delta)
	#if _move_enabled == true:
		#_move_enabled = false
		#_speed = transform.basis * Vector3(0, 0, 30.0)
		#print("velocity " + str(_speed))
		#_space = _speed * delta
		#_space_travelled = Vector3(0.0, 0.0, 0.0)
		#inc = 0
		#_lerp_weight = 0
		#print("_space " + str(_space))
		#
#
#
#func bk_thrust():
	#var delta = get_physics_process_delta_time()
	##linear_velocity.z += (-acceleration * delta)
	#if _move_enabled == true:
		#_move_enabled = false
		#_speed = transform.basis * Vector3(0, 0, -15.0)
		#print("velocity " + str(_speed))
		#_space = _speed * delta
		#_space_travelled = Vector3(0.0, 0.0, 0.0)
		#inc = 0
		#_lerp_weight = 0
		#print("_space " + str(_space))
#
#
#func lf_thrust():
	#var delta = get_physics_process_delta_time()
	##linear_velocity.x += (acceleration * delta)
	#if _move_enabled == true:
		#_move_enabled = false
		#_speed = transform.basis * Vector3(15.0, 0, 0)
		#print("speed " + str(_speed))
		#_space = _speed * delta
		#_space_travelled = Vector3(0.0, 0.0, 0.0)
		#inc = 0
		#_lerp_weight = 0
		#print("_space " + str(_space))
#
#
#func rg_thrust():
	#var delta = get_physics_process_delta_time()
	##linear_velocity.x += (-acceleration * delta)
	#if _move_enabled == true:
		#_move_enabled = false
		#_speed = transform.basis * Vector3(-15.0, 0, 0)
		#print("speed " + str(_speed))
		#_space = _speed * delta
		#_space_travelled = Vector3(0.0, 0.0, 0.0)
		#inc = 0
		#_lerp_weight = 0
		#print("_space " + str(_space))
#
#
#func up_thrust():
	#var delta = get_physics_process_delta_time()
	##linear_velocity.y += (acceleration * delta)
#
#
#func dw_thrust():
	#var delta = get_physics_process_delta_time()
	##linear_velocity.y += (-acceleration * delta)


# ----- private methods

func _next_thrust_envent():
	if !thrust_event_buffer.is_empty():
		var current_event = thrust_event_buffer.get_event()
		var data_input = MPEventBuilder.gain_input(current_event)
		mapod_thrust(data_input.v.d)
		print(current_event)


func _next_rotate_envent():
	if !rotate_event_buffer.is_empty():
		var current_event = rotate_event_buffer.get_event()
		mapod_rotate(current_event.input)
		print(current_event)



