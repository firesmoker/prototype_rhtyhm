Right pointer destination: 1200 px
Right teacher pointer destination: 2400 px

TO DO

Content
* build good level

Audio
* better sounds for note play and you play

Art
* 1/8 and 1/4 assets same size
* first 1/8 and second 1/8 assets
* Listen "icon"
* Play "icon"

Functionality
* first 1/8 and second 1/8 functionality
* indication where you just played
* Listen and Play Label



previous load rhythmic pattern in ready:
	
	#var rhythm_game_level: RhythmGameLevel = RhythmGameLevel.new("res://rhythmGameLevelExample.json")
	#var stages: Dictionary = rhythm_game_level.get_stage(1)
	## Assuming stages["notes"] contains the list of notes
	#var input_notes: Array[Dictionary] = []
	#if "notes" in stages:
		#for note: Dictionary in stages["notes"]:
			#input_notes.append(note)
			#
	#populate_note_nodes(input_notes.size())	
	#for i in range(input_notes.size()):
		#var type: String  = "note"
		#if input_notes[i]["is_rest"]:
			#type = "rest"
		#notes_dictionary[i] = {
			#"x_location": i * note_quarter_gap,
			#"duration": 1,  # Assuming all are quarter note, adjust as needed
			#"type": type,
			#"status": note_status.IDLE,  # Assuming note_status is defined elsewhere in your code
		#}
		#note_nodes[i].type = type
	#
	#notes_dictionary[0]["status"] = note_status.ACTIVE
	#
	#var count: int = 0
	#for note in note_nodes:
		#note.position.x = notes_dictionary[count]["x_location"]
		#note.position.y = note_y_location
		#count += 1
