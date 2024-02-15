# tool

# class_name

# extends
extends RigidBody3D

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
@export var acceleration = 20.0
@export var mouse_sensitivity = 0.01

# ----- public variables

# ----- private variables


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


# ----- public methods
func mapod_rotate(_rotate_vector: Vector2):
	#rotate_y(-event.relative.x * mouse_sensitivity)
	#_camera.rotate_x(-rotate_vector.x * mouse_sensitivity)
	pass


func fw_thrust():
	var delta = get_physics_process_delta_time()
	linear_velocity.z += (acceleration * delta)


func bk_thrust():
	var delta = get_physics_process_delta_time()
	linear_velocity.z += (-acceleration * delta)


func lf_thrust():
	var delta = get_physics_process_delta_time()
	linear_velocity.x += (acceleration * delta)


func rg_thrust():
	var delta = get_physics_process_delta_time()
	linear_velocity.x += (-acceleration * delta)


func up_thrust():
	var delta = get_physics_process_delta_time()
	linear_velocity.y += (acceleration * delta)


func dw_thrust():
	var delta = get_physics_process_delta_time()
	linear_velocity.y += (-acceleration * delta)


# ----- private methods





