class_name MapodStatusBuffer
extends Object


var _internal_buffer = []
var _max_size = 0
var minimum_time = 0



func _init(max_size: int):
	_max_size = max_size


func push(mapod4d_status, minimum_tick):
	if mapod4d_status.T > minimum_tick:
		if _internal_buffer.is_empty():
			_internal_buffer.push_back(mapod4d_status)
		else:
			var b_size = len(_internal_buffer)
			for index in range(0, b_size):
				var local_index = b_size - index - 1
				print(local_index)
				if mapod4d_status.T > _internal_buffer[local_index].T:
					if local_index == b_size - 1:
						_internal_buffer.push_back(mapod4d_status)
					elif local_index == 0:
						_internal_buffer.push_front(mapod4d_status)
					else:
						_internal_buffer.insert(local_index + 1, mapod4d_status)
					break


func print():
	var b_size = len(_internal_buffer)
	for index in range(0 , b_size):
		print(_internal_buffer[index])
