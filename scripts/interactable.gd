extends StaticBody3D

@export var interaction_text: String = "Inspect"
@export_multiline var message: String = "Nothing unusual."

func interact(_player: Node) -> void:
	var game: Node = get_tree().get_first_node_in_group("game")
	if game == null:
		return

	if game.has_method("on_interaction"):
		var consumed_value: Variant = game.call("on_interaction", self)
		if typeof(consumed_value) == TYPE_BOOL and bool(consumed_value):
			return

	if game.has_method("show_message"):
		game.call("show_message", message)
