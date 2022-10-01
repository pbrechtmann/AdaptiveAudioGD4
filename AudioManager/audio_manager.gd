extends Node
class_name AudioManager


var current_playlist : Playlist

@onready var playlist_intro : Playlist = $PlaylistIntro
@onready var playlist_main : Playlist = $PlaylistMain

func _ready() -> void:
	for playlist in get_children():
		if playlist is Playlist:
			playlist.transition.connect(_on_playlist_transition)
	
	current_playlist = playlist_intro
	current_playlist.start_playback()



func _on_playlist_transition() -> void:
	current_playlist.start_playback()
