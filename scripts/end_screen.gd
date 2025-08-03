extends CanvasLayer

# Signal émis lorsque le bouton de redémarrage est pressé.
signal restart_game_requested

# --- Références aux Nœuds ---
# L'utilisation de % est une manière robuste de récupérer les nœuds uniques dans la scène.
@onready var final_score_label: Label = %FinalScoreLabel
@onready var sword_texture_rect: TextureRect = %SwordTextureRect
@onready var tier_name_label: Label = %TierNameLabel
@onready var restart_button: Button = %RestartButton

func _ready():
	# On connecte le signal "pressed" du bouton à notre fonction de gestion.
	# Ainsi, quand le bouton est cliqué, la fonction _on_restart_button_pressed sera appelée.
	restart_button.pressed.connect(_on_restart_button_pressed)

## Configure l'écran de fin avec les résultats finaux de la partie.
## Cette fonction est conçue pour être appelée depuis le script principal du jeu (game.gd).
## - final_score: Le score total du joueur.
## - sword_texture: La texture de l'épée finale obtenue.
## - tier_name: Le nom du palier de qualité atteint (ex: "FER").
func set_results(final_score: int, sword_texture: Texture2D, tier_name: String):
	final_score_label.text = "Score: %d" % final_score
	sword_texture_rect.texture = sword_texture
	tier_name_label.text = "Palier: %s" % tier_name.to_upper()

## Fonction privée qui gère le clic sur le bouton.
## Elle ne fait qu'émettre le signal restart_game_requested, que la scène principale du jeu (game.tscn) écoutera.
func _on_restart_button_pressed():
	# On cache le bouton pour éviter les clics multiples pendant le rechargement.
	restart_button.disabled = true
	restart_game_requested.emit()
