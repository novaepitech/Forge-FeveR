extends Node2D

signal note_judged(judgment: String)

# --- Game Parameters ---
const NoteScene = preload("res://scenes/note.tscn")
@export var lookahead_time: float = 2.0

# --- Loop & Chart Parameters ---
const LOOP_DURATION: float = 20.0
const EVALUATION_TIME: float = 17.0

@export_group("Timing Windows")
@export var timing_window_perfect: float = 0.04
@export var timing_window_good: float = 0.08
@export var timing_window_ok: float = 0.12

@export_group("Fever Meter Settings")
@export var fever_gain_perfect: float = 10.0
@export var fever_penalty_imperfect: float = 5.0
@export var fever_decay_rate: float = 2.5 # Units per second

const FEVER_METER_MIN: float = 0.0
const FEVER_METER_MAX: float = 100.0

@export_group("Sword Progression")
@export var sword_score_thresholds: Array[int] = [75000, 250000, 550000, 900000]
@export var sword_state_textures: Array[Texture2D]

@export_group("Checkpoints")
@export var score_checkpoints: Array[int] = [100000, 600000, 800000]

# --- Chart Data Structure ---
# Each key is a difficulty level.
# Note timings are relative to the start of the 20-second loop.
# All notes must end before EVALUATION_TIME (17s) to allow for the transition phase.
var all_charts: Dictionary = {
	1: [2.0, 3.5, 5.0, 6.5, 8.0, 9.5, 11.0, 12.5, 14.0, 15.5],
	2: [1.0, 2.0, 3.0, 4.0, 4.5, 5.0, 6.0, 7.0, 8.0, 8.5, 9.0, 10.0, 11.0, 12.0, 12.5, 13.0, 14.0, 15.0, 16.0, 16.5],
	3: [1.0, 1.5, 2.0, 2.75, 3.5, 4.25, 5.0, 5.5, 6.0, 6.5, 7.0, 8.0, 8.25, 8.5, 8.75, 9.0, 10.0, 10.5, 11.0, 11.75, 12.5, 13.25, 14.0, 14.5, 15.0, 15.5, 16.0]
}

var MAX_LEVEL: int

# --- Game State ---
var song_position: float = 0.0 # Continuous time, never resets.
var active_notes: Array[Node] = []

var total_score: int = 0
var score_multiplier: int = 1

var fever_meter: float = 0.0
var current_sword_state_index: int = 0
var highest_checkpoint_reached: int = 0

var consecutive_misses: int = 0
var base_miss_penalty: int = 500

const SCORE_VALUES = { "Perfect": 1000, "Good": 250, "OK": 50, "Miss": 0 }

# --- Loop-specific State ---
var loop_position: float = 0.0           # Current time within the 0-20s loop.
var last_loop_position: float = 0.0      # loop_position from the previous frame, to detect wrapping.
var current_loop_start_time: float = 0.0 # Absolute song_position where the current loop began.

var current_level: int = 1               # The difficulty level the player is currently playing.
var next_level: int = 1                  # The difficulty level for the *next* loop.

# Intra-loop performance counters, reset every loop.
var notes_in_current_loop: int = 0
var notes_hit_in_current_loop: int = 0

# Spawner indices for the current and next chart.
var current_level_spawn_idx: int = 0
var next_level_spawn_idx: int = 0

# --- Node References ---
@onready var spawn_pos: Vector2 = $SpawnPoint.global_position
@onready var target_pos: Vector2 = $TargetZone.global_position
@onready var score_label: Label = $UI/ScoreLabel
@onready var multiplier_label: Label = $UI/MultiplierLabel
@onready var fever_meter_bar: ProgressBar = $UI/FeverMeterBar
@onready var sword_display: Sprite2D = $SwordDisplay

func _ready():
	MAX_LEVEL = all_charts.size()

	note_judged.connect(_on_note_judged)
	reset_game_state()

func reset_game_state():
	# Reset core stats
	total_score = 0
	score_multiplier = 1
	set_fever_meter(FEVER_METER_MIN)
	consecutive_misses = 0
	highest_checkpoint_reached = 0

	# Reset time and active notes
	song_position = 0.0
	for note in active_notes:
		if is_instance_valid(note): note.queue_free()
	active_notes.clear()

	# Reset Loop State
	loop_position = 0.0
	last_loop_position = 0.0
	current_loop_start_time = 0.0
	current_level = 1
	next_level = 1
	current_level_spawn_idx = 0
	next_level_spawn_idx = 0

	_prepare_for_new_loop()

	# Reset visuals
	current_sword_state_index = 0
	if is_instance_valid(sword_display):
		sword_display.visible = true
		if not sword_state_textures.is_empty() and sword_state_textures[0]:
			sword_display.texture = sword_state_textures[0]
		else:
			sword_display.visible = false
	_update_ui()

func _process(delta):
	# --- 1. TIMEKEEPING ---
	# song_position grows infinitely, ensuring note spawning and movement are continuous.
	song_position += delta
	# loop_position gives us our place within the 20-second cycle for event triggers.
	loop_position = fmod(song_position, LOOP_DURATION)

	# --- 2. LOOP TRANSITION LOGIC (The "Tick") ---
	# Detects when the loop has just wrapped around from ~20.0 back to ~0.0.
	if loop_position < last_loop_position:
		_on_loop_tick()

	# --- 3. PERFORMANCE EVALUATION ---
	# Triggers exactly once per loop when the loop time crosses EVALUATION_TIME.
	if last_loop_position < EVALUATION_TIME and loop_position >= EVALUATION_TIME:
		_evaluate_performance()

	# --- 4. NOTE SPAWNING ---
	_spawn_notes_from_active_charts()

	# --- 5. FEVER DECAY & HOUSEKEEPING ---
	if fever_meter > FEVER_METER_MIN:
		set_fever_meter(fever_meter - fever_decay_rate * delta)

	# Store the current loop position for the next frame's comparison.
	last_loop_position = loop_position

# --- Main Loop Logic Functions ---

func _on_loop_tick():
	# This function is called precisely at the start of a new loop.
	print("--- LOOP TICK --- New Level: %d" % next_level)
	current_loop_start_time += LOOP_DURATION
	current_level = next_level

	# The spawner index for the *current* level is now reset.
	# The spawner index for the *next* level carries over, as it may have already
	# spawned anticipatory notes.
	current_level_spawn_idx = 0

	# Prepare counters for the new loop that has just begun.
	_prepare_for_new_loop()

func _evaluate_performance():
	# Calculate success rate for the loop that is about to end.
	var success_rate: float = 0.0
	if notes_in_current_loop > 0:
		success_rate = float(notes_hit_in_current_loop) / float(notes_in_current_loop)
	else:
		success_rate = 1.0 # No notes means perfect performance by default.

	# Determine the next level based on GDD rules.
	var old_next_level = next_level
	if success_rate >= 1.0: # 100% -> Level Up
		next_level = min(current_level + 1, MAX_LEVEL)
		print("EVAL: LEVEL UP! (100%)")
	elif success_rate >= 0.8: # 80-99% -> Stay
		next_level = current_level
		print("EVAL: STAY! (%.0f%%)" % (success_rate * 100))
	else: # <80% -> Level Down
		next_level = max(current_level - 1, 1)
		print("EVAL: LEVEL DOWN! (%.0f%%)" % (success_rate * 100))

	# If our target for the next loop has changed, we must reset its spawner index.
	if next_level != old_next_level:
		next_level_spawn_idx = 0

func _prepare_for_new_loop():
	# Sets up the counters for the currently active loop.
	var chart = all_charts.get(current_level, [])
	notes_in_current_loop = chart.size()
	notes_hit_in_current_loop = 0

# --- Spawner Logic ---

func _spawn_notes_from_active_charts():
	# Spawner for CURRENT level's chart
	var current_chart = all_charts.get(current_level, [])
	while current_level_spawn_idx < current_chart.size():
		var note_time_relative = current_chart[current_level_spawn_idx]
		var note_time_absolute = note_time_relative + current_loop_start_time
		if song_position >= note_time_absolute - lookahead_time:
			spawn_note(note_time_absolute)
			current_level_spawn_idx += 1
		else:
			break # Notes are sorted, no need to check further.

	# Spawner for NEXT level's chart (for anticipation)
	var next_chart = all_charts.get(next_level, [])
	while next_level_spawn_idx < next_chart.size():
		var note_time_relative = next_chart[next_level_spawn_idx]
		# The crucial difference: the time offset is for the *next* loop.
		var note_time_absolute = note_time_relative + (current_loop_start_time + LOOP_DURATION)
		if song_position >= note_time_absolute - lookahead_time:
			spawn_note(note_time_absolute)
			next_level_spawn_idx += 1
		else:
			break # Notes are sorted, no need to check further.

# --- Core Gameplay Logic (with minor adjustments) ---

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("hit"):
		# The hit time must be the absolute song position to correctly judge against notes.
		var hit_time = song_position
		process_player_hit(hit_time)

func _on_note_judged(judgment: String):
	# --- 1. Update Intra-Loop Performance & Fever ---
	match judgment:
		"Perfect":
			notes_hit_in_current_loop += 1
			set_fever_meter(fever_meter + fever_gain_perfect)
			consecutive_misses = 0
		"Good", "OK":
			notes_hit_in_current_loop += 1
			set_fever_meter(fever_meter - fever_penalty_imperfect)
			consecutive_misses = 0
		"Miss":
			set_fever_meter(FEVER_METER_MIN)
			consecutive_misses += 1

	# --- 2. Update Multiplier ---
	_update_multiplier()
	if judgment == "Miss": score_multiplier = 1

	# --- 3. Update Score ---
	var score_change = 0
	if judgment == "Miss":
		score_change = -calculate_miss_penalty()
	else:
		score_change = SCORE_VALUES.get(judgment, 0) * score_multiplier
	total_score += score_change

	# Check and apply checkpoints
	if score_change > 0:
		for checkpoint_score in score_checkpoints:
			if total_score >= checkpoint_score and checkpoint_score > highest_checkpoint_reached:
				highest_checkpoint_reached = checkpoint_score
	total_score = max(total_score, highest_checkpoint_reached)

	# --- 4. Update Visuals ---
	_update_sword_visual()
	_update_ui()

func spawn_note(target_time: float):
	var note_instance = NoteScene.instantiate()
	add_child(note_instance)
	note_instance.setup(target_time, self, spawn_pos, target_pos)
	active_notes.append(note_instance)
	note_instance.missed.connect(_on_note_missed.bind(note_instance))

func _on_note_missed(note_missed: Node):
	emit_signal("note_judged", "Miss")
	if active_notes.has(note_missed):
		active_notes.erase(note_missed)

func process_player_hit(hit_time: float):
	if active_notes.is_empty(): return
	var best_note: Node = active_notes[0]
	var min_diff = abs(best_note.target_time - hit_time)
	for i in range(1, active_notes.size()):
		var current_note = active_notes[i]
		var diff = abs(current_note.target_time - hit_time)
		if diff < min_diff:
			min_diff = diff
			best_note = current_note
	var timing_error = best_note.target_time - hit_time
	if abs(timing_error) > timing_window_ok: return
	var judgment: String
	var abs_error = abs(timing_error)
	if abs_error <= timing_window_perfect: judgment = "Perfect"
	elif abs_error <= timing_window_good: judgment = "Good"
	else: judgment = "OK"
	emit_signal("note_judged", judgment)
	active_notes.erase(best_note)
	best_note.hit()

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
	score_label.text = "%d" % total_score
	multiplier_label.text = "x%d" % score_multiplier
