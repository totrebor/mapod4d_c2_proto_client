class_name MapodEventBuffer
extends RefCounted


var _internal_buffer = []
var _max_size = 0
var minimum_time = 0



func _init(max_size: int):
	_max_size = max_size


func push(mapod4d_event, minimum_tick):
	var len_internal_buffer = len(_internal_buffer)
	if mapod4d_event.T > minimum_tick:
		if len_internal_buffer == 0:
			_internal_buffer.push_back(mapod4d_event)
		else:
			for index in range(0, len_internal_buffer):
				var local_index = len_internal_buffer - index - 1
				print(local_index)
				if mapod4d_event.T > _internal_buffer[local_index].T:
					if local_index == len_internal_buffer - 1:
						_internal_buffer.push_back(mapod4d_event)
					elif local_index == 0:
						_internal_buffer.push_front(mapod4d_event)
					else:
						_internal_buffer.insert(local_index + 1, mapod4d_event)
					break


func is_empty():
	var ret_val = false
	if len(_internal_buffer) == 0:
		ret_val = true
	return ret_val


func get_event():
	return _internal_buffer.pop_back()


func print():
	var b_size = len(_internal_buffer)
	for index in range(0 , b_size):
		print(_internal_buffer[index])
