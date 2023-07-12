extends CanvasGroup

var screen_size
var player_scene = preload("res://player.tscn")
var player_location
var mob
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	generate_mob()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Globals.player_position = $Player.position
	
func _on_player_location(location):
	player_location = location

func generate_mob():
	mob = player_scene.instantiate()
	mob.position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
	mob.is_cpu = true
	mob.set_collision_layer_value(2, true)
	add_child(mob)

func _on_mob_spawn_timer_timeout():
	
	generate_mob()


func _on_check_button_button_down():
	Globals.is_hostile = true


func _on_check_button_button_up():
	Globals.is_hostile = false
