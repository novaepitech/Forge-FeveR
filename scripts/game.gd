# game.gd
extends Node2D

# --- Paramètres du jeu ---

# Pré-chargez la scène de la note. C'est plus efficace que de la charger à chaque fois.
const NoteScene = preload("res://note.tscn")

# (Problème 1.3) Durée en secondes que met une note pour aller du SpawnPoint à la TargetZone.
@export var lookahead_time: float = 2.0

# --- Données du Chart ---

# (Problème 1.4) Notre structure de données pour la séquence de notes.
# Ce sont les timestamps (en secondes) où les notes doivent atteindre la TargetZone.
@export var chart_data: Array[float] = [2.0, 3.0, 3.5, 4.0, 5.0, 5.25, 5.5, 6.0]

# --- État du jeu ---

# Le temps actuel de la "chanson", en secondes. C'est le chronomètre principal du jeu.
var song_position: float = 0.0

# Un "curseur" pour savoir quelle est la prochaine note à instancier dans le chart.
var next_note_index: int = 0

# Références aux positions, définies une seule fois au démarrage.
@onready var spawn_pos: Vector2 = $SpawnPoint.global_position
@onready var target_pos: Vector2 = $TargetZone.global_position


func _process(delta):
	# Mettre à jour le temps du jeu.
	# Utiliser 'delta' garantit que le temps avance de manière cohérente,
	# peu importe le framerate.
	song_position += delta
	
	# --- Lecteur de Chart (Chart Reader) ---
	
	# On vérifie s'il reste des notes à traiter dans notre chart.
	# On utilise "while" et non "if" pour le cas où plusieurs notes devraient
	# être instanciées dans la même frame (si le jeu a un pic de lag).
	while next_note_index < chart_data.size():
		var note_target_time = chart_data[next_note_index]
		
		# On doit instancier la note 'lookahead_time' secondes AVANT qu'elle n'atteigne sa cible.
		# On vérifie si le temps de la chanson a atteint le point de spawn de la prochaine note.
		if song_position >= note_target_time - lookahead_time:
			# C'est le moment de créer la note !
			spawn_note(note_target_time)
			
			# On avance notre curseur pour regarder la note suivante à la prochaine frame.
			next_note_index += 1
		else:
			# Si la note actuelle n'est pas encore prête à être instanciée,
			# alors les suivantes ne le sont pas non plus (car le chart est trié).
			# On peut donc arrêter de vérifier pour cette frame.
			break

# --- Spawner ---
func spawn_note(target_time: float):
	# Crée une nouvelle instance de notre scène Note.
	var note_instance = NoteScene.instantiate()
	
	# On l'ajoute à l'arbre de la scène pour qu'elle devienne visible et active.
	add_child(note_instance)
	
	# On configure la note avec toutes les informations dont elle a besoin pour être autonome.
	note_instance.setup(target_time, self, spawn_pos, target_pos)
	print("Note instanciée pour t=", target_time, " à song_position=", song_position)
