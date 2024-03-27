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
var multiplayer_peer = ENetMultiplayerPeer.new()
var player_scene = preload("res://player.tscn")
var _player_node = ""

var sync_timer = null
var server_ticks_delta = 0

# ----- private variables
var _peer_id = null
var _auth_token = null
var _latency_queue = []
var latency = 0.0
var latency_variance = 0.0


# ----- onready variables

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer_peer.get_peer(1).set_timeout(0, 0, 3000)  # 3 seconds max timeout
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


# ----- remaining built-in virtual methods

func _physics_process(delta):
	pass # Replace with function body.


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#if event.is_action_pressed("mapod_a"):
		#send_event.rpc_id(1, {
			#"T": Time.get_ticks_msec() + server_ticks_delta,
			#"peer_id": _peer_id
		#})
	pass


# ----- public methods

## server connected
@rpc("authority", "unreliable")
func server_name(peer_id, remote_server_name):
	print("peer_id " + str(peer_id) + " " + remote_server_name)
	_peer_id = peer_id
	user_auth_request.rpc_id(1, peer_id, "login", "password")


## authentication
@rpc("any_peer", "call_remote")
func user_auth_request(peer_id, _login, _password):
	pass


## authentication response error
@rpc("authority", "call_remote")
func auth_error(peer_id):
	print("auth ERROR " + str(peer_id))


## authentication response confirmed 
@rpc("authority", "call_remote")
func auth_confirmed(peer_id, auth_token):
	print("auth OK " + str(peer_id) + " " + auth_token)
	_auth_token = auth_token
	# request player instance
	start_game.rpc_id(1, _peer_id, _auth_token)


## start the game -> create player
@rpc("any_peer", "call_remote")
func start_game(peer_id, auth_token):
	pass


## receive ready to go
@rpc("authority", "call_remote")
func ready_to_go(peer_id):
	_player_node = "PlayerSpawnerArea/" + str(peer_id)
	var player_node = get_node(_player_node)
	player_node.player_event_requested.connect(_on_player_event_requested)
	if player_node.is_connected(
			"player_event_requested", _on_player_event_requested):
		print("sssssssssssssssss")
	#player_node.connect("player_event_requested", _on_player_event_requested)


## ticks sync request
@rpc("any_peer", "call_remote")
func ticks_sync_request(peer_id):
	# defined in the server
	pass


## ticks sync answer
@rpc("authority", "call_remote")
func ticks_sync(server_ticks):
	var client_ticks = Time.get_ticks_msec()
	server_ticks += _get_rtt()
	#print("before  d " + 
			#str(server_ticks_delta) + 
			#" c+d " + str(client_ticks + server_ticks_delta) + 
			#" s " + str(server_ticks) +
			#" diff " + str(server_ticks - (client_ticks + server_ticks_delta))
	#)
	server_ticks_delta =  server_ticks - client_ticks
	#print("after d " + str(server_ticks_delta))
	

@rpc("any_peer",  "call_remote", "reliable")
func send_player_event(peer_id, event):
	# defined in the server
	pass


# ----- private methods
func _on_connected_to_server():
	print("Connection OK!")
	_peer_id = null
	_on_sync_ticks
	sync_timer = Timer.new()
	add_child(sync_timer)
	sync_timer.timeout.connect(_on_sync_ticks)
	sync_timer.start(0.25)


func _on_connection_failed():
	print("Connection ERROR!")
	_peer_id = null
	$PlayerSpawnerArea.local_spawn()


func _get_rtt():
	var server_connection = multiplayer.multiplayer_peer.get_peer(1)
	if server_connection != null:
		latency = server_connection.get_statistic(
					ENetPacketPeer.PEER_ROUND_TRIP_TIME) / 2
		latency_variance = server_connection.get_statistic(
					ENetPacketPeer.PEER_ROUND_TRIP_TIME_VARIANCE)
	#print("latency " + str(latency) + " latency_variance " + str(latency_variance))
	_latency_queue.push_back(latency)
	if len(_latency_queue) > 9:
		_latency_queue.pop_front()
		latency = _latency_queue[4]
	return latency


func _on_sync_ticks():
	#print("start _on_sync_ticks")
	if _peer_id != null:
		#print("request _on_sync_ticks")
		ticks_sync_request.rpc_id(1, _peer_id)
	#print("end _on_sync_ticks")


func _on_player_event_requested(event):
	print("_on_player_event_requested")
	if _peer_id != null:
		event.peer_id = _peer_id
		send_player_event(_peer_id, event)
