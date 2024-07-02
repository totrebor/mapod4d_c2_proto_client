# tool

# class_name
class_name MPEventBuilder

# extends
extends Object

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:            http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com


# ----- signals

# ----- enums
enum MPEVENT_TYPE {
	NONE = 0,
	DRONE_THRUST = 1000,
	DRONE_ROTATE = 1001,
	DRONE_CONFIRM_POSITION = 1001,
}

enum MPEVENT_INPUT_DT {
	NULL = 0,
	VECTOR3 = 1,
}

# ----- constants
const TICK = "T"
const LATENCY = "L"
const MPE = "M"
const PEER_ID = "P"
const INPUT = "I"

# ----- exported variables

# ----- public variables

# ----- private variables

# ----- onready variables


# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# ----- remaining built-in virtual methods

# ----- public methods
static func is_drone(mp_event):
	var ret_val = false
	if MPE in mp_event:
		if mp_event[MPE] == MPEVENT_TYPE.DRONE_THRUST:
			ret_val = true
		elif  mp_event[MPE] == MPEVENT_TYPE.DRONE_ROTATE:
			ret_val = true
		elif  mp_event[MPE] == MPEVENT_TYPE.DRONE_CONFIRM_POSITION:
			ret_val = true
	return ret_val


static func is_drone_trust(mp_event):
	var ret_val = false
	if MPE in mp_event:
		if mp_event[MPE] == MPEVENT_TYPE.DRONE_THRUST:
			ret_val = true
	return ret_val


static func set_peer_id(peer_id, mp_event):
	mp_event[PEER_ID] = peer_id


static func set_tick(tick, mp_event):
	mp_event[TICK] = tick


static func set_latency(latency, mp_event):
	mp_event[LATENCY] = latency


static func set_tick_latency(tick, latency, mp_event):
	mp_event[TICK] = tick
	mp_event[LATENCY] = latency


static func gain_peer_id(mp_event):
	return _gain_data(mp_event, PEER_ID)


static func gain_input(mp_event):
	return _input_decode(_gain_data(mp_event, INPUT))


static func get_empty():
	var mp_event = {
		TICK: 0,
		LATENCY: 0,
		MPE: MPEVENT_TYPE.NONE,
	}
	return mp_event


static func get_drone_trust(vec_input :Vector3):
	var input_data = _input_encode({
			"v": {
				"t": MPEVENT_INPUT_DT.VECTOR3,
				"d": vec_input
			}
		})
	var mp_event = {
		TICK: 0,
		LATENCY: 0,
		MPE: MPEVENT_TYPE.DRONE_THRUST,
		INPUT: input_data
	}
	return mp_event


static func get_drone_rotate(vec_input :Vector3):
	var mp_event = {
		TICK: 0,
		LATENCY: 0,
		MPE: MPEVENT_TYPE.DRONE_ROTATE,
		INPUT: JSON.stringify(vec_input)
	}
	return mp_event

# ----- private methods

static func _gain_data(mp_event, data_id):
	var ret_val = ""
	if data_id in mp_event:
		ret_val = str(mp_event[data_id])
	return ret_val


static func _input_encode(data: Dictionary):
	var ret_val = {}
	for element_name in data:
		match data[element_name].t:
			MPEVENT_INPUT_DT.VECTOR3:
				ret_val[element_name] = {
					"t": data[element_name].t,
					"d" : {
						"x": data[element_name].d.x,
						"y": data[element_name].d.y,
						"z": data[element_name].d.z
					}
				}
	return JSON.stringify(ret_val)


static func _input_decode(tmp_data: String):
	var ret_val = {}
	var data = JSON.parse_string(tmp_data)
	for element_name in data:
		match int(data[element_name].t):
			MPEVENT_INPUT_DT.VECTOR3:
				ret_val[element_name] = {
					"t": data[element_name].t,
					"d": Vector3(
						float(data[element_name].d.x),
						float(data[element_name].d.y),
						float(data[element_name].d.z),
					)
				}
	return ret_val
