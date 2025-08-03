extends Node2D

signal missed

var target_time: float
var track_id: int
var is_empowered: bool
var speed: float

var game_logic: Node
var target_x_pos: float

# A flag to prevent animations from triggering multiple times
var is_being_destroyed: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _process(delta: float):
	# If the note is already animating out, do nothing.
	if is_being_destroyed:
		return

	position.x -= speed * delta

	# When a note is missed by passing the target zone.
	if position.x < target_x_pos - 50:
		is_being_destroyed = true
		missed.emit(self)
		# Trigger just the fade-out animation.
		fade_out()

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
	var time_to_travel = game_logic.lookahead_time
	if time_to_travel > 0:
		speed = distance / time_to_travel

func hit():
	if is_being_destroyed:
		return
	is_being_destroyed = true
	# Stop the note from moving during its animation.
	set_process(false)

	# Create a new tween to handle the animations.
	var tween = create_tween()
	# Set the animations to run in parallel.
	tween.set_parallel()
	# Animate the scale to make it pop.
	tween.tween_property(self, "scale", scale * 1.4, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	# Animate the alpha component of modulate to fade it out.
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Wait for the tween to finish, then free the node.
	await tween.finished
	queue_free()

# This new function handles the fade-out for a missed note.
func fade_out():
	# Stop the note from moving during its animation.
	set_process(false)

	var tween = create_tween()
	# Animate only the alpha component to fade out (longer duration).
	tween.tween_property(self, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN)

	# Wait for the tween to finish, then free the node.
	await tween.finished
	queue_free()
