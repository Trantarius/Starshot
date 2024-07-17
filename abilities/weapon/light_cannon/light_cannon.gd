extends PlayerAbility

var fire_rate:Stat = Stat.new(3, 0, INF)
var damage:Stat = Stat.new(10, 0, INF)
var projectile_count:Stat = Stat.new(1, 1, INF, Stat.PERIODIC)
var projectile_speed:Stat = Stat.new(1000, 0, INF)
var projectile_size:Stat = Stat.new(8, 1, INF)

const proj_spacing:float = 0.5

signal fired

func _ready()->void:
	$FireTimer.duration = 1.0/fire_rate.get_value()
	$FireTimer.reset()
	$FireTimer.start()


func _on_fire_timer_timeout_precise(ago: float) -> void:
	var proj_count:int = projectile_count.get_value()
	
	var lin_err:Vector2 = -get_parent().linear_velocity * ago
	var ang_err:float = -get_parent().angular_velocity * ago
	var mpos:Vector2 = (get_parent().get_muzzle_position() - get_parent().global_position
		).rotated(ang_err) + get_parent().global_position + lin_err
	var mdir:Vector2 = get_parent().get_muzzle_direction().rotated(ang_err)
	
	var tot_width:float = proj_count * projectile_size.get_value() + (proj_count-1) * projectile_size.get_value() * proj_spacing
	var p0:Vector2 = mpos - mdir.orthogonal() * (tot_width/2 - projectile_size.get_value()/2)
	var dp:Vector2 = mdir.orthogonal() * projectile_size.get_value() * (1+proj_spacing)
	
	for n:int in range(proj_count):
		var bullet:Projectile = preload("res://abilities/weapon/light_cannon/light_cannon_projectile.tscn").instantiate()
		bullet.global_position = p0 + dp*n
		
		bullet.linear_velocity = projectile_speed.get_value() * mdir + get_parent().linear_velocity
		bullet.source = get_parent()
		bullet.damage_amount = damage.get_value()
		bullet.scale = Vector2.ONE * projectile_size.get_value()/8
		bullet.global_position += bullet.linear_velocity * ago
		get_tree().current_scene.add_child(bullet)
	
	fired.emit()
	$FireTimer.duration = 1.0/fire_rate.get_value()
