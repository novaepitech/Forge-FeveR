extends Node2D

signal missed

var target_time: float
var track_id: int
var is_empowered: bool
var speed: float

var game_logic: Node
var target_x_pos: float

@onready var sprite: Sprite2D = $Sprite2D

func _process(delta: float):
	position.x -= speed * delta

	if position.x < target_x_pos - 50:
		missed.emit(self)
		queue_free()

func setup(p_target_time: float, p_game_logic: Node, p_start_pos: Vector2, p_end_pos: Vector2, p_track_id: int, p_is_empowered: bool, icon_texture: Texture2D):
	target_time = p_target_time
	position = p_start_pos
	track_id = p_track_id
	is_empowered = p_is_empowered

	game_logic = p_game_logic
	target_x_pos = p_end_pos.x

	if sprite and icon_texture:
		sprite.texture = icon_texture

	if is_empowered:
		self.modulate = Color.GOLD
		self.scale = Vector2(1.2, 1.2)

	var distance = p_start_pos.x - p_end_pos.x
	# Use the stored game_logic reference to access lookahead_time
	var time_to_travel = game_logic.lookahead_time
	if time_to_travel > 0:
		speed = distance / time_to_travel

func hit():
	queue_free()
