class_name MapodInputBuffer
extends Object


var _internal_buffer = []
var _max_size = 0
var minimum_time = 0



func _init(max_size: int):
	_max_size = max_size


func push(mapod_event, minimum_tick):
	if mapod_event.T > minimum_tick:
		if _internal_buffer.is_empty():
			_internal_buffer.push_back(mapod_event)
		else:
			var b_size = len(_internal_buffer)
			for index in range(0, b_size):
				var local_index = b_size - index - 1
				print(local_index)
				if mapod_event.T > _internal_buffer[local_index].T:
					if local_index == b_size - 1:
						_internal_buffer.push_back(mapod_event)
					elif local_index == 0:
						_internal_buffer.push_front(mapod_event)
					else:
						_internal_buffer.insert(local_index + 1, mapod_event)
					break


func pop(current_tick):
	var result = []
	var current
	while _internal_buffer.is_empty() == false:
		if _internal_buffer[0].T <= current_tick:
			current = _internal_buffer.pop_front()
			result.push_back(current)
		else:
			break
	return result


func pop_single():
	var result = null
	if _internal_buffer.is_empty() == false:
		result = _internal_buffer.pop_front()
	return result


func print():
	var b_size = len(_internal_buffer)
	for index in range(0 , b_size):
		print(_internal_buffer[index])
