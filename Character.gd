extends KinematicBody2D

const UP = Vector2(0,1)

signal collided

#Move vars
var velocity = Vector2()
var move_direction
var wall_direction = 1
var is_ground
var run
var is_wall


#Jump const and vars
const WALL_GRAVITY = 300
const MIN_GRAVITY = 650
const MAX_GRAVITY = 900
const JUMP_MAX = -350
const JUMP_MIN = -260
var jumped
onready var can_jump = true

onready var collider = $shape
onready var left_wall_ray_cast = $WallRayCast/LeftRayCast
onready var right_wall_ray_cast = $WallRayCast/RightRayCast


onready var speed = 0
onready var speed_vel = 250
onready var speed_max = 100


var snap = false
var slope_slide_thereshold = 50

# Called when the node enters the scene tree for the first time.
func _ready():

	is_wall = false
	
	velocity.y = 0
	velocity.x = 0
	


	
func _apply_gravity(delta):
	
	
	
	
	can_jump = verif_can_jump(can_jump)
	
	is_ground = is_on_floor()
	if is_ground == true:
		if jumped == true:
			jump(wall_direction, move_direction)
		if is_ground == true && jumped == false:
			velocity.y = 0

	elif is_wall == true:
		if jumped == true:
			jump(wall_direction, move_direction)
		if velocity.y < 0 :
			velocity.y += MIN_GRAVITY * delta
		else:
			velocity.y += WALL_GRAVITY * delta
			
	else:
		if Input.is_action_pressed("jump") and velocity.y < 5:
			velocity.y += MIN_GRAVITY * delta
		else:
			velocity.y += MAX_GRAVITY * delta
	
	var snap_vector = Vector2(0, 32) if snap else Vector2()
	velocity = move_and_slide_with_snap(velocity , snap_vector, Vector2.UP, slope_slide_thereshold)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal("collided", collision)
		

#JUMP MECHANIC
#
func jump(wall_dir, move_dir):
	if can_jump == true && is_ground == true:
		velocity.y += JUMP_MAX
		can_jump = false
	elif can_jump == true && is_wall == true:
		velocity.y = 0
		
		speed = -speed
		if wall_dir == 1:
			velocity += get_impulse_vector(205, 600)
		if wall_dir == -1:
			velocity += get_impulse_vector(335, 600)

			
		
		
		
		can_jump = false
	
	#MOVIMENT OF THE CHAR
func _apply_movement(delta):

		
	#SPEED AND RUNNING MECHANICS
	if  is_ground and not run:                                    #cannot
		speed_vel = 400                                             #lose speed 
		speed_max = 200                                             #in the air
	elif run:
		speed_vel = 600
		speed_max = 400
	elif move_direction == 0:
		speed_vel = 600	
		speed_max = 400
		
		
	if move_direction < 0:
		$Sprite.flip_h = true
		if speed > 100:
			speed = 50  if speed != null else 0
		elif speed > -speed_max:
			speed = speed - speed_vel *delta if speed != null else 0
		else:
			speed = -speed_max
	if move_direction > 0:
		$Sprite.flip_h = false
		if speed < -100:
			speed = -50  if speed != null else 0
		elif speed < speed_max:
			speed = speed + speed_vel *delta  if speed != null else 0
		else:
			speed = speed_max 
	if move_direction == 0:
		
		if speed > 20:
			speed = speed - speed_vel * 4 *delta if speed != null  else 0.00
		elif speed < -20:
			speed = speed + speed_vel * 4 *delta if speed != null   else 0.00
		else:
			speed = 0
	
	
	velocity.x = speed
	
	

	
	
	# INPUT MAP
func _get_input():
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	run = Input.is_action_pressed("run")
	jumped = Input.is_action_pressed("jump")
	
	if right and not left:
		move_direction = 1
	elif left and not right:
		move_direction = -1
	else:
		move_direction = 0
		
		
func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_ray_cast)
	var is_near_wall_right = _check_is_valid_wall(right_wall_ray_cast)
	
	if is_near_wall_left && is_near_wall_right:
		if move_direction > 0:
			wall_direction = 1
		elif move_direction < 0:
			wall_direction = -1
	else:
		wall_direction = - int (is_near_wall_left) + int (is_near_wall_right)



func verif_can_jump(can_jump):
	if can_jump != null:
		if Input.is_action_just_pressed("jump"):
			return true
		elif Input.is_action_just_released("jump"):
			return false
		else:
			return can_jump
	
func _check_is_valid_wall(wall_raycasts):
	for raycasts in wall_raycasts.get_children():
		if raycasts.is_colliding():
			var dot = acos(Vector2.UP.dot(raycasts.get_collision_normal()))
			if dot > PI * 0.35 and dot < PI * 0.55:
				return true
		return false


func get_impulse_vector(angle, size):
	#convert angle to radian
	angle = angle * PI / 180
	
	# get the x and y input
	var fx = size * cos(angle)
	var fy = size * sin(angle)
	
	var out = Vector2(fx,fy)
	
	return out
