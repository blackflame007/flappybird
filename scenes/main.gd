extends Node

# Flappy Bird Clone Game in GODOT

# Flags to determine if the game is running or over
var game_running: bool
var game_over: bool
var scroll
var score
const SCROLL_SPEED: int = 4
var screen_size: Vector2i
var ground_height: int
var pipes: Array
const PIPE_DELAY: int = 100
const PIPE_RANGE: int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func new_game():
	# Reset the game state
	game_running = false
	game_over = false
	scroll = 0
	score = 0
	$Bird.reset()
	
func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
					
func start_game():
	game_running = true
	$Bird.flap()
