extends Node2D

signal note_judged(judgment: String, track_id: int, score_change: int, is_empowered_perfect: bool)

# --- Game Parameters ---
const NoteScene = preload("res://scenes/note.tscn")
@export var lookahead_time: float = 2.0
@export var track_y_positions: Array[float] = [440.0, 490.0, 540.0]

# --- Audio Parameters ---
const VOLUME_AUDIBLE_DB: float = 0.0
const VOLUME_MUTED_DB: float = -80.0

# --- Loop & Chart Parameters ---
const LOOP_DURATION: float = 24.0
const EVALUATION_TIME: float = 21.0

@export_group("Timing Windows")
@export var timing_window_perfect: float = 0.04
@export var timing_window_good: float = 0.08
@export var timing_window_ok: float = 0.12

@export_group("Fever Meter Settings")
@export var fever_gain_perfect: float = 10.0
@export var fever_penalty_imperfect: float = 5.0
@export var fever_decay_rate: float = 2.5

const FEVER_METER_MIN: float = 0.0
const FEVER_METER_MAX: float = 100.0

@export_group("Sword Progression")
@export var sword_score_thresholds: Array[int] = [65000, 150000, 450000, 800000]
@export var sword_state_textures: Array[Texture2D]

@export_group("Checkpoints")
@export var score_checkpoints: Array[int] = [100000, 600000, 800000]

# The game will combine charts from level 0 up to the current level.
# Charts are timed for 160 BPM (0.375s per beat, 1.5s per 4/4 measure).
var all_charts: Dictionary = {
	# Level 0 (Easiest: One note every two measures, on the downbeat)
	0: [
		{"time": 2.0, "track": 1},
		{"time": 5.0, "track": 2},
		{"time": 8.0, "track": 1},
		{"time": 11.0, "track": 2},
		{"time": 14.0, "track": 1},
		{"time": 17.0, "track": 2},
		{"time": 19.0, "track": 2}
	],
	# Level 1 (Fills in the other downbeats for a one-note-per-measure feel)
	1: [
		{"time": 0, "track": 3}, # Since the level zero had to start at 2.0 for a "grace period"
		{"time": 6.5, "track": 1},
		{"time": 9.5, "track": 3},
		{"time": 12.5, "track": 1},
		{"time": 15.5, "track": 3},
		{"time": 18.5, "track": 1}
	],
	# Level 2 (Adds notes on the 3rd beat of each measure - a simple quarter-note pulse)
	2: [
		{"time": 2.75, "track": 2},
		{"time": 5.75, "track": 1},
		{"time": 8.75, "track": 3},
		{"time": 11.75, "track": 1},
		{"time": 14.75, "track": 2},
		{"time": 17.75, "track": 3}
	],
	# Level 3 (Adds a few extra quarter notes and two simple eighth-note flourishes)
	3: [
		{"time": 4.25, "track": 2},  # Quarter note
		{"time": 5.375, "track": 1}, # Eighth note after 5.0 note
		{"time": 10.25, "track": 2}, # Quarter note
		{"time": 14.375, "track": 1},# Eighth note after 14.0 note
		{"time": 16.25, "track": 3}, # Quarter note
		{"time": 19.25, "track": 2}  # Quarter note
	]
}

var MAX_LEVEL: int
var song_position: float = 0.0
var active_notes: Array[Node] = []
var total_score: int = 0
var score_multiplier: int = 1
var fever_meter: float = 0.0
var current_sword_state_index: int = 0
var highest_checkpoint_reached: int = 0
var consecutive_misses: int = 0
var base_miss_penalty: int = 500
const SCORE_VALUES = { "Perfect": 1000, "Good": 250, "OK": 50, "Miss": 0 }
const EMPOWERED_BONUS = 1500

# --- Loop State ---
var loop_position: float = 0.0
var last_loop_position: float = 0.0
var current_loop_start_time: float = 0.0
var current_level: int = 0 # Difficulty of notes being played
var next_level: int = 0
var notes_in_current_loop: int = 0
var notes_hit_in_current_loop: int = 0
var current_loop_spawn_indices: Dictionary = {}
var next_loop_spawn_indices: Dictionary = {}

# --- State Variables for Music Start & Sync ---
var music_started: bool = false
var active_music_level: int = 0 # Which music layers are audible
var is_awaiting_level_sync_hit: bool = false # Flag for pending music level-up

# --- Node References ---
@onready var spawn_pos_marker: Marker2D = $SpawnPoint
@onready var target_pos_marker: Marker2D = $TargetZone
@onready var score_label: Label = $UI/ScoreLabel
@onready var multiplier_label: Label = $UI/MultiplierLabel
@onready var fever_meter_bar: ProgressBar = $UI/FeverMeterBar
@onready var sword_display: Sprite2D = $SwordDisplay

# --- Audio Node References ---
@onready var music_layers: Dictionary = {
	0: $MusicLayers/MusicLayer1, # Base track
	1: $MusicLayers/MusicLayer2, # First additional layer
	2: $MusicLayers/MusicLayer3  # Second additional layer
}
@onready var sfx_perfect: AudioStreamPlayer = $SFX/SfxPerfect
@onready var sfx_imperfect: AudioStreamPlayer = $SFX/SfxImperfect
@onready var sfx_miss: AudioStreamPlayer = $SFX/SfxMiss
@onready var sfx_level_up: AudioStreamPlayer = $SFX/SfxLevelUp
@onready var sfx_level_down: AudioStreamPlayer = $SFX/SfxLevelDown
@onready var loop_time_label: Label = $UI/LoopTimeLabel


func _ready():
	MAX_LEVEL = all_charts.keys().max()
	reset_game_state()
	_initialize_audio()


func reset_game_state():
	if is_node_ready():
		for player in music_layers.values(): player.stop()

	music_started = false
	active_music_level = 0
	is_awaiting_level_sync_hit = false

	total_score = 0
	score_multiplier = 1
	set_fever_meter(FEVER_METER_MIN)
	consecutive_misses = 0
	highest_checkpoint_reached = 0
	song_position = 0.0

	for note in active_notes:
		if is_instance_valid(note): note.queue_free()
	active_notes.clear()

	loop_position = 0.0
	last_loop_position = 0.0
	current_loop_start_time = 0.0
	current_level = 0
	next_level = 0
	current_loop_spawn_indices.clear()
	next_loop_spawn_indices.clear()

	_prepare_for_new_loop()

	current_sword_state_index = 0
	if is_instance_valid(sword_display):
		sword_display.visible = true
		if not sword_state_textures.is_empty() and sword_state_textures[0]:
			sword_display.texture = sword_state_textures[0]
		else:
			sword_display.visible = false
	_update_ui()

	if is_node_ready():
		_update_music_volume()


# --- Audio Management Functions ---
func _initialize_audio():
	for level in music_layers:
		music_layers[level].volume_db = VOLUME_MUTED_DB


func _trigger_forge_start(note_target_time: float):
	music_started = true
	print("FORGE START! Music triggered by player. Resyncing clock.")

	for player in music_layers.values():
		player.play()

	song_position = note_target_time

	# The initial music level is set here.
	active_music_level = current_level
	_update_music_volume()


# --- MODIFIED: Uses active_music_level instead of current_level ---
func _update_music_volume():
	if not music_started:
		return

	# The audible music is now controlled by its own state variable.
	for level in music_layers:
		var player = music_layers[level]
		if level <= active_music_level:
			player.volume_db = VOLUME_AUDIBLE_DB
		else:
			player.volume_db = VOLUME_MUTED_DB


# --- Main Game Loop ---
func _process(delta):
	song_position += delta
	loop_position = fmod(song_position, LOOP_DURATION)

	if loop_position < last_loop_position:
		_on_loop_tick()

	if last_loop_position < EVALUATION_TIME and loop_position >= EVALUATION_TIME:
		_evaluate_performance()

	_spawn_notes_from_active_charts()

	if fever_meter > FEVER_METER_MIN:
		set_fever_meter(fever_meter - fever_decay_rate * delta)

	last_loop_position = loop_position
	loop_time_label.text = "[DEBUG] Loop: %.2fs" % loop_position # Update loop time display


# --- MODIFIED: Implements delayed music level-up ---
func _on_loop_tick():
	print("--- LOOP TICK --- Note Level: %d, Music Level: %d" % [next_level, active_music_level])
	var loops_passed = floor(song_position / LOOP_DURATION)
	current_loop_start_time = loops_passed * LOOP_DURATION

	var old_level = current_level
	current_level = next_level

	# GDD Compliance: Logic for music level transition
	if current_level > old_level:
		# LEVEL UP: Don't change the music yet. Set a flag to wait for the player's hit.
		is_awaiting_level_sync_hit = true
		print("Awaiting player hit to sync music to level %d" % current_level)
	else:
		# STAY or LEVEL DOWN: Music can change immediately.
		if active_music_level != current_level:
			active_music_level = current_level
			_update_music_volume()

	current_loop_spawn_indices = next_loop_spawn_indices.duplicate(true)
	next_loop_spawn_indices.clear()
	_prepare_for_new_loop()


func _evaluate_performance():
	var success_rate: float = 0.0
	if notes_in_current_loop > 0:
		success_rate = float(notes_hit_in_current_loop) / float(notes_in_current_loop)
	else:
		success_rate = 1.0

	var old_next_level = next_level
	if success_rate >= 1.0:
		next_level = min(current_level + 1, MAX_LEVEL)
		print("EVAL: LEVEL UP!")
	elif success_rate >= 0.8:
		next_level = current_level
		print("EVAL: STAY!")
	else:
		next_level = max(current_level - 1, 0)
		print("EVAL: LEVEL DOWN!")

	if next_level > old_next_level:
		sfx_level_up.play()
	elif next_level < old_next_level:
		sfx_level_down.play()

	if next_level != old_next_level:
		next_loop_spawn_indices.clear()


# --- Spawning Logic (Unchanged) ---
func _prepare_for_new_loop():
	notes_in_current_loop = 0
	for level_idx in range(current_level + 1):
		notes_in_current_loop += all_charts.get(level_idx, []).size()
	notes_hit_in_current_loop = 0


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
					spawn_note(note_time_absolute, note_data.track)
					spawn_idx += 1
				else:
					break
			spawn_indices[level_idx] = spawn_idx

	spawn_helper.call(0, current_level, current_loop_spawn_indices, current_loop_start_time)
	spawn_helper.call(0, next_level, next_loop_spawn_indices, current_loop_start_time + LOOP_DURATION)


func spawn_note(target_time: float, track_id: int):
	var note_instance = NoteScene.instantiate()
	add_child(note_instance)
	var y_pos = track_y_positions[track_id - 1]
	var spawn_for_track = Vector2(spawn_pos_marker.global_position.x, y_pos)
	var target_for_track = Vector2(target_pos_marker.global_position.x, y_pos)
	note_instance.setup(target_time, self, spawn_for_track, target_for_track, track_id)
	active_notes.append(note_instance)
	note_instance.missed.connect(_on_note_missed.bind(note_instance))


# --- Input and Judgment (Unchanged) ---
func _unhandled_input(_event: InputEvent):
	var hit_time = song_position
	if Input.is_action_just_pressed("hit_track1"): process_player_hit(hit_time, 1)
	elif Input.is_action_just_pressed("hit_track2"): process_player_hit(hit_time, 2)
	elif Input.is_action_just_pressed("hit_track3"): process_player_hit(hit_time, 3)

# --- MODIFIED: Checks flag to trigger music level-up ---
func process_player_hit(hit_time: float, track_id: int):
	var best_note_on_track: Node = null
	var min_diff = timing_window_ok + 0.1
	for note in active_notes:
		if note.track_id == track_id:
			var diff = abs(note.target_time - hit_time)
			if diff < min_diff:
				min_diff = diff
				best_note_on_track = note
	if best_note_on_track == null or min_diff > timing_window_ok:
		return

	if not music_started:
		_trigger_forge_start(best_note_on_track.target_time)
		hit_time = song_position
	# --- GDD Compliance: Player's hit triggers the new music layer ---
	elif is_awaiting_level_sync_hit:
		active_music_level = current_level
		_update_music_volume()
		is_awaiting_level_sync_hit = false # Reset flag
		print("Music synced to level %d by player action!" % active_music_level)

	var timing_error = best_note_on_track.target_time - hit_time
	var judgment: String
	var abs_error = abs(timing_error)
	if abs_error <= timing_window_perfect: judgment = "Perfect"
	elif abs_error <= timing_window_good: judgment = "Good"
	else: judgment = "OK"

	var score_change = SCORE_VALUES.get(judgment, 0)
	var is_empowered_perfect = (judgment == "Perfect" and best_note_on_track.is_empowered)
	if is_empowered_perfect:
		score_change += EMPOWERED_BONUS

	_on_note_judged(judgment, track_id, score_change, is_empowered_perfect)

	active_notes.erase(best_note_on_track)
	best_note_on_track.hit()

func _on_note_missed(note_missed: Node):
	if active_notes.has(note_missed):
		active_notes.erase(note_missed)
	_on_note_judged("Miss", note_missed.track_id, 0, false)


func _on_note_judged(judgment: String, track_id: int, score_change: int, is_empowered_perfect: bool):
	match judgment:
		"Perfect":
			notes_hit_in_current_loop += 1
			set_fever_meter(fever_meter + fever_gain_perfect)
			consecutive_misses = 0
			sfx_perfect.play()
		"Good", "OK":
			notes_hit_in_current_loop += 1
			set_fever_meter(fever_meter - fever_penalty_imperfect)
			consecutive_misses = 0
			sfx_imperfect.play()
		"Miss":
			set_fever_meter(FEVER_METER_MIN)
			consecutive_misses += 1
			sfx_miss.play()
			# GDD Compliance: If a level-up was pending, a miss cancels it.
			# The music stays at the lower level for the repeated loop.
			if is_awaiting_level_sync_hit:
				is_awaiting_level_sync_hit = false

	_update_multiplier()
	if judgment == "Miss":
		score_multiplier = 1

	var final_score_change = 0
	if judgment == "Miss":
		final_score_change = -calculate_miss_penalty()
	else:
		final_score_change = score_change * score_multiplier

	total_score += final_score_change
	if final_score_change > 0:
		for checkpoint_score in score_checkpoints:
			if total_score >= checkpoint_score and checkpoint_score > highest_checkpoint_reached:
				highest_checkpoint_reached = checkpoint_score

	total_score = max(total_score, highest_checkpoint_reached)
	_update_sword_visual()
	_update_ui()


# --- UI and Scoring Helpers (Unchanged) ---
func set_fever_meter(value: float):
	fever_meter = clamp(value, FEVER_METER_MIN, FEVER_METER_MAX)
	if is_instance_valid(fever_meter_bar): fever_meter_bar.value = fever_meter

func calculate_miss_penalty() -> int:
	if consecutive_misses == 0: return base_miss_penalty
	return base_miss_penalty * (2 ** (consecutive_misses - 1))

func _update_sword_visual():
	var required_state_index = 0
	for i in range(sword_score_thresholds.size()):
		if total_score >= sword_score_thresholds[i]: required_state_index = i + 1
		else: break
	if required_state_index != current_sword_state_index:
		current_sword_state_index = required_state_index
		if is_instance_valid(sword_display) and sword_state_textures.size() > current_sword_state_index:
			var new_texture = sword_state_textures[current_sword_state_index]
			if new_texture: sword_display.texture = new_texture

func _update_multiplier():
	if fever_meter >= 95.0: score_multiplier = 32
	elif fever_meter >= 80.0: score_multiplier = 16
	elif fever_meter >= 60.0: score_multiplier = 8
	elif fever_meter >= 40.0: score_multiplier = 4
	elif fever_meter >= 20.0: score_multiplier = 2
	else: score_multiplier = 1

func _update_ui():
	if not is_instance_valid(score_label): return
	score_label.text = "%d" % total_score
	multiplier_label.text = "x%d" % score_multiplier
