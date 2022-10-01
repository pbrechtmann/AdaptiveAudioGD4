extends Node
class_name Loop

@export var length_seconds : float
@export var bpm : int
@export var bars : int
@export var beats_per_bar : int
@export var transition_on_bar : int
@export var repetitions_max : int
@export var repetitions_min : int
@export_range(0, 1) var repetition_chance : float
@export var transitions : Dictionary

var beats : int = 0
var beat_counter : int = 0
var bar_counter : int = 0

var repetitions : int = 0
var transitioning : bool = false

var stems : Array = [] # array containing all stems inside the stemcontainer

@onready var stem_container : Node = $Stems
@onready var beat_timer : Timer = $BeatTimer

signal beat_done()
signal bar_done()
signal transition()
signal transition_picked(loop_index : int)


func _ready() -> void:
	beat_timer.timeout.connect(_on_beat)
	beats = bars * beats_per_bar
	if beats != 0:
		beat_timer.wait_time = length_seconds / beats
	
	stems = stem_container.get_children()
	for stem in stems:
		if stem is AudioStreamPlayer:
			stem.max_polyphony = repetitions_max
	
	randomize()


func setup(length_seconds : float, bpm : int, bars : int, beats_per_bar : int, transition_on_bar : int) -> void:
	self.length_seconds = length_seconds
	self.bpm = bpm
	self.bars = bars
	self.beats_per_bar = beats_per_bar
	self.transition_on_bar = transition_on_bar
	beats = bars * beats_per_bar
	beat_timer.wait_time = length_seconds / beats


func start() -> void:
	reset()
	
	if repetition_chance != 0:
		repetitions = randi_range(repetitions_min, repetitions_max)
	
	var c : float = 0 # current chance percentage
	var r : float = randf()
	
	for key in transitions.keys():
		c += key
		if c >= r:
			transition_picked.emit(transitions[key])
			break
	
	for stem in stems:
		stem.play()
	
	beat_timer.start()


func stop() -> void:
	for stem in stems:
		stem.stop()
	
	beat_timer.stop()


func _on_beat() -> void:
	beat_counter += 1
	beat_done.emit()
	if beat_counter == beats_per_bar:
		beat_counter = 0
		bar_counter += 1
		bar_done.emit()
	
	if bar_counter == transition_on_bar and not transitioning:
		if repetitions > 0:
			print_debug("repeating")
			for stem in stems:
				stem.play()
			repetitions -= 1
			bar_counter = 0
		
		else:
			transitioning = true
			transition.emit()


func reset() -> void:
	bar_counter = 0
	transitioning = false
	beat_timer.stop()
