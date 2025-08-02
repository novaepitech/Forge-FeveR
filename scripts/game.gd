extends Node2D

# --- Game Parameters ---
const NoteScene = preload("res://scenes/note.tscn")
@export var HitFeedbackPopup: PackedScene
@export var lookahead_time: float = 2.0
@export var track_y_positions: Array[float] = [440.0, 490.0, 540.0]
@export var initial_delay: float = 2.0

# --- Audio Parameters ---
const VOLUME_AUDIBLE_DB: float = 0.0
const VOLUME_MUTED_DB: float = -80.0

# --- Loop & Chart Parameters ---
const LOOP_DURATION: float = 24.0
const EVALUATION_TIME: float = 21.0

# --- Scoring & Empowered Notes Parameters ---
const SCORE_VALUES = { "Perfect": 1000, "Good": 250, "OK": 50, "Miss": 0 }
const EMPOWERED_BONUS: int = 1500
const EMPOWERED_CHANCE_NEW: float = 0.20
const EMPOWERED_CHANCE_OLD: float = 0.07

@export_group("Timing Windows")
@export var timing_window_perfect: float = 0.04
@export var timing_window_good: float = 0.08
@export var timing_window_ok: float = 0.12

@export_group("Fever Meter Settings")
@export var fever_gain_perfect: float = 10.0
@export var fever_penalty_imperfect: float = 5.0
@export var fever_decay_rate: float = 2.5
@export var fever_bar_lerp_speed: float = 8.0 # Speed for smooth visual decay

const FEVER_METER_MIN: float = 0.0
const FEVER_METER_MAX: float = 100.0
const SUPERNOVA_THRESHOLD: float = 95.0

@export_group("Feedback Settings")
@export var shake_strength_perfect: float = 4.0
@export var shake_strength_empowered: float = 8.0
@export var shake_fade: float = 10.0

@export_group("Progression System")
@export var sword_state_textures: Array[Texture2D]
@export var progression_data: Array[Dictionary] = [
	{
		"name": "SCRAP",
		"levels": [
			{"score_threshold": 0, "texture_index": 0},
			{"score_threshold": 65000, "texture_index": 1},
			{"score_threshold": 150000, "texture_index": 2}
		]
	},
	{
		"name": "IRON",
		"levels": [
			{"score_threshold": 450000, "texture_index": 3},
			{"score_threshold": 900000, "texture_index": 3},
			{"score_threshold": 1600000, "texture_index": 4}
		]
	}
]

var all_charts: Dictionary = {
	0: [{"time": 0.0, "track": 1}, {"time": 3.0, "track": 2}, {"time": 6.0, "track": 1}, {"time": 9.0, "track": 2}, {"time": 12.0, "track": 1}, {"time": 15.0, "track": 2}, {"time": 17.0, "track": 3}, {"time": 19.0, "track": 2}],
	1: [{"time": 3.5, "track": 3}, {"time": 6.5, "track": 1}, {"time": 9.5, "track": 3}, {"time": 12.5, "track": 1}, {"time": 15.5, "track": 3}, {"time": 18.5, "track": 1}],
	2: [{"time": 2.75, "track": 2}, {"time": 5.75, "track": 1}, {"time": 8.75, "track": 3}, {"time": 11.75, "track": 1}, {"time": 14.75, "track": 2}, {"time": 17.75, "track": 3}],
	3: [{"time": 4.25, "track": 2}, {"time": 5.375, "track": 1}, {"time": 10.25, "track": 2}, {"time": 14.375, "track": 1}, {"time": 16.25, "track": 3}, {"time": 19.25, "track": 2}]
}

# --- Game State Variables ---
var MAX_LEVEL: int
var song_position: float = 0.0
var active_notes: Array[Node] = []
var total_score: int = 0
var score_multiplier: int = 1
var fever_meter: float = 0.0
var consecutive_misses: int = 0
var base_miss_penalty: int = 500

var current_tier_index: int = 0
var current_level_index: int = 0
var highest_tier_checkpoint_index: int = 0

var loop_position: float = 0.0
var last_loop_position: float = 0.0
var current_loop_start_time: float = 0.0
var current_level: int = 0
var next_level: int = 0
var notes_in_current_loop: int = 0
var notes_hit_in_current_loop: int = 0
var current_loop_spawn_indices: Dictionary = {}
var next_loop_spawn_indices: Dictionary = {}

var music_started: bool = false
var active_music_level: int = 0
var is_awaiting_level_sync_hit: bool = false

var _settings_bar_active: LabelSettings
var _settings_bar_inactive: LabelSettings

var is_supernova_active: bool = false
var supernova_tween: Tween
var fever_bar_tween: Tween

# Screen Shake State
var shake_strength: float = 0.0
var rng = RandomNumberGenerator.new()

# --- Node References ---
@onready var spawn_pos_marker: Marker2D = $SpawnPoint
@onready var target_pos_marker: Marker2D = $TargetZone
@onready var score_label: Label = $UI/ScoreLabel
@onready var fever_meter_bar: ProgressBar = $UI/FeverMeterBar
@onready var sword_display: Sprite2D = $SwordDisplay
@onready var loop_time_label: Label = $UI/LoopTimeLabel
@onready var transition_feedback_label: Label = $UI/TransitionFeedbackLabel
@onready var transition_feedback_timer: Timer = $TransitionFeedbackTimer
@onready var tier_name_label: Label = $UI/TierDisplay/TierNameLabel
@onready var level_bars: Array[Label] = [$UI/TierDisplay/LevelBarsContainer/LevelBar1, $UI/TierDisplay/LevelBarsContainer/LevelBar2, $UI/TierDisplay/LevelBarsContainer/LevelBar3]

@onready var music_layers: Dictionary = {0: $MusicLayers/MusicLayer1, 1: $MusicLayers/MusicLayer2, 2: $MusicLayers/MusicLayer3}
@onready var sfx_perfect: AudioStreamPlayer = $SFX/SfxPerfect
@onready var sfx_imperfect: AudioStreamPlayer = $SFX/SfxImperfect
@onready var sfx_miss: AudioStreamPlayer = $SFX/SfxMiss
@onready var sfx_level_up: AudioStreamPlayer = $SFX/SfxLevelUp
@onready var sfx_level_down: AudioStreamPlayer = $SFX/SfxLevelDown

# --- Feedback Node References ---
@onready var camera: Camera2D = $Camera2D
@onready var ui_canvas_layer: CanvasLayer = $UI
@onready var popup_container: Node2D = $UI/PopupContainer
@onready var target_flashes: Dictionary = {1: $TargetFlashes/FlashTrack1, 2: $TargetFlashes/FlashTrack2, 3: $TargetFlashes/FlashTrack3}
@onready var hit_particles: Dictionary = {
	"Perfect": $HitParticles/ParticlesPerfect, "Empowered": $HitParticles/ParticlesEmpowered,
	"Good": $HitParticles/ParticlesGood, "OK": $HitParticles/ParticlesGood, "Miss": $HitParticles/ParticlesMiss
}
@onready var supernova_flame: AnimatedSprite2D = $UI/FeverMeterBar/SupernovaFlame
@onready var multiplier_tier_labels: Dictionary = {
	2: $UI/FeverMeterBar/MultiplierTiers/Tier2x, 4: $UI/FeverMeterBar/MultiplierTiers/Tier4x,
	8: $UI/FeverMeterBar/MultiplierTiers/Tier8x, 16: $UI/FeverMeterBar/MultiplierTiers/Tier16x,
	32: $UI/FeverMeterBar/MultiplierTiers/Tier32x
}

func _ready():
	MAX_LEVEL = all_charts.keys().max()
	_capture_ui_styles()
	reset_game_state()
	_initialize_audio()


func _capture_ui_styles():
	_settings_bar_active = level_bars[0].label_settings
	_settings_bar_inactive = level_bars[1].label_settings


func reset_game_state():
	if is_node_ready():
		for player in music_layers.values(): player.stop()

	music_started = false
	active_music_level = 0
	is_awaiting_level_sync_hit = false

	total_score = 0
	score_multiplier = 1
	set_fever_meter(FEVER_METER_MIN, false)
	consecutive_misses = 0

	current_tier_index = 0
	current_level_index = 0
	highest_tier_checkpoint_index = 0

	song_position = -initial_delay

	for note in active_notes:
		if is_instance_valid(note): note.queue_free()
	active_notes.clear()

	loop_position = 0.0
	last_loop_position = fmod(-initial_delay, LOOP_DURATION)
	current_loop_start_time = 0.0
	current_level = 0
	next_level = 0
	current_loop_spawn_indices.clear()
	next_loop_spawn_indices.clear()

	_prepare_for_new_loop()

	if is_instance_valid(sword_display):
		sword_display.visible = true
	_update_progression() # Initializes progression state

	_update_fever_state()
	_update_ui()

	if is_node_ready():
		_update_music_volume()


func _initialize_audio():
	for level in music_layers:
		music_layers[level].volume_db = VOLUME_MUTED_DB


func _start_music():
	music_started = true
	print("MUSIC START! Loop begins.")
	for player in music_layers.values():
		player.play(0.0)
	active_music_level = 0
	_update_music_volume()


func _update_music_volume():
	if not music_started: return
	for level in music_layers:
		var player = music_layers[level]
		if level <= active_music_level:
			player.volume_db = VOLUME_AUDIBLE_DB
		else:
			player.volume_db = VOLUME_MUTED_DB


func _process(delta):
	song_position += delta

	if not music_started and song_position >= 0.0:
		_start_music()

	if song_position >= 0:
		loop_position = fmod(song_position, LOOP_DURATION)
		if last_loop_position < EVALUATION_TIME and loop_position >= EVALUATION_TIME:
			_end_of_loop_procedure()
		last_loop_position = loop_position
		loop_time_label.text = "[DEBUG] Loop: %.2fs" % loop_position
	else:
		loop_time_label.text = "[DEBUG] Get Ready..."

	_spawn_notes_from_active_charts()
	_update_fever_meter_visuals(delta)
	_process_shake(delta)


func _update_fever_meter_visuals(delta: float):
	if fever_meter > FEVER_METER_MIN:
		var new_fever_value = fever_meter - fever_decay_rate * delta
		set_fever_meter(new_fever_value, false)

	# --- CORRECTED LINE ---
	# Only lerp for smooth decay if no "pop" tween is currently active
	if not (fever_bar_tween and fever_bar_tween.is_valid()):
		fever_meter_bar.value = lerp(fever_meter_bar.value, fever_meter, delta * fever_bar_lerp_speed)


func _end_of_loop_procedure():
	var success_rate: float = 0.0
	if notes_in_current_loop > 0:
		success_rate = float(notes_hit_in_current_loop) / float(notes_in_current_loop)
	else:
		success_rate = 1.0

	var old_level_for_sfx_check = next_level
	if success_rate >= 0.90:
		next_level = min(current_level + 1, MAX_LEVEL)
		if next_level > current_level: _show_transition_feedback("LEVEL UP!", Color.PALE_GREEN)
		else: _show_transition_feedback("MAX LEVEL!", Color.GOLD)
	elif success_rate >= 0.8:
		next_level = current_level
		_show_transition_feedback("STAY", Color.WHITE_SMOKE)
	else:
		next_level = max(current_level - 1, 0)
		if next_level < current_level: _show_transition_feedback("LEVEL DOWN!", Color.INDIAN_RED)
		else: _show_transition_feedback("STAY", Color.WHITE_SMOKE)

	if next_level > old_level_for_sfx_check: sfx_level_up.play()
	elif next_level < old_level_for_sfx_check: sfx_level_down.play()

	if next_level != old_level_for_sfx_check: next_loop_spawn_indices.clear()

	var loops_passed = floor(song_position / LOOP_DURATION)
	current_loop_start_time = (loops_passed + 1) * LOOP_DURATION

	var old_level = current_level
	current_level = next_level

	if current_level > old_level:
		is_awaiting_level_sync_hit = true
	else:
		if active_music_level != current_level:
			active_music_level = current_level
			_update_music_volume()

	current_loop_spawn_indices = next_loop_spawn_indices.duplicate(true)
	next_loop_spawn_indices.clear()
	_prepare_for_new_loop()
	notes_hit_in_current_loop = 0


func _prepare_for_new_loop():
	notes_in_current_loop = 0
	for level_idx in range(current_level + 1):
		notes_in_current_loop += all_charts.get(level_idx, []).size()


func _spawn_notes_from_active_charts():
	var spawn_helper = func(start_level: int, end_level: int, spawn_indices: Dictionary, loop_start_time: float):
		for level_idx in range(start_level, end_level + 1):
			var chart = all_charts.get(level_idx, [])
			if chart.is_empty(): continue
			var spawn_idx = spawn_indices.get(level_idx, 0)
			while spawn_idx < chart.size():
				var note_data = chart[spawn_idx]
				var note_time_absolute = note_data.time + loop_start_time
				if song_position >= note_time_absolute - lookahead_time:
					spawn_note(note_time_absolute, note_data.track, level_idx)
					spawn_idx += 1
				else:
					break
			spawn_indices[level_idx] = spawn_idx

	spawn_helper.call(0, current_level, current_loop_spawn_indices, current_loop_start_time)
	spawn_helper.call(0, next_level, next_loop_spawn_indices, current_loop_start_time + LOOP_DURATION)


func spawn_note(target_time: float, track_id: int, note_level: int):
	var is_empowered := false
	var chance := 0.0
	if note_level == current_level and current_level > 0:
		chance = EMPOWERED_CHANCE_NEW
	elif note_level < current_level:
		chance = EMPOWERED_CHANCE_OLD

	if randf() < chance:
		is_empowered = true

	var note_instance = NoteScene.instantiate()
	add_child(note_instance)
	var y_pos = track_y_positions[track_id - 1]
	var spawn_for_track = Vector2(spawn_pos_marker.global_position.x, y_pos)
	var target_for_track = Vector2(target_pos_marker.global_position.x, y_pos)
	note_instance.setup(target_time, self, spawn_for_track, target_for_track, track_id, is_empowered)
	active_notes.append(note_instance)
	note_instance.missed.connect(_on_note_missed)


func _unhandled_input(_event: InputEvent):
	if song_position < -timing_window_ok: return

	var hit_time = song_position
	var track_id = 0
	if Input.is_action_just_pressed("hit_track1"): track_id = 1
	elif Input.is_action_just_pressed("hit_track2"): track_id = 2
	elif Input.is_action_just_pressed("hit_track3"): track_id = 3

	if track_id > 0:
		process_player_hit(hit_time, track_id)

func process_player_hit(hit_time: float, track_id: int):
	var best_note: Node = null
	var min_diff = timing_window_ok + 0.1
	for note in active_notes:
		if note.track_id == track_id:
			var diff = abs(note.target_time - hit_time)
			if diff < min_diff:
				min_diff = diff
				best_note = note

	if best_note:
		var timing_error = best_note.target_time - hit_time
		var judgment: String
		if abs(timing_error) <= timing_window_perfect: judgment = "Perfect"
		elif abs(timing_error) <= timing_window_good: judgment = "Good"
		else: judgment = "OK"

		_process_judgment(judgment, best_note)
		active_notes.erase(best_note)
		best_note.hit()
	else:
		_process_judgment("Miss", null, track_id)

func _on_note_missed(note_missed: Node):
	if active_notes.has(note_missed):
		active_notes.erase(note_missed)
	_process_judgment("Miss", note_missed)


# --- CENTRAL JUDGMENT PROCESSING ---
func _process_judgment(judgment: String, note: Node, miss_track_id: int = -1):
	var track_id = note.track_id if note else miss_track_id
	var position = note.global_position if note else Vector2(target_pos_marker.global_position.x, track_y_positions[track_id - 1])
	var is_empowered = note.is_empowered if note else false

	var score_change = 0
	var is_empowered_perfect = (judgment == "Perfect" and is_empowered)
	if is_empowered_perfect:
		score_change = SCORE_VALUES["Perfect"] + EMPOWERED_BONUS
	else:
		score_change = SCORE_VALUES.get(judgment, 0)

	_trigger_all_feedback(judgment, track_id, position, is_empowered_perfect, score_change)

	match judgment:
		"Perfect":
			notes_hit_in_current_loop += 1
			set_fever_meter(fever_meter + fever_gain_perfect, true)
			consecutive_misses = 0
			sfx_perfect.play()
			if is_awaiting_level_sync_hit: _sync_music_on_hit()
		"Good", "OK":
			notes_hit_in_current_loop += 1
			set_fever_meter(fever_meter - fever_penalty_imperfect, false)
			consecutive_misses = 0
			sfx_imperfect.play()
			if is_awaiting_level_sync_hit: _sync_music_on_hit()
		"Miss":
			set_fever_meter(FEVER_METER_MIN, true)
			consecutive_misses += 1
			score_multiplier = 1
			sfx_miss.play()
			if is_awaiting_level_sync_hit: is_awaiting_level_sync_hit = false

	var final_score_change = 0
	if judgment == "Miss":
		final_score_change = -calculate_miss_penalty()
	else:
		final_score_change = score_change * score_multiplier

	total_score += final_score_change
	_update_progression()
	_update_fever_state()
	_update_ui()


func _sync_music_on_hit():
	active_music_level = current_level
	_update_music_volume()
	is_awaiting_level_sync_hit = false


# --- SENSORY FEEDBACK SUB-SYSTEMS ---
func _trigger_all_feedback(judgment: String, track_id: int, pos: Vector2, is_empowered_perfect: bool, score: int):
	_trigger_score_popup(judgment, pos, score, is_empowered_perfect)
	_trigger_camera_shake(judgment, is_empowered_perfect)
	_trigger_target_flash(judgment, track_id)
	_trigger_hit_particles(judgment, pos, is_empowered_perfect)

func _trigger_score_popup(judgment: String, pos: Vector2, score: int, is_empowered_perfect: bool):
	var popup = HitFeedbackPopup.instantiate()
	popup_container.add_child(popup)
	popup.global_position = pos

	var text: String; var color: Color; var font_size: int

	match judgment:
		"Perfect":
			text = "+%d" % score
			color = Color.GOLD
			font_size = 32 if not is_empowered_perfect else 48
		"Good", "OK":
			text = "+%d" % score
			color = Color.WHITE_SMOKE
			font_size = 24
		"Miss":
			var penalty = calculate_miss_penalty()
			text = "MISS\n-%d" % penalty
			color = Color.INDIAN_RED
			font_size = 28

	popup.setup(text, color, font_size, is_empowered_perfect)

func _trigger_camera_shake(judgment: String, is_empowered_perfect: bool):
	if judgment != "Perfect": return
	var strength = shake_strength_empowered if is_empowered_perfect else shake_strength_perfect
	# Set shake strength. Using max prevents a stronger shake from being overridden by a weaker one.
	shake_strength = max(shake_strength, strength)

func _trigger_target_flash(judgment: String, track_id: int):
	if not target_flashes.has(track_id): return
	var flash_rect: ColorRect = target_flashes[track_id]

	var color: Color
	match judgment:
		"Perfect": color = Color.GOLD
		"Good", "OK": color = Color.WHITE
		"Miss": color = Color.RED
		_: return

	flash_rect.color = color
	var tween = get_tree().create_tween()
	flash_rect.modulate.a = 1.0
	tween.tween_property(flash_rect, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN)

func _trigger_hit_particles(judgment: String, pos: Vector2, is_empowered_perfect: bool):
	var key = "Empowered" if is_empowered_perfect else judgment
	if hit_particles.has(key):
		var emitter: GPUParticles2D = hit_particles[key]
		emitter.global_position = pos
		emitter.restart()


# --- Screen Shake Logic ---
func _process_shake(delta: float) -> void:
	if shake_strength > 0.01:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		var offset = _random_shake_offset()
		# Apply the same offset to the camera and the UI layer
		camera.offset = offset
		ui_canvas_layer.offset = offset
	elif camera.offset != Vector2.ZERO: # Executes once when the shake ends
		shake_strength = 0
		camera.offset = Vector2.ZERO
		ui_canvas_layer.offset = Vector2.ZERO


func _random_shake_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))


# --- FEVER METER & MULTIPLIER LOGIC ---
func set_fever_meter(value: float, use_tween: bool):
	fever_meter = clamp(value, FEVER_METER_MIN, FEVER_METER_MAX)

	if use_tween:
		# --- CORRECTED LOGIC ---
		# Kill any previous animation to avoid conflicts
		if fever_bar_tween and fever_bar_tween.is_valid():
			fever_bar_tween.kill()

		# Create a new tween and store its reference
		fever_bar_tween = create_tween()
		fever_bar_tween.tween_property(fever_meter_bar, "value", fever_meter, 0.15).set_ease(Tween.EASE_OUT)
	else:
		# For decay, we don't directly set the bar value; we let the lerp handle it.
		# But if a tween was running, we kill it so the lerp can take over.
		if fever_bar_tween and fever_bar_tween.is_valid():
			fever_bar_tween.kill()

func _update_fever_state():
	var old_multiplier = score_multiplier
	if fever_meter >= SUPERNOVA_THRESHOLD: score_multiplier = 32
	elif fever_meter >= 80.0: score_multiplier = 16
	elif fever_meter >= 60.0: score_multiplier = 8
	elif fever_meter >= 40.0: score_multiplier = 4
	elif fever_meter >= 20.0: score_multiplier = 2
	else: score_multiplier = 1

	if old_multiplier != score_multiplier:
		_update_multiplier_tier_visuals()

	if fever_meter >= SUPERNOVA_THRESHOLD and not is_supernova_active:
		_activate_supernova(true)
	elif fever_meter < SUPERNOVA_THRESHOLD and is_supernova_active:
		_activate_supernova(false)

func _update_multiplier_tier_visuals():
	var active_color = Color(1, 0.84, 0.2, 1)
	var inactive_color = Color(0.4, 0.4, 0.4, 1)

	for tier_value in multiplier_tier_labels:
		var label = multiplier_tier_labels[tier_value]
		if score_multiplier >= tier_value:
			label.modulate = active_color
		else:
			label.modulate = inactive_color

func _activate_supernova(activate: bool):
	is_supernova_active = activate
	supernova_flame.visible = activate
	if activate:
		supernova_flame.play("default")
		if supernova_tween and supernova_tween.is_valid(): supernova_tween.kill()
		supernova_tween = create_tween().set_loops()
		supernova_tween.tween_property(fever_meter_bar, "self_modulate", Color.ORANGE_RED, 0.5).set_trans(Tween.TRANS_SINE)
		supernova_tween.tween_property(fever_meter_bar, "self_modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_SINE)
	else:
		supernova_flame.stop()
		if supernova_tween and supernova_tween.is_valid(): supernova_tween.kill()
		fever_meter_bar.self_modulate = Color.WHITE

func calculate_miss_penalty() -> int:
	if consecutive_misses == 0: return base_miss_penalty
	var penalty = base_miss_penalty * (2 ** (consecutive_misses - 1))
	return min(penalty, 32000)  # Cap the penalty at 32000

func _update_progression():
	var potential_tier_idx = 0; var potential_level_idx = 0; var found_level = false
	for i in range(progression_data.size() - 1, -1, -1):
		var tier = progression_data[i]
		var levels = tier["levels"]
		for j in range(levels.size() - 1, -1, -1):
			if total_score >= levels[j]["score_threshold"]:
				potential_tier_idx = i; potential_level_idx = j; found_level = true; break
		if found_level: break

	var final_tier_idx = max(potential_tier_idx, highest_tier_checkpoint_index)
	var final_level_idx = potential_level_idx
	if final_tier_idx > potential_tier_idx: final_level_idx = 0

	if final_tier_idx > highest_tier_checkpoint_index:
		highest_tier_checkpoint_index = final_tier_idx

	current_tier_index = final_tier_idx
	current_level_index = final_level_idx

	var checkpoint_score_floor = progression_data[highest_tier_checkpoint_index]["levels"][0]["score_threshold"]
	total_score = max(total_score, checkpoint_score_floor)

	_update_sword_texture()
	_update_tier_ui()


func _update_sword_texture():
	if not is_instance_valid(sword_display) or progression_data.is_empty(): return
	var tier_data = progression_data[current_tier_index]
	var level_data = tier_data["levels"][current_level_index]
	var texture_idx = level_data["texture_index"]
	if sword_state_textures.size() > texture_idx:
		var new_texture = sword_state_textures[texture_idx]
		if new_texture and sword_display.texture != new_texture:
			sword_display.texture = new_texture

func _update_tier_ui():
	if not is_instance_valid(tier_name_label): return
	var tier_data = progression_data[current_tier_index]
	tier_name_label.text = tier_data["name"]
	for i in range(level_bars.size()):
		var bar_label = level_bars[i]
		if i <= current_level_index: bar_label.label_settings = _settings_bar_active
		else: bar_label.label_settings = _settings_bar_inactive


func _update_ui():
	if not is_instance_valid(score_label): return
	score_label.text = "%d" % total_score

func _show_transition_feedback(text: String, color: Color):
	transition_feedback_label.text = text
	transition_feedback_label.modulate = color
	transition_feedback_label.visible = true
	transition_feedback_timer.start()

func _on_transition_feedback_timer_timeout():
	transition_feedback_label.visible = false
