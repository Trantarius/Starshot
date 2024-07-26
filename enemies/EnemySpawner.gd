extends Node

## Scales how fast enemies spawn
@export var spawn_rate:float = 1
## Soft maximum total point_value of spawned enemies currently alive
@export var target_points:float = 10

const enemy_list:SceneList = preload("res://enemies/enemy_list.tres")

## Toggles all enemy spawning
@export var enabled:bool = true

func get_weight(idx:int)->float:
	var spawnable:bool = enemy_list.get_scene_prop(idx, &'spawnable', true)
	var point_value:float = enemy_list.get_scene_prop(idx, &'point_value', 1)
	var rarity:float = enemy_list.get_scene_prop(idx, &'rarity', 1)
	return 100.0/(point_value*rarity) if spawnable else 0

func select_random_enemy()->PackedScene:
	var total:float = 0
	var weights:Array[float]
	for n:int in range(enemy_list.list.size()):
		var w:float = get_weight(n)
		total+=w
		weights.push_back(w)
	var val:float = total*randf()
	var idx:int = 0
	while(idx<weights.size()):
		val -= weights[idx]
		if(val<=0):
			break
		else:
			idx += 1
	return enemy_list.list[idx]

func _enter_tree()->void:
	Performance.add_custom_monitor('Enemy Points',get_total_enemy_points)

func _exit_tree() -> void:
	Performance.remove_custom_monitor('Enemy Points')

func _physics_process(delta: float) -> void:
	if(!enabled):
		return
	var spawn_chance:float = delta * spawn_rate * (target_points-get_total_enemy_points())/target_points
	if(randf() < spawn_chance):
		spawn_an_enemy()

func spawn_an_enemy()->void:
	var players:Array = get_tree().get_nodes_in_group('Players')
	if(players.is_empty()):
		return
	spawn(select_random_enemy())

func spawn(scene:PackedScene)->void:
	var enemy:Enemy = scene.instantiate()
	var campos:Vector2 = get_viewport().get_camera_2d().get_screen_center_position()
	var locator:Callable = func()->Transform2D:
		return Transform2D(randf()*TAU, campos + 
			Vector2.from_angle(randf()*TAU) * randf_range(enemy.min_spawn_distance,enemy.max_spawn_distance))
	
	if(!Util.attempt_place_node(enemy,self,locator,5)):
		push_error("Failed to place an enemy after 5 attempts")
		enemy.queue_free()

func get_total_enemy_points()->float:
	var enemies:Array = get_tree().get_nodes_in_group('Enemies')
	var total:float = 0
	for enemy:Enemy in enemies:
		total += enemy.point_value
	return total
