extends PanelContainer
class_name UpgradeCard

@onready var upgrade: Upgrade:
	set(val):
		upgrade = val
		var mod = Color.WHITE
		match upgrade.level:
			0:
				mod = Color("b0c3d9")
			1:
				mod = Color("8847ff")
			2: 
				mod = Color("fff34f")
		self_modulate = mod
		%Label.text = upgrade.description
		%TextureRect.texture = upgrade.texture
		centered()
		
signal upgrade_choosen(upgrade: Upgrade)
var mouse_in = false

func centered():
	pivot_offset = size / 2

func _on_mouse_entered() -> void:
	%AudioStreamPlayer.play()
	scale = Vector2(1.06, 1.06)
	mouse_in = true


func _on_mouse_exited() -> void:
	scale = Vector2(1.0, 1.0)
	mouse_in = false


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and mouse_in:
		upgrade_choosen.emit(upgrade)
		%AudioStreamPlayer.play()
		get_viewport().set_input_as_handled()
