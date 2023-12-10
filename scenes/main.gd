extends Node

# Flappy Bird Clone Game in GODOT

@export var pipe_scene: PackedScene

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
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	# Reset the game state
	game_running = false
	game_over = false
	# scroll is the position of the ground
	scroll = 0
	score = 0
	$UI/ScoreLabel.text = "SCORE: " + str(score)
	$GameOver.hide()
	get_tree().call_group("pipes", "queue_free")
  # remove all pipes
	pipes.clear()
  # generate the first set of pipes
	generate_pipes()
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
						check_top()
					
func start_game():
	game_running = true
	$Bird.flap()
	# start pipe timer
	$PipeTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		# reset scroll
		if scroll >= screen_size.x:
			scroll = 0
		# move the ground
		$Ground.scroll(scroll)
		# move pipes
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED


func _on_pipe_timer_timeout():
	generate_pipes()


func generate_pipes():
	var pipe = pipe_scene.instantiate()
  # pipe slides from right to left
	pipe.position.x = screen_size.x + PIPE_DELAY
  # each pipe set is a random height between -PIPE_RANGE and PIPE_RANGE
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)

func scored():
	score += 1
	$UI/ScoreLabel.text = "SCORE: " + str(score)

func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$Bird.flying = false
	game_running = false
	game_over = true
	$GameOver.show()

func bird_hit():
	$Bird.falling = true
	stop_game()


func _on_ground_hit():
	# prevent the bird from falling through the ground
	$Bird.falling = false
	stop_game()


func _on_game_over_restart():
	new_game()
