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
enum MPEVENT_TYPE {
	DRONE = 0,
}

# ----- constants
const ADDRESS = "localhost"
const PORT = 9999
const LATENCY_QUEUE_SIZE = 11

# ----- exported variables

# ----- public variables
var multiplayer_peer = ENetMultiplayerPeer.new()

var player_scene = preload("res://player.tscn")
var _player_node = ""

var sync_timer = null
var server_ticks_delta = 0

# ----- private variables
var _network_error = false
var _server_connection = null
var _latency_queue = []
var _latency_queue_size: int = LATENCY_QUEUE_SIZE
var _latency = 0.0
var _latency_decimal = 0.0

# sync time like ping
var _ticks_sync_request_begin_time = 0
var _ticks_sync_request_end_time = 10

var _peer_id = null
var _auth_token = null




var latency_variance = 0.0


# ----- onready variables

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	if _latency_queue_size <= 3:
		_latency_queue_size = 3
	else:
		if _latency_queue_size % 2 == 0:
			_latency_queue_size += 1
	if multiplayer_peer.create_client(ADDRESS, PORT) == OK:
		multiplayer.multiplayer_peer = multiplayer_peer
		var peer = multiplayer_peer.get_peer(1)
		if peer != null:
			multiplayer_peer.get_peer(1).set_timeout(0, 0, 3000)  # 3 seconds max timeout
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)
	else:
		_network_error = true
		call_deferred("connection_failed")


# ----- remaining built-in virtual methods

func _physics_process(_delta):
	pass # Replace with function body.
	# try to do another sync
	#client_clock += int(delta * 1000) + delta_latency
	#delta_latency -= delta_latency
	#decimal_collector += (delta * 100) - int(delta * 1000)
	#if decimal_collector >= 1.00:
	#	client_clock += 1
	#	decimal_collecor -= 1.00


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#if event.is_action_pressed("mapod_a"):
		#send_event.rpc_id(1, {
			#"T": Time.get_ticks_msec() + server_ticks_delta,
			#"peer_id": _peer_id
		#})
	pass


# ----- public methods

## server connected
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
	_player_node = "PlayerSpawnerArea/" + str(peer_id)
	var player_node = get_node(_player_node)
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
	server_ticks_delta =  server_tick - _ticks_sync_request_end_time
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
		print("push confirm")
		player_node.push_confirm_thrust_event(mp_event)
	


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


# ----- private methods

func _get_player_node_or_null(peer_id):
	var player_node_name = "PlayerSpawnerArea/" + str(peer_id)
	var player_node = get_node_or_null(_player_node)
	return player_node

func _on_connected_to_server():
	print("Connection OK!")
	await get_tree().create_timer(1).timeout
	_server_connection = multiplayer.multiplayer_peer.get_peer(1)
	for index in range (0, _latency_queue_size + 1):
		_on_sync_ticks()
	sync_timer = Timer.new()
	add_child(sync_timer)
	sync_timer.timeout.connect(_on_sync_ticks)
	sync_timer.start(0.02)


func connection_failed():
	print("Connection ERROR!")
	_peer_id = null
	_server_connection = null
	$PlayerSpawnerArea.local_spawn()
	await get_tree().create_timer(1).timeout
	var player_node = $PlayerSpawnerArea.get_local_player()
	player_node.player_event_requested.connect(_on_player_event_requested)


func _on_connection_failed():
	print("OnConnection ERROR!")
	connection_failed()
	#_peer_id = null
	#_server_connection = null
	#$PlayerSpawnerArea.local_spawn()

#https://daposto.medium.com/game-networking-2-time-tick-clock-synchronisation-9a0e76101fe5
#Method 1
#
#https://web.archive.org/web/20181107022429/http://www.mine-control.com/zack/timesync/timesync.html
#
#The simplest idea is to sync the time between the Client and the Server once (at the beginning of the game session or game event or…) and then rely on both the Client and the Server clock running at pretty much the same speed.
#
#A simple algorithm with these properties is as follows:
#
	#Client stamps current local time on a “time request” packet and sends to server
	#Upon receipt by server, server stamps server-time and returns
	#Upon receipt by client, client subtracts current time from sent time and divides by two to compute latency. It subtracts current time from server time to determine client-server time delta and adds in the half-latency to get the correct clock delta.(So far this algothim is very similar to SNTP)
	#The first result should immediately be used to update the clock since it will get the local clock into at least the right ballpark (at least the right timezone!)
	#The client repeats steps 1 through 3 five or more times, pausing a few seconds each time. Other traffic may be allowed in the interim, but should be minimized for best results
	#The results of the packet receipts are accumulated and sorted in lowest-latency to highest-latency order. The median latency is determined by picking the mid-point sample from this ordered list.
	#All samples above approximately 1 standard-deviation from the median are discarded and the remaining samples are averaged using an arithmetic mean.
#
#The only subtlety of this algorithm is that packets above one standard deviation above the median are discarded. The purpose of this is to eliminate packets that were retransmitted by TCP. To visualize this, imagine that a sample of five packets was sent over TCP and there happened to be no retransmission. In this case, the latency histogram will have a single-mode (cluster) centered around the median latency. Now imagine that in another trial, a single packet of the five is retransmitted. The retransmission will cause this one sample to fall far to the right on the latency histogram, on average twice as far away as the median of the primary mode. By simply cutting out all samples that fall more than one standard deviation away from the median, these stray modes are easily eliminated assuming that they do not comprise the bulk of the statistics.
#Method 2
#
	#When joining a game, have the client send the server a time sync request packet with the client’s current local time.
	#When the server receives this packet, have the server send back to the client a time sync response packet with the following: a) The local time that the client originally sent to the server b) The server’s current game time.
	#When the client receives the response packet, he subtracts the local time in the packet, from his current local time. This gives him the round trip ping value.
	#The client divides the round trip ping by 2 to get an approximation of the one-way latency.
	#The client then adds the one-way latency that he just calculated to the server’s ping time he received in the packet.
	#The client sets his game time to this newly calculated time.

func _get_latency():
	_latency = 0
	if _server_connection != null:
		_latency = _server_connection.get_statistic(
					ENetPacketPeer.PEER_ROUND_TRIP_TIME) / 2
		#print("RTT " + str(_latency))
		latency_variance = _server_connection.get_statistic(
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
	#print("start _on_sync_ticks")
	if _peer_id != null and is_peer_connected():
		#print("request _on_sync_ticks")
		ticks_sync_request.rpc_id(1, _peer_id, Time.get_ticks_msec())
	#print("end _on_sync_ticks")


func is_peer_connected():
	var ret_val = false
	var con_status = multiplayer.multiplayer_peer.get_connection_status()
	if  con_status == MultiplayerPeer.CONNECTION_CONNECTED:
		ret_val = true
	return ret_val


func serverTime():
	return server_ticks_delta + Time.get_ticks_msec()


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
			print(server_ticks_delta)
			## send to server player
			send_player_event.rpc_id(1, _peer_id, mp_event)
			## send to local player
			player.push_thrust_event(mp_event)
	else:
		print("LOCAL PLAYER EVENT START")
		player.push_thrust_event(mp_event)
