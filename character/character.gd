extends CharacterBody2D
class_name Character

var lock_move = false
@export var default_hp: int
@export var default_velocity: float
@onready var hp: int = default_hp 
@onready var hp_bar = %HpBar
@onready var danage_sound = $DamageSound

var invulnerability: bool = false
var projectiles: Node2D

func die_animation():
	process_mode = Node.PROCESS_MODE_DISABLED
	var tween = get_tree().create_tween().set_parallel().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var mult = 1
	if randi() & 1:
		mult = -1
	tween.tween_property(self, "rotation", mult * PI / 2, 0.2)
	tween.tween_property(self, "modulate", Color.RED, 0.3)
	await  tween.finished


func set_hp(hp: int):
	self.hp = hp
	hp_bar.update(hp, default_hp)

func _ready() -> void:
	set_hp(default_hp)

func apply_velocity(delta: float):
	pass

func handle_collision():
	pass

func _input(event: InputEvent) -> void:
	pass

func apply_damage(damage: int):
	pass



func _physics_process(delta: float) -> void:
	if not lock_move:
		apply_velocity(delta)
	if move_and_slide():
		handle_collision()

func get_view_direction():
	return (get_global_mouse_position() - global_position).normalized()

func push(direction: Vector2, push_speed: float, push_duration: float):
	if lock_move or invulnerability:
		return
	direction = direction.normalized()
	lock_move = true
	var tween = self.create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, push_duration).from(push_speed * direction)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	await tween.finished
	lock_move = false
	
