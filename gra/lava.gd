extends Area2D

@onready var spawn_point = get_node("/root/Gra/SpawnPoint")

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D:
		body.global_position = spawn_point.global_position
