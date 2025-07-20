extends Enemy

var attack_cooldown: float = 2
@onready var timer: Timer = %AttackTimer

static  var curve: Curve2D = preload("uid://dnjkbgd3jaave")
static var curve_len: int = int(curve.get_baked_length())
var step: float = 16

@onready var offset: float = curve.get_closest_offset(global_position)
@onready var next_point: Vector2 = curve.sample_baked(offset)
static var points: Array[bool] = []
static  var radius = 16

static func _static_init() -> void:
	for i in range(int(curve.get_baked_length() / radius)):
		points.append(true)

func fix_offset(offset):
	return fposmod(offset, curve.get_baked_length()) 

func get_point(offset):
	return curve.sample_baked(fix_offset(offset))

func apply_velocity(delta: float):
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	var offset = curve.get_closest_offset(global_position)
	var near_point = offset / radius
	for i in range(len(points) / 2):
		pass
	
			
			
