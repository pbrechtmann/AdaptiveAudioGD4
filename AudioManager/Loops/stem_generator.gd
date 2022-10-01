extends Node
class_name StemGenerator
@tool


@export var update : bool = false:
	set(update):
		generate_stems()
		update = false
@export var amount_stems = 1


func generate_stems() -> void:
	print_debug("starting")
	if Engine.is_editor_hint():
		for child in get_children():
			child.queue_free()
		
		for i in range(amount_stems):
			var audio_player : AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(audio_player)
			audio_player.owner = get_tree().edited_scene_root
