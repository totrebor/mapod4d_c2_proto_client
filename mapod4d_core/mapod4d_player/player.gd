# tool

# class_name

# extends
extends Node3D

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:            http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com


# ----- signals
signal player_event_requested(player_object, event)

# ----- enums
enum PLAYER_EVENT_ACTION {
	FW_THRUST = 0,
	BK_THRUST,
}

# ----- constants

# ----- exported variables

# ----- public variables

# ----- private variables

# movement values
var _mp_mv_left = 0
var _mp_mv_right = 0
var _mp_mv_forward = 0
var _mp_mv_backward = 0
var _mp_mv_up = 0
var _mp_mv_down = 0

# rotate values
var _mp_rt_up = 0
var _mp_rt_down = 0
var _mp_rt_left = 0
var _mp_rt_right = 0

# ----- onready variables
@onready var _mapod = $Mapod
@onready var _camera = $Mapod/Camera3D

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	#var sync_timer = Timer.new()
	#add_child(sync_timer)
	#sync_timer.timeout.connect(func():
		#_player_event.action = PLAYER_EVENT_ACTION.FW_THRUST
		#emit_signal("player_event_requested", _player_event)
	#)
	#sync_timer.start(1)
	#var input_timer = Timer.new()
	#add_child(input_timer)
	#input_timer.timeout.connect(_mapod_elab_input)
	#input_timer.start(0.1)
	

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.


func _unhandled_input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("mapod_a"):
			_mp_mv_left = 1
		elif event.is_action_released("mapod_a"):
			_mp_mv_left = 0

		elif event.is_action_pressed("mapod_d"):
			_mp_mv_right = 1
		elif event.is_action_released("mapod_d"):
			_mp_mv_right = 0

		elif event.is_action_pressed("mapod_q"):
			_mp_mv_up = 1
		elif event.is_action_released("mapod_q"):
			_mp_mv_up = 0

		elif event.is_action_pressed("mapod_space"):
			_mp_mv_down = 1
		elif event.is_action_released("mapod_space"):
			_mp_mv_down = 0

		elif event.is_action_pressed("mapod_w"):
			_mp_mv_forward = 1
		elif event.is_action_released("mapod_w"):
			_mp_mv_forward = 0

		elif event.is_action_pressed("mapod_s"):
			_mp_mv_backward = 1
		elif event.is_action_released("mapod_s"):
			_mp_mv_backward = 0

		elif event.is_action_pressed("mapod_rotate_u"):
			_mp_rt_up = 1
		elif event.is_action_released("mapod_rotate_u"):
			_mp_rt_up = 0

		#var move_vec = Vector3(
			#float(event.is_action_pressed("mapod_a")) * 1.0 +
			#float(event.is_action_pressed("mapod_d")) * -1.0,
			#float(event.is_action_pressed("mapod_q")) * 1.0 +
			#float(event.is_action_pressed("mapod_space")) * -1.0,
			#float(event.is_action_pressed("mapod_w")) * 1.0 +
			#float(event.is_action_pressed("mapod_s")) * -1.0
		#)
		
		elif event.is_action_pressed("mapod_rotate_d"):
			_mp_rt_down = 1
		elif event.is_action_released("mapod_rotate_d"):
			_mp_rt_down = 0

		elif event.is_action_pressed("mapod_rotate_r"):
			_mp_rt_right = 1
		elif event.is_action_released("mapod_rotate_r"):
			_mp_rt_right = 0

		elif event.is_action_pressed("mapod_rotate_l"):
			_mp_rt_left = 1
		elif event.is_action_released("mapod_rotate_l"):
			_mp_rt_left = 0

		#var rotate_vec = Vector2(
			#float(event.is_action_pressed("mapod_rotate_u")) * 0.05 * PI +
			#float(event.is_action_pressed("mapod_rotate_d")) * 0.05 * -PI,
			#float(event.is_action_pressed("mapod_rotate_r")) * 0.05 * -PI +
			#float(event.is_action_pressed("mapod_rotate_l")) * 0.05 * PI
		#)
		
		#if move_vec.length() != 0:
		#	_mapod.mapod_thrust(move_vec)
		#if rotate_vec.length() != 0:
			#_mapod.mapod_rotate(rotate_vec)
		#_mapod_elab_input()
		
		if event is InputEventMouseMotion:
			pass
			#var rotate_vector: Vector2 = Vector2(0, 0)
			#if event.relative.y > 0:
				#rotate_vector.x = 1
			#else:
				#rotate_vector.x = -1
			#_mapod.mapod_rotate(rotate_vector)


func _physics_process(_delta):
	_mapod_elab_input()


# ----- public methods
@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	#set_multiplayer_authority(player_id)
	var is_player = player_id == multiplayer.get_unique_id()
	print("setup_multiplayer io " + str(is_player) + " " + str(player_id))
	_camera.current = is_player
	set_physics_process(is_player)
	set_process_unhandled_input(is_player)
	#label.text = "P%s" % get_index()


#@rpc("any_peer", "call_remote")
#func fw_thrust(player_name):
	#pass


#@rpc("any_peer", "call_remote")
#func bk_thrust(player_name):
	#pass

func set_mapod_position(_position):
	print("set_mapod_position")
	#var position = _position["position"]
	var _mapod_tween = $Mapod.create_tween()
	_mapod_tween.tween_property(
			_mapod, "position", _position["position"], 0.08)
	# OK _mapod.position = _position["position"]


func push_thrust_event(mp_event):
	_mapod.thrust_event_buffer.push_c(mp_event, 0)
	pass


func push_rotate_event(mp_event):
	_mapod.rotate_event_buffer.push_c(mp_event, 0)
	pass


func push_confirm_thrust_event(mp_event):
	print("push_confirm_thrust_event ", mp_event)
	_mapod.confirmed_thrust_event_buffer.push_unc(mp_event)


func push_confirm_rotate_event(mp_event):
	print("push_confirm_rotate_event ", mp_event)
	_mapod.confirmed_rotate_event_buffer.push_unc(mp_event)


# ----- private methods

func _mapod_elab_input():
	var move_vec = Vector3(
		_mp_mv_left * 1.0 + _mp_mv_right * -1.0,
		_mp_mv_up * 1.0 + _mp_mv_down * -1.0,
		_mp_mv_forward * 1.0 + _mp_mv_backward * -1.0,
	)
	var rotate_vec = Vector2(
			_mp_rt_up * 0.05 * PI + _mp_rt_down * 0.05 * -PI,
			_mp_rt_right * 0.05 * -PI + _mp_rt_left * 0.05 * PI
		)
	if move_vec.length() != 0:
		call_deferred("_mapod_thrust", move_vec)
	if rotate_vec.length() != 0:
		call_deferred("_mapod_rotate",rotate_vec)


func _mapod_thrust(move_vec):
	if _mapod.can_thrust():
		var mp_event = MPEventBuilder.build_drone_thrust(move_vec)
		# servirebbe il server time qui
		_player_event_request(self, mp_event)
		#_mapod.thrust_event_buffer.push(mp_event, 0)


func _mapod_rotate(rotate_vec):
	if _mapod.can_rotate():
		var mp_event = MPEventBuilder.build_drone_rotate(rotate_vec)
		# servirebbe il server time qui
		_player_event_request(self, mp_event)
		#_mapod.rotate_event_buffer.push_unc(mp_event)


func _player_event_request(player_object, mp_event):
	player_event_requested.emit(player_object, mp_event)
	# from server simulation (debug only)
	#var me = event["ME"]
	#if me == "thrust":
		#pass
	#elif me == "rotate":
		#pass
