extends PanelContainer
class_name UpgradeCard

@onready var upgrade: Upgrade:
	set(val):
		upgrade = val
		%Label.text = upgrade.description
		%TextureRect.texture = upgrade.texture
		centered()
		
signal upgrade_choosen(upgrade: Upgrade)
var mouse_in = false

func centered():
	pivot_offset = size / 2

func _on_mouse_entered() -> void:
	scale = Vector2(1.06, 1.06)
	mouse_in = true


func _on_mouse_exited() -> void:
	scale = Vector2(1.0, 1.0)
	mouse_in = false


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and mouse_in:
		upgrade_choosen.emit(upgrade)
