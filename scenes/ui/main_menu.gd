extends Control

@onready var start_game = preload("res://scenes/main.tscn")

func _ready():
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_packed(start_game)



func _on_quit_button_pressed():
	get_tree().quit()
