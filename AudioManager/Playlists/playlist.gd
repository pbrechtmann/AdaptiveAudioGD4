extends Node
class_name Playlist

@export_category("Loop Defaults")
@export var default_length_seconds : float
@export var default_bpm : int
@export var default_bars : int
@export var default_beats_per_bar : int
@export var default_transition_on_bar : int

var loops : Array = []
var current_loop : Loop
var current_loop_number = 0

var loop_switch_queued : bool = false
var transition_queued : bool = false

signal transition()


func _ready() -> void:
	loops = get_children()
	for loop in loops:
		if loop is Loop:
			if loop.length_seconds == 0:
				loop.setup(default_length_seconds, default_bpm, default_bars, default_beats_per_bar, default_transition_on_bar)
		
			loop.beat_done.connect(_on_loop_beat_done)
			loop.bar_done.connect(_on_loop_bar_done)
			loop.transition.connect(_on_loop_transition)
			loop.transition_picked.connect(_on_loop_transition_picked)
	
	randomize()


func start_playback() -> void:
	if (current_loop_number == -1):
		current_loop_number = randi_range(0, loops.size() - 1)
	
	current_loop = loops[current_loop_number]
	current_loop.start()


func stop_playback() -> void:
	current_loop.stop()
 

func start_playlist_transition() -> void:
	transition_queued = true


func queue_loop_switch() -> void:
	loop_switch_queued = true


func get_loops() -> Array:
	return loops


func _on_loop_beat_done() -> void:
	pass


func _on_loop_bar_done() -> void:
	if loop_switch_queued:
		var temp : int = current_loop_number
		while (current_loop_number == temp):
			current_loop_number = randi_range(0, loops.size() - 1)
		
		stop_playback()
		start_playback()
		loop_switch_queued = false


func _on_loop_transition() -> void:
	if transition_queued:
		current_loop_number = 0
		current_loop = loops[current_loop_number]
		transition.emit()
		transition_queued = false
	
	else:
		if current_loop_number + 1 < loops.size():
			current_loop_number += 1
			current_loop = loops[current_loop_number]
		else:
			current_loop_number = 0
			current_loop = loops[current_loop_number]
		
		current_loop.start()


func _on_loop_transition_picked(index : int) -> void:
	current_loop_number = index - 2
