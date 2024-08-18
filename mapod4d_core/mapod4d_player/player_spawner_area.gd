# tool

# class_name

# extends
extends Marker3D

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
@export var players_scene = preload("res://mapod4d_core/mapod4d_player/player.tscn")

# ----- public variables
var local_player = null

# ----- private variables

# ----- onready variables


# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	#await(get_tree().create_timer(0.1).timeout)
	#for i in range(0, multiplayer.get_peers().size()):
		#var player = players_scene.instantiate()
		#var player_id = multiplayer.get_peers()[i]
		#player.name = str(player_id)
		#add_child(player)
		#await(get_tree().create_timer(0.1).timeout)
		#player.rpc("setup_multiplayer", player_id)
	pass

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.

# ----- public methods
func remote_spawn():
	await(get_tree().create_timer(0.1).timeout)

func local_spawn():
	local_player = players_scene.instantiate()
	local_player.name = "MapodAvatar"
	add_child(local_player)


func get_local_player():
	return local_player

# ----- private methods
