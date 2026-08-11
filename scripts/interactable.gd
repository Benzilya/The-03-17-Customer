extends StaticBody3D

@export var interaction_text := "Inspect"
@export_multiline var message := "Nothing unusual."

func interact(_player: Node) -> void:
	var game := get_tree().get_first_node_in_group("game")
	if not game:
		return
	if game.has_method("on_interaction"):
		game.on_interaction(self)
	var output := message
	if game.has_method("get_interaction_message"):
		output = game.get_interaction_message(self, message)
	if game.has_method("show_message"):
		game.show_message(output)
