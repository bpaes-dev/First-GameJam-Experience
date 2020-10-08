#ARCHER

extends "res://scripts/StateMachine.gd"

onready var right_cast = parent.right_wall_ray_cast
onready var left_cast = parent.left_wall_ray_cast


func _ready():
	
	add_state("iddle")
	add_state("walk")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("die")
	add_state("wall_slide")
	call_deferred("set_state", states.iddle)
	
	

func _state_logic(delta):

	parent._apply_gravity(delta)
	parent._get_input()
	parent._update_wall_direction()
	parent._apply_movement(delta)
	if state == states.wall_slide:
		parent.velocity.x = parent.wall_direction
		
	
	
	
	
	
	
	
	
func _get_transition(delta):
	
	match state:
		
		
		states.iddle:
			if !parent.is_ground:
				if parent.velocity.y < 0:
					return states.jump
				if parent.velocity.y > 0:
					return states.fall
			else:
				if parent.move_direction == 1 or parent.move_direction == -1:
					if parent.run == true:
						states.run
					else:
						states.walk
				
		
		states.run:
			if !parent.is_ground:
				if parent.velocity.y < 0:
					return states.jump
				if parent.velocity.y > 0:
					return states.fall
			else:
				if not parent.run:
					return states.walk
				if parent.move_direction == 0 :
					return states.iddle
				
				
		states.walk:
			if !parent.is_ground:

				if parent.velocity.y < 0:
						return states.jump
				if parent.velocity.y > 0:
						return states.fall	
			else:
				if parent.move_direction == 1 or parent.move_direction == -1:
					return states.run
				if parent.move_direction == 0 and parent.velocity.x == 0:
					return states.iddle
				
				
		states.jump:
			if !parent.is_ground:
				if parent.wall_direction != 0 and parent.wall_direction == parent.move_direction:
					return states.wall_slide
			
				if parent.velocity.y > 0:
					return states.fall
			else:
				if parent.move_direction == 1 or parent.move_direction == -1:
					if parent.run == true:
						states.run
					else:
						states.walk
				if parent.move_direction == 0 and parent.velocity.x == 0:
					return states.iddle
					
					
		states.fall:
			if !parent.is_ground:
				if parent.wall_direction != 0 and parent.wall_direction == parent.move_direction:
					return states.wall_slide
			
			
				if parent.velocity.y < 0:
					return states.jump
			else:
				if parent.move_direction == 1 or parent.move_direction == -1:
					if parent.run == true:
						states.run
					else:
						states.walk
				if parent.move_direction == 0 and parent.velocity.x == 0:
					return states.iddle

		
		states.wall_slide:
			if parent.is_ground:
				if parent.move_direction == 1 or parent.move_direction == -1:
					if parent.run == true:
						return states.run
					else:
						return states.walk
				else:
					return states.iddle
			else:
				if parent.wall_direction != 0:
					
					if !(parent.jumped and parent.can_jump):
					
						if parent.move_direction == 1:
							if parent.wall_direction == -1:
								if parent.speed > 150:
									if parent.velocity.y >= 0:
										return states.fall
									elif parent.velocity.y < 0:
										return states.jump
										
						if parent.move_direction == -1:
							if parent.wall_direction == 1:
								if parent.speed < -150 :
									if parent.velocity.y >= 0:
										return states.fall
									elif parent.velocity.y < 0:
										return states.jump
					else:
						parent.jump(parent.wall_direction, parent.move_direction)
						return states.jump
				
				else:
					if parent.velocity.y >= 0:
						return states.fall
					elif parent.velocity.y < 0:
						return states.jump
	return null
	

	# CHANGE prints TO ANIMATIONs
func _enter_state(new_state, old_state):
	match new_state:
		states.iddle:
			parent.is_wall = false
		states.walk:
			parent.is_wall = false
		states.run:
			parent.is_wall = false
		states.jump:
			parent.is_wall = false
		states.fall:
			parent.is_wall = false
		states.wall_slide:
			parent.is_wall = true
func _exit_state(old_state, new_state):
	pass


