extends "res://scripts/Enemy.gd"

func _ready():
	pass
	

func _on_Timer_timeout() -> void:
	match state:
		States.SHOOTING:
			
			
			var angle : float = target.position.angle_to_point(position) + PI
			var bullet = Bullet.instance() #need to do something before bullet ready function is called?
			bullet.position = get_global_transform().get_origin() - Vector2(16, 0).rotated(angle)
			bullet.init(bullet_modulate)
			bullet_speed = (position - player.position).length() / bullet.lifetime
			bullet.speed = bullet_speed
			$Gun.add_child(bullet)
			SoundService.call(sound + "_gunshot")
			
			# Muzzle flash
			if MuzzleFlash:
				var muzzle_flash = MuzzleFlash.instance()
				muzzle_flash.position = -Vector2(16, 0).rotated(angle)
				muzzle_flash.rotation = bullet.rotation
				add_child(muzzle_flash)
		_:
			._on_Timer_timeout()