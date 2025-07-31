# note.gd
extends Area2D

# (Problème 6) Signal pour notifier le jeu principal qu'elle a été manquée.
signal missed

var target_time: float = 0.0
var game_node
var spawn_position: Vector2
var target_position: Vector2

# Un état pour éviter des comportements multiples (ex: être manquée après avoir été touchée).
var is_hit: bool = false

func setup(p_target_time: float, p_game_node, p_spawn_pos: Vector2, p_target_pos: Vector2):
	self.target_time = p_target_time
	self.game_node = p_game_node
	self.spawn_position = p_spawn_pos
	self.target_position = p_target_pos
	self.global_position = spawn_position

func _process(delta):
	if not is_instance_valid(game_node) or is_hit:
		return

	var current_song_time = game_node.song_position
	var lookahead = game_node.lookahead_time
	var spawn_time = target_time - lookahead
	
	if current_song_time < spawn_time:
		self.visible = false
		return
	
	self.visible = true

	var progress = (current_song_time - spawn_time) / lookahead
	self.global_position = spawn_position.lerp(target_position, progress)

	# (Problème 5.1) Détection d'une note manquée par omission.
	# Si le temps de la chanson a dépassé le temps de la note PLUS la fenêtre de jugement
	# la plus large, alors elle est définitivement manquée.
	if current_song_time > target_time + game_node.timing_window_ok:
		is_hit = true # On la "verrouille" pour éviter d'envoyer le signal plusieurs fois.
		emit_signal("missed")
		queue_free() # La note s'auto-détruit.

# (Problème 6) Fonction appelée par game.gd quand la note est touchée avec succès.
func hit():
	is_hit = true # Verrouille l'état de la note.
	queue_free() # La note a rempli son rôle, elle disparaît.
