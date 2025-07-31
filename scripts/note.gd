# note.gd
extends Area2D

var target_time: float = 0.0
var game_node
var spawn_position: Vector2
var target_position: Vector2

func setup(p_target_time: float, p_game_node, p_spawn_pos: Vector2, p_target_pos: Vector2):
	self.target_time = p_target_time
	self.game_node = p_game_node
	self.spawn_position = p_spawn_pos
	self.target_position = p_target_pos
	
	# Positionner la note au point de départ dès sa création
	self.global_position = spawn_position

func _process(delta):
	# Si le noeud principal n'est pas encore défini, on ne fait rien.
	if not is_instance_valid(game_node):
		return

	# Récupérer les variables clés du noeud principal
	var current_song_time = game_node.song_position
	var lookahead = game_node.lookahead_time

	# Calculer le temps auquel la note doit apparaître (spawner)
	var spawn_time = target_time - lookahead

	# Si la note n'est pas encore censée être à l'écran, on ne fait rien.
	if current_song_time < spawn_time:
		# On la cache pour éviter un "pop" si le jeu lag au démarrage
		self.visible = false
		return
	
	self.visible = true

	# Calculer la progression de la note sur la piste (un ratio de 0.0 à 1.0)
	# 0.0 = au SpawnPoint, 1.0 = à la TargetZone
	var progress = (current_song_time - spawn_time) / lookahead
	
	# Mettre à jour la position en utilisant l'interpolation linéaire (lerp)
	# lerp est parfait car il est indépendant du framerate.
	self.global_position = spawn_position.lerp(target_position, progress)

	# Auto-destruction si la note a largement dépassé la cible
	# (pour ne pas accumuler des milliers d'objets)
	if current_song_time > target_time + 0.5: # Une marge de 0.5s
		queue_free()
