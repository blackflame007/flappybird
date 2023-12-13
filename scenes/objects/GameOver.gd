extends CanvasLayer

signal restart

func _ready():
	pass




func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_restart_button_pressed():
	restart.emit()
