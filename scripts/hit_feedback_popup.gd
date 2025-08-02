extends Label

const MOVE_UP_AMOUNT: float = 60.0
const DURATION: float = 1.0

func setup(text: String, color: Color, font_size: int, is_empowered: bool = false):
	self.text = text
	self.modulate = color
	self.add_theme_font_size_override("font_size", font_size)

	var start_scale = Vector2(1.8, 1.8) if is_empowered else Vector2(1.5, 1.5)
	var end_scale = Vector2.ONE
	var start_pos = global_position
	var end_pos = start_pos - Vector2(0, MOVE_UP_AMOUNT)

	var tween = create_tween()
	tween.set_parallel(true)
	# Pop in animation
	tween.tween_property(self, "scale", end_scale, 0.15).from(start_scale).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# Upward movement
	tween.tween_property(self, "global_position", end_pos, DURATION * 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, DURATION * 0.6).set_delay(DURATION * 0.4)

	tween.finished.connect(queue_free)
