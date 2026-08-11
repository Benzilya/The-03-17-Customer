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
	if message == "CCTV_DYNAMIC":
		var current_status = game.get("cctv_status")
		if current_status != null:
			output = str(current_status)
	if game.has_method("show_message"):
		game.show_message(output)
