extends Area2D
class_name Parry

@onready var player: Player = get_parent()
@export var collision_shape: CollisionShape2D
var parry_promise: bool = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("parry"):
		start_parry()
	if Input.is_action_just_released("parry"):
		end_parry()

func start_parry():
	parry_promise = true
	if player.state != player.State.WALK:
		return
	player.state = player.State.PARRY
	visible = true
	monitorable = true
	
func end_parry():
	parry_promise = false
	if player.state != player.State.PARRY:
		return
	player.state = player.State.WALK
	visible = false
	monitorable = false
