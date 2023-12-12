extends Area2D

signal hit


func _on_body_entered(body):
	hit.emit()

func scroll(_scroll):
	position.x = -_scroll
