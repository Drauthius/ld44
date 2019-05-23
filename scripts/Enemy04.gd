extends KinematicBody2D

const QPI = PI/4.0

export var walk_speed : int = 70
export var run_speed : int = 110
var current_speed : int = 0
var direction : Vector2 = Vector2()
export var charge_distance : int = 220
export var charge_distance_span : int = 30
export var charge_speed : int = 300
export var charge_chance : float = 0.75
export var charge_timer : float = 2.0
export var charge_cooldown : float = 1.0
#var charge_distance_sqrd = charge_distance * charge_distance
var charge_target
var mate

export var health = 5
signal death(KinematicBody2D)

export var timer_long = 1.0
export var timer_short = 0.5
export var time_until_removal = 4
var death_timer = 0.0
var is_dead = false
export var worth : int = 5
var difficulty = 0
enum {PURSUE, CHARGE, CHARGING, EVADE, MATING, WANDER, WAIT}
var behaviour_switch = WANDER

onready var player = $"../Player"

func _ready():
	SoundService.enemy04_spawn()


func _physics_process(delta):
	if is_dead:
		death_timer += delta
		if death_timer > time_until_removal:
			queue_free()
		return
	elif $"..".is_choosing:
		$AnimationPlayer.stop()
		return
	
	
	if behaviour_switch == MATING:
		if mate == null or mate.is_dead:
			behaviour_switch = WANDER
			$WalkTimer.start()
			return
		direction = (mate.position - position).normalized()
		direction = direction * 0.1 + direction.tangent()
		var coll = move_and_collide(direction * delta * run_speed)
	elif behaviour_switch == PURSUE:
		current_speed = run_speed
		direction = (player.position - position).normalized()
		var velocity = move_and_slide(direction * current_speed, Vector2(0, 0), true, 1, 0.0, false)
		_set_sprite(direction.angle(), velocity.length_squared() <= 1000)
	elif behaviour_switch == WANDER:
		if $WalkTimer.is_stopped():
			print("start wandering")
			$WalkTimer.start()
			$WaitTimer.stop()
			print("walktimer time left: ",$WalkTimer.time_left)
			direction = _get_random_direction()
			current_speed = walk_speed
		var velocity = move_and_slide(direction * current_speed, Vector2(0, 0), true, 1, 0.0, false)
		_set_sprite(direction.angle(), velocity.length_squared() <= 1000, "walk")
		pass
	elif behaviour_switch == WAIT:
		if $WaitTimer.is_stopped():
			$WaitTimer.start()
			$WalkTimer.stop()
			direction = _get_random_direction()
			current_speed = 0
		var velocity = move_and_slide(direction * current_speed, Vector2(0, 0), true, 1, 0.0, false)
		_set_sprite(direction.angle(), velocity.length_squared() <= 1000, "walk")
	
	# Check for player collision
	for i in range(get_slide_count()):
		var coll = get_slide_collision(i)
		if coll.collider == player:
			player.die()
			$AnimationPlayer.stop()

func _set_sprite(angle, paused = false, state = "run"):
	angle += PI
	var wide = true
	if state != "":
		state = str("_"+state)
	if angle > 5*QPI and angle < 7*QPI:
		$AnimationPlayer.play("down"+state)
		wide = false
	elif angle > 3*QPI and angle < 5*QPI:
		$AnimationPlayer.play("right"+state)
	elif angle > QPI and angle < 3*QPI:
		$AnimationPlayer.play("up"+state)
		wide = false
	else:
		$AnimationPlayer.play("left"+state)
	
	if paused:
		$AnimationPlayer.advance(0.01)
		$AnimationPlayer.stop()
	
	# They're very oblong, so rotate the collision shape.
	if wide:
		$CollisionShape2D.rotation = PI/2
	else:
		$CollisionShape2D.rotation = 0

func _get_random_direction():
	var _angle = randf() * 2 * PI
	return Vector2(cos(_angle), sin(_angle))

func get_worth():
	return worth

func die():
	SoundService.fleshthump() #TODO add sound
	if is_dead:
		return
	
	print("health ", health)
	health -= 1
	if health <= 0:
		is_dead = true
		#SoundService.enemy02_death()
		emit_signal("death", self)
		$AnimationPlayer.play($AnimationPlayer.current_animation.replace("down_", "right_"))
		$AnimationPlayer.play($AnimationPlayer.current_animation.replace("up_", "left_"))
		$AnimationPlayer.play($AnimationPlayer.current_animation.replace("_run", "_death"))
		# Bug?? Play won't change the current animation when called by Game from a signal
		$AnimationPlayer.current_animation = $AnimationPlayer.current_animation.replace("_run", "_death")


func _on_MatingArea_body_entered(body):
	if mate != null:
		print("mate: ", mate, ", returning ")
		return
	
	if body.is_in_group("Mate"):
		print("mate found, nothing done, see on MatinArea body entered")
		return
		body.mate = self
		behaviour_switch = MATING
		mate = body



func _on_AttackArea_body_entered(body):
	if body == player:
		$WalkTimer.stop()
		$WaitTimer.stop()
		behaviour_switch = PURSUE
		$RunTimer.start()
		pass


func _on_RunTimer_timeout():
	behaviour_switch = WAIT


func _on_WalkTimer_timeout():
	print("walk timer timeout")
	print("walktimer time left: ",$WalkTimer.time_left)
	behaviour_switch = WAIT


func _on_WaitTimer_timeout():
	behaviour_switch = WANDER
