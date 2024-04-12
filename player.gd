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
signal player_event_requested(event)

# ----- enums
enum PLAYER_EVENT_ACTION {
	FW_THRUST = 0,
	BK_THRUST,
}

# ----- constants

# ----- exported variables

# ----- public variables

# ----- private variables
var _player_event = {
	'T': 0.0,
	'action': PLAYER_EVENT_ACTION.FW_THRUST,
	'data': '',
}

# ----- onready variables
@onready var _mapod = $Mapod
@onready var _camera = $Mapod/Camera3D

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var sync_timer = Timer.new()
	add_child(sync_timer)
	#sync_timer.timeout.connect(func():
		#_player_event.action = PLAYER_EVENT_ACTION.FW_THRUST
		#emit_signal("player_event_requested", _player_event)
	#)
	#sync_timer.start(1)
	

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.


func _unhandled_input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var move_vec = Vector3(
			float(Input.is_action_pressed("mapod_a")) * 1.0 +
			float(Input.is_action_pressed("mapod_d")) * -1.0,
			float(Input.is_action_pressed("mapod_q")) * 1.0 +
			float(Input.is_action_pressed("mapod_space")) * -1.0,
			float(Input.is_action_pressed("mapod_w")) * 1.0 +
			float(Input.is_action_pressed("mapod_s")) * -1.0
		)
		var rotate_vec = Vector2(
			0.0,
			float(Input.is_action_pressed("mapod_rotate_r")) * 0.1 * PI +
			float(Input.is_action_pressed("mapod_rotate_l")) * 0.1 * -PI
		)
		
		if move_vec.length() != 0:
			_mapod.mapod_thrust(move_vec)
		if rotate_vec.length() != 0:
			_mapod.mapod_rotate(rotate_vec)
		
		#if Input.is_action_pressed("mapod_w"):
			#print("FW")
			#_mapod.mapod_thrust(Vector3(0, 0, 1))
			#_player_event.action = PLAYER_EVENT_ACTION.FW_THRUST
			#emit_signal("player_event_requested", _player_event)
		#elif Input.is_action_pressed("mapod_s"):
			#print("BK")
			#_mapod.mapod_thrust(Vector3(0, 0, -1))
			#_player_event.action = PLAYER_EVENT_ACTION.BK_THRUST
			#emit_signal("player_event_requested", _player_event)
		#elif Input.is_action_pressed("mapod_a"):
			#print("LF")
			#_mapod.mapod_thrust(Vector3(1, 0, 0))
		#elif Input.is_action_pressed("mapod_d"):
			#print("RG")
			#_mapod.mapod_thrust(Vector3(-1, 0, 0))

			
		if event is InputEventMouseMotion:
			#rotate_y(-event.relative.x * mouse_sensitivity)
			#$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
			#$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
			var rotate_vector: Vector2 = Vector2(0, 0)
			if event.relative.y > 0:
				rotate_vector.x = 1
			else:
				rotate_vector.x = -1
			_mapod.mapod_rotate(rotate_vector)


func _physics_process(_delta):
	pass


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
	var position = _position["position"]
	var _mapod_tween = $Mapod.create_tween()
	_mapod_tween.tween_property(
			_mapod, "position", _position["position"], 0.08)
	# OK _mapod.position = _position["position"]

# ----- private methods





