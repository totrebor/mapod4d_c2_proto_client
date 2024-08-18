class_name MapodEventList
extends RefCounted

var _internal_buffer = []
var _max_size = 0

## define buffer max size
func _init(max_size: int):
	_max_size = max_size


## unconditioned push
func push_unc(mapod4d_event):
	var len_internal_buffer = len(_internal_buffer)
	if _max_size == 0 or len_internal_buffer < _max_size:
		if len_internal_buffer == 0:
			_internal_buffer.push_back(mapod4d_event)
		else:
			for index in range(0, len_internal_buffer):
				var local_index = len_internal_buffer - index - 1
				if mapod4d_event.T > _internal_buffer[local_index].T:
					if local_index == len_internal_buffer - 1:
						_internal_buffer.push_back(mapod4d_event)
					elif local_index == 0:
						_internal_buffer.push_front(mapod4d_event)
					else:
						_internal_buffer.insert(local_index + 1, mapod4d_event)
					break
	else:
		## out of buffer
		pass


## conditioned push
func push_c(mapod4d_event, minimum_tick):
	var len_internal_buffer = len(_internal_buffer)
	if _max_size == 0 or len_internal_buffer < _max_size:
		if minimum_tick == 0 or mapod4d_event.T > minimum_tick:
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
		else:
			## discarged
			pass
	else:
		## out of buffer
		pass


func is_empty():
	var ret_val = false
	if len(_internal_buffer) == 0:
		ret_val = true
	return ret_val


## get and remove mapod event
func get_event_rm():
	var ret_val = null
	if !is_empty():
		ret_val = _internal_buffer.pop_front()
	return ret_val


## get and remove mapod event
## with specified tick and clean events before
func get_event_cb(tick):
	var ret_val = null
	while !is_empty():
		if _internal_buffer[0].T == tick:
			ret_val = _internal_buffer.pop_front()
			break
		elif _internal_buffer[0].T < tick:
			_internal_buffer.pop_front()
		else:
			break
	return ret_val


func print():
	var b_size = len(_internal_buffer)
	for index in range(0 , b_size):
		print(_internal_buffer[index])
