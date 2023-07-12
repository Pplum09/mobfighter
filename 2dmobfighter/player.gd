extends Area2D

signal hit
signal die

@export var is_cpu = false
@export var show_stats = false
@export var current_state = STATE.IDLE

enum STATE {IDLE, MOVING, ATTACK}
enum DIRECTION {UP, DOWN, LEFT, RIGHT, UPLEFT, UPRIGHT, DOWNLEFT, DOWNRIGHT}

var velocity = Vector2.ZERO
var current_direction = DIRECTION.DOWN
var speed = 600
var mob_speed = 50
var screen_size
var health = 100
var attack_strength = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	disable_weapon_collision()
	if not show_stats:
		$Stats.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if is_cpu and Globals.is_hostile:
		velocity = position.direction_to(Globals.player_position) * mob_speed
	if not is_cpu:
		velocity = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down').normalized() * speed
		
	set_direction(velocity)
	set_move_animation()
	
	# physically move player
	position += velocity * delta
	position = Vector2(clamp(position.x, 0, screen_size.x), clamp(position.y, 0, screen_size.y))
#
	if not is_cpu and Input.is_action_just_pressed("attack"):
		current_state = STATE.ATTACK
		set_attack_animation()
	
	update_stats()
	update_health()
	
func update_health():
	$Health.text = str(health)
	
func update_stats():
	var updateText = ''
	updateText += 'Direction: ' + DIRECTION.keys()[current_direction]
	updateText += '\nSTATE: ' + STATE.keys()[current_state]
	updateText += '\nMove animation: ' + $AnimatedSprite2D.animation 
	updateText += '\nPosition: (' + str(position.x) + ', ' + str(position.y) +')'
	$Stats.text = updateText

func set_attack_animation():
	$WeaponArea2D/WeaponAnimatedSprite2D.speed_scale = 7
	$WeaponArea2D/WeaponAnimatedSprite2D.show()
	var attack_animation = 'sword_upleft'
	var weapon_collision_rotation
	match current_direction:
		DIRECTION.LEFT, DIRECTION.UPLEFT:
#			$AnimatedSprite2D.play('slash_upleft')
			attack_animation = 'sword_upleft'
			$WeaponArea2D/CollisionPolygon2DLeft.show()
		DIRECTION.RIGHT, DIRECTION.DOWNRIGHT:
#			$AnimatedSprite2D.play('slash_downright')
			attack_animation = 'sword_downright'
			$WeaponArea2D/CollisionPolygon2DRight.show()
		DIRECTION.DOWN, DIRECTION.DOWNLEFT:
#			$AnimatedSprite2D.play('slash_downleft')
			attack_animation = 'sword_downleft'
			$WeaponArea2D/CollisionPolygon2DDown.show()
		DIRECTION.UP, DIRECTION.UPRIGHT:
#			$AnimatedSprite2D.play('slash_upright')
			attack_animation = 'sword_upright'
			$WeaponArea2D/CollisionPolygon2DUp.show()
		_:
			print('nothing')
	
	$WeaponArea2D/WeaponAnimatedSprite2D.play(attack_animation)
	
func set_move_animation():
	if current_state == STATE.IDLE:
		if $AnimatedSprite2D.animation != 'idle':
			$AnimatedSprite2D.stop()
		return
		
	match current_direction: 
		DIRECTION.UP:
			$AnimatedSprite2D.play('move_up')
		DIRECTION.DOWN:
			$AnimatedSprite2D.play('move_down')
		DIRECTION.LEFT: 
			$AnimatedSprite2D.play('move_left')
		DIRECTION.RIGHT: 
			$AnimatedSprite2D.play('move_right')
		DIRECTION.UPLEFT: 
			$AnimatedSprite2D.play('move_upleft')
		DIRECTION.UPRIGHT: 
			$AnimatedSprite2D.play('move_upright')
		DIRECTION.DOWNLEFT: 
			$AnimatedSprite2D.play('move_downleft')
		DIRECTION.DOWNRIGHT: 
			$AnimatedSprite2D.play('move_downright')
#		_:
#			$AnimatedSprite2D.stop()
		
func set_direction(velocity):
	if velocity.x == 0 and velocity.y == 0:
		current_state = STATE.IDLE
		return
		
	if velocity.x == 0:
		if velocity.y < 0:
			current_direction = DIRECTION.UP
		elif velocity.y > 0:
			current_direction = DIRECTION.DOWN
	elif velocity.y == 0:
		if velocity.x < 0:
			current_direction = DIRECTION.LEFT
		elif velocity.x > 0:
			current_direction = DIRECTION.RIGHT
	elif velocity.x < 0:
		if velocity.y < 0:
			current_direction = DIRECTION.UPLEFT
		elif velocity.y > 0:
			current_direction = DIRECTION.DOWNLEFT
	elif velocity.x > 0:
		if velocity.y < 0:
			current_direction = DIRECTION.UPRIGHT
		elif velocity.y > 0:
			current_direction = DIRECTION.DOWNRIGHT
	current_state = STATE.MOVING
	
func disable_weapon_collision():
	$WeaponArea2D/CollisionPolygon2DUp.hide()
	$WeaponArea2D/CollisionPolygon2DDown.hide()
	$WeaponArea2D/CollisionPolygon2DLeft.hide()
	$WeaponArea2D/CollisionPolygon2DRight.hide()
	
func _on_weapon_animated_sprite_2d_animation_finished():
	current_state = STATE.IDLE
	$AnimatedSprite2D.speed_scale = 1
	$WeaponArea2D/WeaponAnimatedSprite2D.speed_scale = 1
	$WeaponArea2D/WeaponAnimatedSprite2D.hide()
	print('DONE!')

func _on_weapon_area_2d_area_entered(area):
	print('weapon hit: ', area)
	area.emit_signal('hit', attack_strength)

func _on_hit(attack_strength):
	health -= attack_strength
	if health <= 0:
		health = 0
		queue_free()
