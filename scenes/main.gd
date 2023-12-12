extends Node

# Flappy Bird Clone Game in GODOT

@export var pipe_scene: PackedScene

# Flags to determine if the game is running or over
var game_running: bool
var game_over: bool
var scroll
var score
var highScore
const SCROLL_SPEED: int = 4
var screen_size: Vector2i
var ground_height: int
var pipes: Array
const PIPE_DELAY: int = 100
const PIPE_RANGE: int = 200
const SAVEFILE = "user://save.json"

@onready var score_label = $UI/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ScoreLabel
@onready var high_score_label = $UI/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HighScoreLabel

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
	highScore = 0
	load_game()
	score_label.text = "SCORE: " + str(score)
	high_score_label.text = "HIGH SCORE: " + str(highScore)
	$GameOver.hide()
	get_tree().call_group("pipes", "queue_free")
  # remove all pipes
	pipes.clear()
  # generate the first set of pipes
	generate_pipes()
	$Bird.reset()
	
func _input(event):
	if game_over == false:
		if event.is_action_pressed("flap"):
			if game_running == false:
				start_game()
			else:
				if $Bird.flying:
					$Bird.flap()
					check_top()
	# Check if restart button is pressed
	if event.is_action_pressed("restart"):
		if game_over:
			new_game()
					
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
	score_label.text = "SCORE: " + str(score)
	if score > highScore:
		highScore = score
		high_score_label.text = "HIGH SCORE: " + str(highScore)

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
	save_game()

func bird_hit():
	$Bird.falling = true
	stop_game()


func _on_ground_hit():
	# prevent the bird from falling through the ground
	$Bird.falling = false
	stop_game()


func _on_game_over_restart():
	new_game()


func save():
	var save_dict = {
		"high_score": score
	}
	return save_dict

# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)

	var node_data = save()

	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(node_data)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)


# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		highScore = node_data["high_score"]
