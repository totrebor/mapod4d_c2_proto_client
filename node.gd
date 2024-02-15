# tool

# class_name

# extends
extends Node

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:            http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com


# ----- signals

# ----- enums

# ----- constants
const ADDRESS = "localhost"
const PORT = 9999

# ----- exported variables

# ----- public variables
var peer = ENetMultiplayerPeer.new()
var player_scene = preload("res://player.tscn")

# ----- private variables

# ----- onready variables

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	peer.get_peer(1).set_timeout(0, 0, 3000)  # 3 seconds max timeout
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ----- public methods
@rpc
func server_name(remote_server_name):
	print(remote_server_name)


# ----- private methods
func _on_connected_to_server():
	print("Connection OK!")


func _on_connection_failed():
	print("Connection ERROR!")
	$PlayerSpawnerArea.local_spawn()



