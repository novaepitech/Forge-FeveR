# game.gd
extends Node2D

# Signal émis chaque fois qu'une note est jugée.
signal note_judged(judgment: String)

# --- Paramètres du jeu ---
const NoteScene = preload("res://scenes/note.tscn")
@export var lookahead_time: float = 2.0

@export_group("Timing Windows")
@export var timing_window_perfect: float = 0.04
@export var timing_window_good: float = 0.08
@export var timing_window_ok: float = 0.12

# --- Données du Chart ---
@export var chart_data: Array[float] = [
	# Section 1: Introduction (rythme lent et régulier)
	# 4 notes, intervalle de 1.0s
	2.0, 3.0, 4.0, 5.0,

	# Section 2: Montée vers le multiplicateur x2 (rythme medium)
	# Le 10ème combo est atteint sur la note à 8.5s. Intervalle de 0.5s.
	# C'est un rythme commun dans les jeux de rythme.
	6.0, 6.5, 7.0, 7.5, 8.0, 8.5,

	# Section 3: Progression vers le multiplicateur x3 (rythme un peu plus soutenu)
	# Le 20ème combo est atteint sur la note à 13.6s. Intervalle de 0.4s.
	# C'est plus rapide, mais beaucoup plus lisible que les 0.25s précédents.
	10.0, 10.4, 10.8, 11.2, 11.6,
	12.0, 12.4, 12.8, 13.2, 13.6,

	# Section 4: Sprint vers le multiplicateur x4 (le plus rapide, mais gérable)
	# Le 30ème combo est atteint sur la note à 18.0s. Intervalle de 0.25s en courtes rafales.
	# Les rafales sont séparées par une pause pour vous laisser respirer.
	15.0, 15.25, 15.5, 15.75, 16.0, # Première rafale
	17.0, 17.25, 17.5, 17.75, 18.0, # Seconde rafale

	# Section 5: Le "Piège à Combo" (rythme syncopé mais plus lent)
	# Conçu pour tester la rupture de combo sans être injuste.
	# Le rythme est volontairement cassé.
	20.0, 20.5, # Simple
	21.25,     # Note isolée après une pause plus longue
	22.0,      # Reprise

	# Section 6: Outro (retour à un rythme calme)
	# Intervalle de 0.5s pour finir en douceur.
	24.0, 24.5, 25.0, 25.5, 26.0, 26.5
]

# --- État du jeu ---
var song_position: float = 0.0
var next_note_index: int = 0
var active_notes: Array[Node] = []

# --- [NOUVEAU] Problème 1 : Gestion de l'état du joueur ---
var total_score: int = 0
var combo_counter: int = 0
var score_multiplier: int = 1

# --- [NOUVEAU] Problème 2 : Valeurs de points par jugement ---
const SCORE_VALUES = {
	"Perfect": 100,
	"Good": 50,
	"OK": 10,
	"Miss": 0
}

# --- [NOUVEAU] Problème 4 : Paliers du multiplicateur ---
const COMBO_THRESHOLD_1: int = 10
const COMBO_THRESHOLD_2: int = 20
const COMBO_THRESHOLD_3: int = 30
const COMBO_DISPLAY_THRESHOLD: int = 3 # Seuil d'affichage du combo

# --- Références aux Nœuds ---
@onready var spawn_pos: Vector2 = $SpawnPoint.global_position
@onready var target_pos: Vector2 = $TargetZone.global_position
# --- [NOUVEAU] Problème 6 : Références aux labels de l'interface ---
@onready var score_label: Label = $UI/ScoreLabel
@onready var combo_label: Label = $UI/ComboLabel
@onready var multiplier_label: Label = $UI/MultiplierLabel

func _ready():
	# Connexion du signal à la fonction de gestion du score
	note_judged.connect(_on_note_judged)
	# Initialisation de l'état et de l'UI au démarrage
	reset_game_state()

func reset_game_state():
	# --- Problème 1 : Contraintes initiales ---
	total_score = 0
	combo_counter = 0
	score_multiplier = 1

	song_position = 0.0
	next_note_index = 0

	# Mise à jour initiale de l'affichage
	_update_ui()

func _process(delta):
	song_position += delta

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

# --- [NOUVEAU] Fonction centrale pour la logique de score ---
func _on_note_judged(judgment: String):
	# --- Problème 3 : Mise à jour du compteur de combo ---
	match judgment:
		"Perfect", "Good":
			combo_counter += 1
		"OK":
			pass # Le combo n'est pas modifié
		"Miss":
			combo_counter = 0 # Le combo est brisé

	# --- Problème 4 : Mise à jour du multiplicateur ---
	_update_multiplier()

	# --- Problème 5 : Calcul du score final de la note ---
	var base_score = SCORE_VALUES.get(judgment, 0)
	if base_score > 0:
		var points_gained = base_score * score_multiplier
		total_score += points_gained

	# --- Problème 6 : Mise à jour de l'affichage ---
	_update_ui()
	print("Judgment: %s | Combo: %d | Multiplier: x%d | Score: %d" % [judgment, combo_counter, score_multiplier, total_score])

# --- [NOUVEAU] Fonction dédiée à la mise à jour du multiplicateur ---
func _update_multiplier():
	# --- Problème 4 : Logique de paliers ---
	if combo_counter >= COMBO_THRESHOLD_3:
		score_multiplier = 4
	elif combo_counter >= COMBO_THRESHOLD_2:
		score_multiplier = 3
	elif combo_counter >= COMBO_THRESHOLD_1:
		score_multiplier = 2
	else:
		score_multiplier = 1 # Valeur de base

# --- [NOUVEAU] Fonction dédiée à la mise à jour de l'interface ---
func _update_ui():
	# --- Problème 6 : Affichage des informations ---
	score_label.text = "Score: %d" % total_score
	multiplier_label.text = "x%d" % score_multiplier

	# Affichage conditionnel du compteur de combo
	if combo_counter >= COMBO_DISPLAY_THRESHOLD:
		combo_label.text = "%d\nCOMBO" % combo_counter
		combo_label.show()
	else:
		combo_label.hide()


# --- Logique de Jugement (inchangée) ---

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
