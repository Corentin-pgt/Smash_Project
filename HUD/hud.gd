extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_pourcent(player, pourcent):
	if player == "Player":
		$P1.text = "Player 1 : " + str(pourcent) + "%"
	elif player == "Player2":
		$P2.text = "Player 2 : " + str(pourcent) + "%"
