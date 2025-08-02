extends Area2D

signal missed

@onready var color_rect: ColorRect = $ColorRect

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

func setup(p_target_time: float, p_game_node, p_spawn_pos: Vector2, p_target_pos: Vector2, p_track_id: int, p_is_empowered: bool):
	self.target_time = p_target_time
	self.game_node = p_game_node
	self.spawn_position = p_spawn_pos
	self.target_position = p_target_pos
	self.global_position = spawn_position
	self.track_id = p_track_id

	self.is_empowered = p_is_empowered
	if is_empowered:
		# Visually distinguish empowered notes
		color_rect.color = Color.GOLD

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
