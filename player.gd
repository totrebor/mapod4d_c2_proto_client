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

# ----- enums

# ----- constants

# ----- exported variables

# ----- public variables

# ----- private variables

# ----- onready variables
@onready var _mapod = $Mapod
@onready var _camera = $Mapod/Camera3D

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.


func _unhandled_input(event):
	pass
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
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
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_pressed("mapod_w"):
			if multiplayer.get_peers().size() > 0:
				#rpc_id(1, "fw_thrust", name)
				fw_thrust.rpc_id(1, name)
			else:
				_mapod.fw_thrust()
		if Input.is_action_pressed("mapod_s"):
			if multiplayer.get_peers().size() > 0:
				rpc_id(1, "bk_thrust", name)
			else:
				_mapod.bk_thrust()
		if Input.is_action_pressed("mapod_a"):
			_mapod.lf_thrust()
		if Input.is_action_pressed("mapod_d"):
			_mapod.rg_thrust()
		if Input.is_action_pressed("mapod_q"):
			_mapod.up_thrust()
		if Input.is_action_pressed("mapod_space"):
			_mapod.dw_thrust()


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


@rpc("any_peer", "call_remote")
func fw_thrust(player_name):
	pass


@rpc("any_peer", "call_remote")
func bk_thrust(player_name):
	pass

# ----- private methods





