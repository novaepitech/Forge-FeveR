extends Node2D

signal note_judged(judgment: String)

# --- Game Parameters ---
const NoteScene = preload("res://scenes/note.tscn")
@export var lookahead_time: float = 2.0

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
# The score thresholds required to reach the next visual state of the sword.
# Example: [10000, 25000, 50000] means:
# - State 1 ("Lame brute") is reached at 10,000 points.
# - State 2 ("Lame affûtée") is reached at 25,000 points.
# - State 3 ("Lame spectaculaire") is reached at 50,000 points.
@export var sword_score_thresholds: Array[int] = [10000, 25000, 50000]
# The textures for the sword's visual states.
# Must have one more element than the thresholds array.
# - Index 0: "Lingot" (initial state)
# - Index 1: "Lame brute"
# - etc.
@export var sword_state_textures: Array[Texture2D]


# --- Chart Data ---
@export var chart_data: Array[float] = [
	# Section 1: Introduction (slow and regular rhythm)
	# 4 notes, 1.0s interval
	2.0, 3.0, 4.0, 5.0,

	# Section 2: Progression to x2 multiplier (medium rhythm)
	# The 10th combo is reached on the note at 8.5s. 0.5s interval.
	# This is a common rhythm in rhythm games.
	6.0, 6.5, 7.0, 7.5, 8.0, 8.5,

	# Section 3: Progression to x3 multiplier (slightly faster rhythm)
	# The 20th combo is reached on the note at 13.6s. 0.4s interval.
	# This is faster, but much more readable than the previous 0.25s.
	10.0, 10.4, 10.8, 11.2, 11.6,
	12.0, 12.4, 12.8, 13.2, 13.6,

	# Section 4: Sprint to x4 multiplier (fastest, but manageable)
	# The 30th combo is reached on the note at 18.0s. 0.25s intervals in short bursts.
	# Bursts are separated by a pause to let you breathe.
	15.0, 15.25, 15.5, 15.75, 16.0, # First burst
	17.0, 17.25, 17.5, 17.75, 18.0, # Second burst

	# Section 5: The "Combo Trap" (syncopated but slower rhythm)
	# Designed to test combo breaking without being unfair.
	# The rhythm is intentionally broken.
	20.0, 20.5, # Simple
	21.25,     # Isolated note after a longer pause
	22.0,      # Resumption

	# Section 6: Outro (return to a calm rhythm)
	# 0.5s interval to finish smoothly.
	24.0, 24.5, 25.0, 25.5, 26.0, 26.5
]

# --- Game State ---
var song_position: float = 0.0
var next_note_index: int = 0
var active_notes: Array[Node] = []

var total_score: int = 0
var score_multiplier: int = 1

var fever_meter: float = 0.0
var current_sword_state_index: int = 0

# Miss penalty system
var consecutive_misses: int = 0
var base_miss_penalty: int = 500

const SCORE_VALUES = {
	"Perfect": 1000,
	"Good": 250,
	"OK": 50,
	"Miss": 0
}

# --- Node References ---
@onready var spawn_pos: Vector2 = $SpawnPoint.global_position
@onready var target_pos: Vector2 = $TargetZone.global_position
@onready var score_label: Label = $UI/ScoreLabel
@onready var multiplier_label: Label = $UI/MultiplierLabel
@onready var fever_meter_bar: ProgressBar = $UI/FeverMeterBar
@onready var sword_display: Sprite2D = $SwordDisplay

func _ready():
	note_judged.connect(_on_note_judged)
	reset_game_state()

func reset_game_state():
	total_score = 0
	score_multiplier = 1
	set_fever_meter(FEVER_METER_MIN)
	consecutive_misses = 0

	song_position = 0.0
	next_note_index = 0

	# Reset sword to its initial state ("Lingot")
	current_sword_state_index = 0
	if is_instance_valid(sword_display):
		sword_display.visible = true
		if not sword_state_textures.is_empty() and sword_state_textures[0]:
			sword_display.texture = sword_state_textures[0]
		else:
			# Hide the sprite if no textures are configured to avoid showing a white box
			sword_display.visible = false
			print("Warning: Sword textures are not configured. Hiding SwordDisplay.")

	_update_ui()

func _process(delta):
	song_position += delta

	if fever_meter > FEVER_METER_MIN:
		set_fever_meter(fever_meter - fever_decay_rate * delta)

	while next_note_index < chart_data.size():
		var note_target_time = chart_data[next_note_index]
		if song_position >= note_target_time - lookahead_time:
			spawn_note(note_target_time)
			next_note_index += 1
		else:
			break

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("hit"):
		var hit_time = song_position
		process_player_hit(hit_time)

# Handles value clamping and UI updates.
func set_fever_meter(value: float):
	fever_meter = clamp(value, FEVER_METER_MIN, FEVER_METER_MAX)
	if is_instance_valid(fever_meter_bar):
		fever_meter_bar.value = fever_meter

# Calculate the miss penalty based on consecutive misses
func calculate_miss_penalty() -> int:
	if consecutive_misses == 0:
		return base_miss_penalty
	# Each miss doubles the penalty: -500, -1000, -2000, -4000, etc.
	return base_miss_penalty * (2 ** (consecutive_misses - 1))

# Core function for score logic, now based on the Fever Meter.
func _on_note_judged(judgment: String):
	match judgment:
		"Perfect":
			set_fever_meter(fever_meter + fever_gain_perfect)
			# Reset consecutive misses when hitting a note
			consecutive_misses = 0
		"Good", "OK":
			set_fever_meter(fever_meter - fever_penalty_imperfect)
			# Reset consecutive misses when hitting a note
			consecutive_misses = 0
		"Miss":
			set_fever_meter(FEVER_METER_MIN)
			# Increment consecutive misses and apply penalty
			consecutive_misses += 1
			var miss_penalty = calculate_miss_penalty()
			total_score -= miss_penalty
			# Ensure score doesn't go below 0
			if total_score < 0:
				total_score = 0

	_update_multiplier()

	var base_score = SCORE_VALUES.get(judgment, 0)
	if base_score > 0:
		var points_gained = base_score * score_multiplier
		total_score += points_gained
		# Check if the score update triggered a sword evolution
		_update_sword_visual()

	# On "Miss", we must also reset the multiplier to 1 immediately.
	# The GDD says it's instant, so let's ensure that.
	if judgment == "Miss":
		score_multiplier = 1

	_update_ui()

	# Enhanced debug output to show miss penalty information
	if judgment == "Miss":
		var miss_penalty = calculate_miss_penalty()
		print("Judgment: %s | Miss Penalty: -%d | Consecutive Misses: %d | Fever: %.1f | Multiplier: x%d | Score: %d" % [judgment, miss_penalty, consecutive_misses, fever_meter, score_multiplier, total_score])
	else:
		print("Judgment: %s | Fever: %.1f | Multiplier: x%d | Score: %d" % [judgment, fever_meter, score_multiplier, total_score])

# Checks if the current score has unlocked a new visual state for the sword.
# This progression is permanent for the duration of the run (non-regression).
func _update_sword_visual():
	# Determine the highest state we currently qualify for based on score
	var target_state_index = 0
	for i in range(sword_score_thresholds.size()):
		if total_score >= sword_score_thresholds[i]:
			# The threshold array index `i` corresponds to the visual state `i + 1`.
			# State 0 is the default.
			target_state_index = i + 1
		else:
			# Since thresholds are sorted, we can stop early.
			break

	# Non-regression: Only update if we've reached a NEW, higher state.
	if target_state_index > current_sword_state_index:
		current_sword_state_index = target_state_index

		# Update the visual if possible
		if is_instance_valid(sword_display) and sword_state_textures.size() > current_sword_state_index:
			var new_texture = sword_state_textures[current_sword_state_index]
			if new_texture:
				sword_display.texture = new_texture
			else:
				print("Warning: Texture for sword state index %d is not set." % current_sword_state_index)


# Function dedicated to updating the multiplier.
func _update_multiplier():
	if fever_meter >= 95.0:
		score_multiplier = 32 # Supernova Forge
	elif fever_meter >= 80.0:
		score_multiplier = 16
	elif fever_meter >= 60.0:
		score_multiplier = 8
	elif fever_meter >= 40.0:
		score_multiplier = 4
	elif fever_meter >= 20.0:
		score_multiplier = 2
	else:
		score_multiplier = 1

# Function dedicated to updating the UI.
func _update_ui():
	score_label.text = "%d" % total_score
	multiplier_label.text = "x%d" % score_multiplier

# --- Judgment Logic (unchanged) ---

func process_player_hit(hit_time: float):
	if active_notes.is_empty():
		return

	var best_note: Node = active_notes[0]
	var min_diff = abs(best_note.target_time - hit_time)

	for i in range(1, active_notes.size()):
		var current_note = active_notes[i]
		var diff = abs(current_note.target_time - hit_time)
		if diff < min_diff:
			min_diff = diff
			best_note = current_note

	var timing_error = best_note.target_time - hit_time

	if abs(timing_error) > timing_window_ok:
		return

	var judgment: String
	var abs_error = abs(timing_error)

	if abs_error <= timing_window_perfect:
		judgment = "Perfect"
	elif abs_error <= timing_window_good:
		judgment = "Good"
	else:
		judgment = "OK"

	emit_signal("note_judged", judgment)

	active_notes.erase(best_note)
	best_note.hit()

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
