extends RigidBody2D

## Size of the resulting explosion
@export var explosion_radius:float = 256
## Damage of the resulting explosion
@export var explosion_damage:float = 50

## Time between entering tree and becoming 'armed'
@export var arming_time:float = 3
## Time after detecting an enemy to explode
@export var detonate_time:float = 0.5
## Time until deletion
@export var lifetime:float = 10

## Indictor color when light is 'off'
@export var off_color:Color
## Indicator color while waiting to become armed
@export var arming_color:Color
## Indicator color while armed and no enemies are detected
@export var armed_color:Color
## Indicator color while armed and enemies are detected
@export var detonate_color:Color

@export_flags_2d_physics var explosion_mask:int

var lifetime_timer:CountdownTimer = CountdownTimer.new()
var timer:CountdownTimer = CountdownTimer.new()
var armed:bool = false
var detonating:bool = false
var enemies_detected:int = 0

func _ready() -> void:
	timer.time = arming_time
	lifetime_timer.time = lifetime

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(armed):
		if(detonating):
			$Interpolator/Indicator.modulate = detonate_color
			if(timer.time<=0):
				detonate()
		else:
			$Interpolator/Indicator.modulate = armed_color
	else:
		if(fmod(timer.time,0.5)>0.25):
			$Interpolator/Indicator.modulate = arming_color
		else:
			$Interpolator/Indicator.modulate = off_color
		if(!armed && timer.time<=0):
			armed = true
			if(enemies_detected>0):
				detonating = true
				timer.time = detonate_time
	
	modulate.a = clamp(lifetime_timer.time,0,1)
	if(lifetime_timer.time<=0):
		queue_free()
			

func detonate()->void:
	var explosion:Explosion = Explosion.new()
	explosion.collision_mask = explosion_mask
	explosion.damage_amount = explosion_damage
	explosion.radius = explosion_radius
	explosion.linear_velocity = linear_velocity
	explosion.position = global_position
	explosion.source = get_parent()
	get_parent().add_child(explosion)
	queue_free()

func _on_detector_body_entered(body: Node2D) -> void:
	if(body is Enemy):
		enemies_detected += 1
		if(!detonating && armed):
			detonating = true
			timer.time = detonate_time

func _on_detector_body_exited(body: Node2D) -> void:
	if(body is Enemy):
		enemies_detected -= 1
		if(enemies_detected <=0):
			detonating = false
