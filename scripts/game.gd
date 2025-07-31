# game.gd
extends Node2D

# (Problème 6) Signal émis chaque fois qu'une note est jugée.
# D'autres systèmes (UI, score) pourront s'y connecter.
signal note_judged(judgment: String)

# --- Paramètres du jeu ---
const NoteScene = preload("res://scenes/note.tscn")
@export var lookahead_time: float = 2.0

# (Problème 4) Définition des fenêtres de temps pour chaque jugement (en secondes).
# Une action est "Perfect" si l'écart est inférieur ou égal à cette valeur.
@export_group("Timing Windows")
@export var timing_window_perfect: float = 0.04
# "Good" si l'écart est > perfect mais <= good.
@export var timing_window_good: float = 0.08
# "OK" si l'écart est > good mais <= ok.
@export var timing_window_ok: float = 0.12


# --- Données du Chart ---
@export var chart_data: Array[float] = [2.0, 4.0, 5.0, 5.5, 6.0, 7.0, 8.5, 9.0]

# --- État du jeu ---
var song_position: float = 0.0
var next_note_index: int = 0

# (Problème 2) Liste pour suivre toutes les notes actuellement sur la piste.
var active_notes: Array[Node] = []

@onready var spawn_pos: Vector2 = $SpawnPoint.global_position
@onready var target_pos: Vector2 = $TargetZone.global_position


func _process(delta):
	song_position += delta
	
	while next_note_index < chart_data.size():
		var note_target_time = chart_data[next_note_index]
		if song_position >= note_target_time - lookahead_time:
			spawn_note(note_target_time)
			next_note_index += 1
		else:
			break

# (Problème 1) Capture de l'action du joueur.
# _unhandled_input est souvent préféré pour les actions de jeu.
func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("hit"):
		# Horodatage de l'action en utilisant notre horloge de jeu.
		var hit_time = song_position
		process_player_hit(hit_time)

# --- Logique de Jugement ---

func process_player_hit(hit_time: float):
	if active_notes.is_empty():
		return # Aucune note à frapper.

	# (Problème 2) Trouver la note la plus proche temporellement.
	var best_note: Node = active_notes[0]
	var min_diff = abs(best_note.target_time - hit_time)

	for i in range(1, active_notes.size()):
		var current_note = active_notes[i]
		var diff = abs(current_note.target_time - hit_time)
		if diff < min_diff:
			min_diff = diff
			best_note = current_note
	
	# (Problème 3) Calcul de l'écart de timing (la valeur brute).
	var timing_error = best_note.target_time - hit_time
	
	# (Problème 2 & 5.2) Vérifier si la note est "jouable". Si l'écart est trop grand,
	# on ignore l'input. La note sera éventuellement comptée "Miss" par omission.
	if abs(timing_error) > timing_window_ok:
		# On peut ajouter un son "d'erreur" ici si on veut.
		# L'action ne correspond à aucune note valide.
		return

	# (Problème 4) Traduction de l'écart en jugement qualitatif.
	var judgment: String
	var abs_error = abs(timing_error)
	
	if abs_error <= timing_window_perfect:
		judgment = "Perfect"
	elif abs_error <= timing_window_good:
		judgment = "Good"
	else: # Forcément <= timing_window_ok grâce au check précédent.
		judgment = "OK"

	# (Problème 6) Communiquer le résultat et terminer le cycle de vie de la note.
	print("Hit! Judgment: ", judgment, " | Error: ", timing_error, "s")
	emit_signal("note_judged", judgment)
	
	# La note a été jouée, on la retire de la liste des notes actives.
	active_notes.erase(best_note)
	# On dit à la note de disparaître.
	best_note.hit()


func spawn_note(target_time: float):
	var note_instance = NoteScene.instantiate()
	add_child(note_instance)
	note_instance.setup(target_time, self, spawn_pos, target_pos)

	# (Problème 2 & 6) On ajoute la nouvelle note à notre liste de suivi.
	active_notes.append(note_instance)
	# On se connecte à son signal "missed" pour savoir quand elle est manquée.
	note_instance.missed.connect(_on_note_missed.bind(note_instance))
	# print("Note instanciée pour t=", target_time, " à song_position=", song_position) # Décommenter pour debug

# (Problème 5.1) Gère le cas où une note est manquée par omission.
func _on_note_missed(note_missed: Node):
	# (Problème 6) Le cycle de vie de la note est terminé.
	print("Miss! Note for t=", note_missed.target_time, " was missed.")
	emit_signal("note_judged", "Miss")
	
	# On la retire de la liste pour qu'elle ne puisse plus être ciblée.
	if active_notes.has(note_missed):
		active_notes.erase(note_missed)
