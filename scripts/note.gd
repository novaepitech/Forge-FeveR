extends Area2D

signal missed

var target_time: float = 0.0
var game_node
var spawn_position: Vector2
var target_position: Vector2
var track_id: int = 0

# --- Cahier des Charges 2.B Addition ---
# Flag to identify special notes for scoring and visual feedback.
var is_empowered: bool = false

# A state to prevent multiple behaviors (e.g., being missed after being hit).
var is_hit: bool = false

func setup(p_target_time: float, p_game_node, p_spawn_pos: Vector2, p_target_pos: Vector2, p_track_id: int):
	self.target_time = p_target_time
	self.game_node = p_game_node
	self.spawn_position = p_spawn_pos
	self.target_position = p_target_pos
	self.global_position = spawn_position
	self.track_id = p_track_id

func _process(_delta: float):
	if not is_instance_valid(game_node) or is_hit:
		return

	var current_song_time = game_node.song_position
	var lookahead = game_node.lookahead_time
	var spawn_time = target_time - lookahead

	if current_song_time < spawn_time:
		self.visible = false
		return

	self.visible = true

	var progress = (current_song_time - spawn_time) / lookahead
	self.global_position = spawn_position.lerp(target_position, progress)

	if current_song_time > target_time + game_node.timing_window_ok:
		is_hit = true
		emit_signal("missed")
		queue_free()

func hit():
	is_hit = true
	queue_free()
