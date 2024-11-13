extends Node

const DIRECTIONS : Array = [ # <Vector2>
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, 1),
	Vector2(-1, 1),
	Vector2(-1, 0),
	Vector2(-1, -1),
]

static func get_direction_snap(point : Vector2, origin : Vector2) -> Vector2:
	var angle : float = (point - origin).angle()
	
	if angle < 0:
		angle += TAU
		
	var index = int(round((angle + PI / 2) / (PI / 4))) % 8
	
	return DIRECTIONS[index]
	
static func get_direction_analog(point : Vector2, origin : Vector2) -> Vector2:
	return (point - origin).normalized()
	
static func is_intercardinal(direction : Vector2) -> bool:
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		return true
	else:
		return false
		
static func is_subset(v1 : Vector2, v2 : Vector2) -> bool:
	if v1.x == v2.x and v1.y == 0:
		return true
	elif v1.y == v2.y and v1.x == 0:
		return true
	elif v1 == v2:
		return true
	else:
		return false
