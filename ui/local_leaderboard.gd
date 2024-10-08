extends VBoxContainer

@export var entries:VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()

func update() -> void:
	
	for entry:Control in entries.get_children():
		entry.queue_free()
	
	var leaderboard:Array = GlobalMonitor.local_leaderboard
	
	for n:int in range(leaderboard.size()):
		var entry:Control = preload('res://ui/leaderboard_entry.tscn').instantiate()
		entry.run = leaderboard[n]
		entry.rank = n+1
		entry.show_submitted = true
		entries.add_child(entry)
	
