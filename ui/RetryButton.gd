extends Button

var was_visible = false

func _process(delta):
	if !was_visible and is_visible_in_tree():
		was_visible = true
		grab_focus()

func _pressed():
	get_tree().change_scene("res://cart/Master.tscn")
