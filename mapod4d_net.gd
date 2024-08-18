# tool

# class_name
class_name Mapod4dNet

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
const LATENCY_QUEUE_SIZE = 11

# ----- exported variables

# ----- public variables

# ----- private variables
var _playerSpawnerArea = null

# ----- onready variables private variables
@onready var _flag_started = false
@onready var _peer_id = null
@onready var _auth_token = null
@onready var _server_ticks_delta = 0
@onready var _sync_timer = null
## latency vars
@onready var _latency = 0.0
@onready var _latency_variance = 0.0
@onready var _latency_queue = []
@onready var _latency_queue_size: int = LATENCY_QUEUE_SIZE
@onready var _latency_decimal = 0.0
## sync time like ping
@onready var _ticks_sync_request_begin_time = 0
@onready var _ticks_sync_request_end_time = 10
## multiplayer connection
@onready var _network_error = false

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.


# ----- public methods
func start(playerSpawnerArea):
	_playerSpawnerArea = playerSpawnerArea
	if _latency_queue_size <= 3:
		_latency_queue_size = 3
	else:
		if _latency_queue_size % 2 == 0:
			_latency_queue_size += 1
	_flag_started = true


func connect_server(_login, _password):
	print("connect_server")
	if _flag_started:
		var multiplayer_peer = ENetMultiplayerPeer.new()
		if multiplayer_peer != null:
			if multiplayer_peer.create_client(ADDRESS, PORT) == OK:
				multiplayer.multiplayer_peer = multiplayer_peer
				var peer = multiplayer_peer.get_peer(1)
				if peer != null:
					## 3 seconds max timeout
					multiplayer_peer.get_peer(1).set_timeout(0, 0, 3000)
				var isc = multiplayer.connected_to_server.is_connected(
							_on_connected_to_server)
				if !isc:
					multiplayer.connected_to_server.connect(
							_on_connected_to_server)
				isc = multiplayer.connected_to_server.is_connected(
							_on_connection_failed)
				if !isc:
					multiplayer.connection_failed.connect(
							_on_connection_failed)
			else:
				_network_error = true
				call_deferred("connection_failed")


func disconnect_server():
	print("disconnect_server")
	if multiplayer.multiplayer_peer != null:
		multiplayer.connected_to_server.disconnect(_on_connected_to_server)
		multiplayer.connection_failed.disconnect(_on_connection_failed)
		multiplayer.multiplayer_peer.disconnect_peer(1)
		multiplayer.multiplayer_peer = null


## autenticantion client side
@rpc("authority", "call_remote", "unreliable")
func server_name(peer_id, remote_server_name):
	print("peer_id " + str(peer_id) + " " + remote_server_name)
	_peer_id = peer_id
	user_auth_request.rpc_id(1, peer_id, "login", "password")


## authentication
@rpc("any_peer", "call_remote")
func user_auth_request(_peer_id_rpc, _login, _password):
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
func start_game(_peer_id_rpc, _auth_token_rpc):
	pass


## receive ready to go
@rpc("authority", "call_remote")
func ready_to_go(peer_id):
	var player_node = _get_player_node_or_null(peer_id)
	if player_node != null:
		player_node.player_event_requested.connect(_on_player_event_requested)


## ticks sync request
@rpc("any_peer", "call_remote", "reliable")
func ticks_sync_request(_peer_id_rpc, _client_tick_rpc):
	# defined in the server
	pass


## ticks sync answer
@rpc("authority", "call_remote", "reliable")
func ticks_sync(client_tick, server_tick):
	_ticks_sync_request_begin_time = client_tick
	_ticks_sync_request_end_time = Time.get_ticks_msec()
	var latency = _get_latency()
	# update server_ticks_delta  
	server_tick += latency
	_server_ticks_delta =  server_tick - _ticks_sync_request_end_time
	#print("after d " + str(server_ticks_delta))


@rpc("any_peer", "call_remote", "reliable")
func send_player_event(_peer_id_rpc, _event_rpc):
	# defined in the server
	pass


## confirm an event to the remote player
@rpc("authority", "call_remote", "reliable")
func confirm_player_event(mp_event):
	print("confirm_player_event ", mp_event)
	var player_node = _get_player_node_or_null(_peer_id)
	if player_node != null:
		print("push confirm ", mp_event)
		if MPEventBuilder.is_drone_confirm_thrust(mp_event):
			print("push confirm thrust")
			player_node.push_confirm_thrust_event(mp_event)
		elif MPEventBuilder.is_drone_rotate(mp_event):
			print("push confirm thrust")
			player_node.push_confirm_confirm_rotate_event(mp_event)
	


@rpc("authority", "call_remote", "reliable")
func send_server_event(event):
	print(event)


@rpc("authority", "call_remote", "reliable")
func send_metaverse_status(metaverese_status):
	print(metaverese_status)
	# QUESTA E' SOLO UNA PROVA VA FATTA INTERPOLAZIONE
	# ANCHE PER GLI ALTRI DRONI
	for drone in metaverese_status.drones.keys():
		var player_name = "PlayerSpawnerArea/" + str(drone)
		var player_node = get_node_or_null(player_name)
		if player_node != null:
			player_node.set_mapod_position(
					metaverese_status.drones[str(drone)])


func serverTime():
	return _server_ticks_delta + Time.get_ticks_msec()


func connection_failed():
	print("Connection ERROR!")
	_peer_id = null
	_playerSpawnerArea.local_spawn()
	await get_tree().create_timer(1).timeout
	var player_node = _playerSpawnerArea.get_local_player()
	player_node.player_event_requested.connect(_on_player_event_requested)


# ----- private methods
func _is_connected():
	var ret_val = false
	if multiplayer.multiplayer_peer != null:
		var con_status = multiplayer.multiplayer_peer.get_connection_status()
		if  con_status == MultiplayerPeer.CONNECTION_CONNECTED:
			ret_val = true
	return ret_val


func _get_player_node_or_null(peer_id):
	var player_node_name = "/root/Mapod4dMain/PlayerSpawnerArea/" + str(peer_id)
	var player_node = get_node_or_null(player_node_name)
	return player_node


func _get_latency():
	_latency = 0
	if _is_connected():
		var server_connection = multiplayer.multiplayer_peer.get_peer(1)
		if server_connection != null:
			_latency = server_connection.get_statistic(
						ENetPacketPeer.PEER_ROUND_TRIP_TIME) / 2
			#print("RTT " + str(_latency))
			_latency_variance = server_connection.get_statistic(
						ENetPacketPeer.PEER_ROUND_TRIP_TIME_VARIANCE)
			_latency = (_ticks_sync_request_end_time -
					_ticks_sync_request_begin_time) / 2
			#print("PING TEST " + str(_latency))
			if _latency < 0:
				#print("NEGATIVE LATENCY -------------------")
				_latency = 1
			_latency_queue.push_back(_latency)
			if len(_latency_queue) == _latency_queue_size:
				@warning_ignore("integer_division")
				var med_pos = ((_latency_queue_size - 1) / 2) + 1
				#print("ok")
				var local_latency_queue = _latency_queue.duplicate()
				local_latency_queue.sort()
				var median = local_latency_queue[med_pos]
				#print("median " + str(median))
				var abs_dev = local_latency_queue.map(
						func(number): return abs(number - median))
				abs_dev.sort()
				var mad = abs_dev[med_pos]
				#print("mad " + str(mad))
				#print("local_latency_queue " + str(local_latency_queue))
				var final = local_latency_queue.filter(
						func(number): return number <= (median + mad))
				#print("final " + str(final))
				var total = final.reduce(
						func(accum, number): return accum + number, 0.0)
				#print("total " + str(total))
				#print("len " + str(float(len(final))))
				_latency = total / float(len(final))
				#print("latency " + str(_latency))
				_latency_queue.pop_front()
		# decimal count
		#print("latency_dec " + str(_latency))
		_latency_decimal += _latency - int(_latency)
		_latency = int(_latency)
		if _latency_decimal >= 1:
			_latency_decimal -= 1
			_latency += 1
		#print("latency " + str(_latency))
		assert(_latency >= 0, "negative latency")
		return _latency


func _on_sync_ticks():
	if _peer_id != null and _is_connected():
		ticks_sync_request.rpc_id(1, _peer_id, Time.get_ticks_msec())


func _on_connected_to_server():
	print("Connection OK!")
	await get_tree().create_timer(1).timeout
	if _is_connected():
		for index in range (0, _latency_queue_size + 1):
			_on_sync_ticks()
		_sync_timer = Timer.new()
		add_child(_sync_timer)
		_sync_timer.timeout.connect(_on_sync_ticks)
		_sync_timer.start(0.02)


func _on_connection_failed():
	print("OnConnection ERROR!")
	connection_failed()


func _on_player_event_requested(player_object, mp_event):
	print("PLAYER EVENT")
	var player = player_object
	if _peer_id != null:
		print("NET PLAYER EVENT START")
		# var player = get_player_node_or_null(_peer_id)
		if player != null:
			#event.peer_id = _peer_id
			#event.class = "ME"
			#event.type = MPEVENT_TYPE.DRONE
			#event.T = serverTime()
			#event.L = _latency
			## info setting
			MPEventBuilder.set_peer_id(_peer_id, mp_event)
			MPEventBuilder.set_tick_latency(serverTime(), _latency, mp_event)
			print(_server_ticks_delta)
			## send to server player
			send_player_event.rpc_id(1, _peer_id, mp_event)
			## send to local player
	else:
		print("LOCAL PLAYER EVENT START")
	if MPEventBuilder.is_drone_thrust(mp_event):
		player.push_thrust_event(mp_event)
	elif MPEventBuilder.is_drone_rotate(mp_event):
		player.push_rotate_event(mp_event)
