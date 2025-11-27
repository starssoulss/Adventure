class_name Player extends CharacterBody2D

const SPEED = 100.0 #速度
const ROLL_SPEED = 125.0 #滚动速度

@export var stats: Stats

var input_vector = Vector2.ZERO #输入向量
var last_input_vector = Vector2.ZERO #最后输入向量

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback


func _physics_process(_delta: float) -> void:
	
	#获取当前状态
	var state = playback.get_current_node()
	
	#根据当前状态进行处理
	match state:
		"MoveState": move_state(_delta)
			
		"AttackState":pass
			
		"RollState": roll_state(_delta)
			
			
			
func move_state(_delta: float) -> void:
	#输入向量归一化处理，会根据输入始终生成单位向量
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#有方向
	if input_vector != Vector2.ZERO:
		last_input_vector = input_vector
		update_blend_positions(input_vector)
		
	#按下攻击键
	if Input.is_action_just_pressed("attack"):
		playback.travel("AttackState")
		
	#按下翻滚键
	if Input.is_action_just_pressed("roll"):
		playback.travel("RollState")
		
	velocity = input_vector * SPEED
	move_and_slide()
	
func roll_state(_delta: float) -> void:
	#normalize函数会进行归一化处理，防止手柄时翻滚速度受摇杆影响
	velocity = last_input_vector.normalized() * ROLL_SPEED
	move_and_slide()
	
#更新动画树混合位置
func update_blend_positions(direction_vector: Vector2) -> void:
	animation_tree.set("parameters/StateMachine/MoveState/RunState/blend_position", direction_vector)
	animation_tree.set("parameters/StateMachine/MoveState/StandState/blend_position", direction_vector)
	animation_tree.set("parameters/StateMachine/AttackState/blend_position", direction_vector)
	animation_tree.set("parameters/StateMachine/RollState/blend_position", direction_vector)
