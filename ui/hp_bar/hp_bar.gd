@tool
extends HBoxContainer

@export var editor_hp: int = 0:
	set(val):
		editor_hp = val
		update(editor_hp, editor_max_hp)
@export var editor_max_hp: int = 0:
	set(val):
		editor_max_hp = val
		update(editor_hp, editor_max_hp)

@export var heart: Texture2D 
@export var empty_heart: Texture2D
@export var visible_on_full_hp = false

func add_texture_rect(texture):
		var texture_rect = TextureRect.new()
		texture_rect.texture = texture
		add_child(texture_rect)
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func update(hp, max_hp = hp):
	if hp == max_hp and not visible_on_full_hp:
		return
	
	for x in get_children():
		x.queue_free()
	
	if hp > 5:
		var label = Label.new()
		label.text = str(hp)
		add_child(label)
		add_texture_rect(heart)
	else: 	
		for i in range(hp):
			add_texture_rect(heart)
	
	pivot_offset = size / 2
	
	
	
