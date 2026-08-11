extends StaticBody3D

@export var interaction_text := "Inspect"
@export_multiline var message := "Nothing unusual."

func interact(_player: Node) -> void:
	var game := get_tree().get_first_node_in_group("game")
	if game and game.has_method("show_message"):
		game.show_message(message)
