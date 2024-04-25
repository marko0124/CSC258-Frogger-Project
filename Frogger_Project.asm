# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 1 reached
# - Milestone 3 reached
# - Milestone 4/5 reached
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Death Screen + Retry
# 2. Display Lives
# 3. New Map/Level 2
# 4. Powerups (gain life) 
# 5. Pause Game
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
.eqv GRASS_COLOR 0x6EDC60
.eqv RIVER_COLOR 0x44DDCE
.eqv SAND_COLOR 0xEEEB9F
.eqv ROAD_COLOR	0x5C5E5E
.eqv LOG_COLOR	0x5D4312
.eqv CAR_COLOR	0xF44BB9
.eqv FROG_COLOR 0xAD0E36
.eqv TALLGRASS_COLOR 0x2F4909
.eqv ALIGATOR_COLOR 0x0CAF5E
.eqv SWAMP_COLOR 0x114984
.eqv FRESHWATER_COLOR 0x1AC5C2
.eqv SHRUB_COLOR 0xA6AFEA
.eqv BEE_COLOR	0xEB7F3C
.eqv HEART_COLOR 0xf29bbb
.eqv GOAL_COLOR 0x4098bf
.eqv WHITE_COLOR 0xFFFFFF
.eqv BLACK_COLOR 0x5C5E5A
.eqv ASCII_W	0x77
.eqv ASCII_A	0x61
.eqv ASCII_S	0x73
.eqv ASCII_D	0x64
.eqv ASCII_E	0x65
.eqv ASCII_P	0x70

.data
	displayAddress:  	.word 0x10008000
	TopGrassPosition: 	.word 0x10008000
	RiverPosition:		.word 0x10008400
	SandPosition:		.word 0x10008800
	RoadPosition:		.word 0x10008A00
	BottomGrassPosition:	.word 0x10008E00
	FreshWaterPosition:	.word 0x10008200
	SwampPosition:		.word 0x10008400
	ShrubPosition:		.word 0x10008A00
	BottomTallGrassPosition:.word 0x10008C00
	FrogPosition:		.word 0x10008E40
	Log1Position:		.word 0x10008420
	Log2Position:		.word 0x10008460
	Log3Position:		.word 0x10008600
	Log4Position:		.word 0x10008640
	Car1Position:		.word 0x10008A20
	Car2Position:		.word 0x10008A60
	Car3Position:		.word 0x10008C10
	Car4Position:		.word 0x10008C50
	Log1Moved:		.word 8
	Log2Moved:		.word 24
	Log3Moved:		.word 31
	Log4Moved:		.word 15
	Car1Moved:		.word 8
	Car2Moved:		.word 24
	Car3Moved:		.word 27
	Car4Moved:		.word 11
	game_image: 		.space 4096
	row_width:		.space 512
	log_row1:		.space 512
	log_row2:		.space 512
	car_row1:		.space 512
	car_row2:		.space 512
	num_lives: 		.word 3
	curr_level: 		.word 1
	Aligator1Position:	.word 0x10008400
	Aligator2Position:	.word 0x10008410
	Aligator3Position:	.word 0x10008640
	Aligator4Position:	.word 0x10008650
	Aligator5Position:	.word 0x10008850
	Aligator6Position:	.word 0x10008860
	Aligator1Moved:		.word 0
	Aligator2Moved:		.word 4
	Aligator3Moved:		.word 15
	Aligator4Moved:		.word 11
	Aligator5Moved:		.word 20
	Aligator6Moved:		.word 24
	BeePosition:		.word 0x10008A00
	BeeMoved:		.word 0
	HeartPosition:		.word 0x10008200
	HeartTaken:		.word 0
	Goal1Position:		.word 0x10008008
	Goal2Position:		.word 0x10008028
	Goal3Position:		.word 0x10008048
	Goal4Position:		.word 0x10008068
	Goal1Reached:		.word 0
	Goal2Reached:		.word 0
	Goal3Reached:		.word 0
	Goal4Reached:		.word 0
	PauseStatus:		.word 0
	
	
.text
li $t1, 0		# color for most painting 
li $t2, 0 		# Loop iterator for most loops

main: 

update_frog:
	lw $t6, 0xffff0000
	beq $t6, 1, keyboard_input
	j check_game_over

keyboard_input:
	lw $t2, 0xffff0004
	beq $t2, ASCII_W, move_w
	beq $t2, ASCII_A, move_a
	beq $t2, ASCII_S, move_s
	beq $t2, ASCII_D, move_d
	beq $t2, ASCII_E, restart
	beq $t2, ASCII_P, update_pause

check_game_over:
	lw $t4, num_lives
	blt $t4, 1, call_game_over
	lw $t1, PauseStatus
	beq $t1, 1, print_pause
	
	j check_collision
	
call_game_over:
	li $a0, 0
	li $t1, 0xEFE3AD
	lw $s1, displayAddress
	la $s2, FrogPosition
	addi $s1, $s1, 3648
	sw $s1, 0($s2)
	j print_page


update_pause:
	lw $t1, PauseStatus 
	beq $t1, 1, unpause
	beq $t1, 0, pause

pause: 
	la $t1, PauseStatus
	li $t2, 1
	sw $t2, 0($t1)
	j print_pause

unpause: 
	la $t1, PauseStatus
	li $t2, 0
	sw $t2, 0($t1)
	j check_collision
	

restart:
	lw $s1, displayAddress
	la $s2, FrogPosition
	addi $s1, $s1, 3648
	sw $s1, 0($s2)
	li $t4, 3
	la $t3, num_lives
	sw $t4, 0($t3)
	li $a1, 0
	la $a0, Goal1Reached
	sw $a1, 0($a0)
	la $a0, Goal2Reached
	sw $a1, 0($a0)
	la $a0, Goal3Reached
	sw $a1, 0($a0)
	la $a0, Goal4Reached
	sw $a1, 0($a0)
	
	j change_map_level1


move_w: 
	lw $t9, FrogPosition
	la $t8, FrogPosition
	addi $t9, $t9, -512
	sw $t9, 0($t8)
	j check_collision

move_a: 
	lw $t9, FrogPosition
	la $t8, FrogPosition
	addi $t9, $t9, -8
	sw $t9, 0($t8)
	j check_collision

move_s: 
	lw $t9, FrogPosition
	la $t8, FrogPosition
	addi $t9, $t9, 512
	sw $t9, 0($t8)
	j check_collision
	
move_d: 
	lw $t9, FrogPosition
	la $t8, FrogPosition
	addi $t9, $t9, 8
	sw $t9, 0($t8)
	j check_collision

check_collision:
	lw $s1, FrogPosition
	lw $t9, 0($s1)
	beq $t9, RIVER_COLOR, collision
	beq $t9, CAR_COLOR, collision
	beq $t9, ALIGATOR_COLOR, collision
	beq $t9, BEE_COLOR, collision
	beq $t9, GOAL_COLOR, goal_in

	
	lw $t9,12($s1)
	beq $t9, RIVER_COLOR, collision
	beq $t9, CAR_COLOR, collision
	beq $t9, ALIGATOR_COLOR, collision
	beq $t9, BEE_COLOR, collision
	
	lw $t9, 256($s1)
	beq $t9, HEART_COLOR, heart_taken
	lw $t9,268($s1)
	beq $t9, HEART_COLOR, heart_taken
	
	j check_complete_map2
	
heart_taken:
	lw $t1, num_lives
	la $t2, num_lives
	addi $t1, $t1, 1
	sw $t1, 0($t2)
	li $t1, 1 
	la $t2, HeartTaken
	sw $t1, 0($t2)
	j redraw_screen2

redraw_screen2:
	lw $s1, FrogPosition
	la $s2, FrogPosition
	addi $s1, $s1, 8
	sw $s1, 0($s2)
	j draw_map2


goal_in:
	lw $s2, Goal1Position
	beq $s1, $s2, goal1
	lw $s2, Goal2Position
	beq $s1, $s2, goal2
	lw $s2, Goal3Position
	beq $s1, $s2, goal3
	lw $s2, Goal4Position
	beq $s1, $s2, goal4

goal1: 
	li $s1, 1 
	la $s2, Goal1Reached
	sw $s1, 0($s2)
	j check_complete_map1
goal2: 
	li $s1, 1 
	la $s2, Goal2Reached
	sw $s1, 0($s2)
	j check_complete_map1
goal3: 
	li $s1, 1 
	la $s2, Goal3Reached
	sw $s1, 0($s2)
	j check_complete_map1
goal4: 
	li $s1, 1 
	la $s2, Goal4Reached
	sw $s1, 0($s2)
	j check_complete_map1
	
redraw_screen:
	lw $s1, displayAddress
	la $s2, FrogPosition
	addi $s1, $s1, 3648
	sw $s1, 0($s2)
	j draw_map
	

collision:
	lw $s1, displayAddress
	la $s2, FrogPosition
	addi $s1, $s1, 3648
	sw $s1, 0($s2)
	lw $t1, num_lives
	la $t2, num_lives
	addi $t1, $t1 -1
	sw $t1, 0($t2)
	j choose_map
	

check_complete_map1:
	lw $s1, Goal1Reached
	lw $s2 Goal2Reached
	add $s1, $s1, $s2
	lw $s2 Goal3Reached
	add $s1, $s1, $s2
	lw $s2 Goal4Reached
	add $s1, $s1, $s2
	beq $s1, 4, completed
	j redraw_screen

check_complete_map2:
	lw $s1, FrogPosition
	lw $s2, displayAddress
	blt $s1, $s2, completed
	j choose_map

completed: 
	lw $s1, displayAddress
	la $s2, FrogPosition
	addi $s1, $s1, 3648
	sw $s1, 0($s2)
	li $a1, 0
	la $a0, Goal1Reached
	sw $a1, 0($a0)
	la $a0, Goal2Reached
	sw $a1, 0($a0)
	la $a0, Goal3Reached
	sw $a1, 0($a0)
	la $a0, Goal4Reached
	sw $a1, 0($a0)
	lw $s2, curr_level
	la $s3, HeartTaken
	sw $a1, 0($s3)
	beq $s2, 1, change_map_level2
	beq $s2, 2, change_map_level1

change_map_level1:
	li $s2, 1
	la $s3, curr_level
	sw $s2, 0($s3)
	j choose_map

change_map_level2:
	li $s2, 2
	la $s3, curr_level
	sw $s2, 0($s3)
	j choose_map

choose_map:
	lw $s2, curr_level
	beq $s2, 1, draw_map
	beq $s2, 2, draw_map2
	j Exit

draw_map2:
	lw $t0, TopGrassPosition
	li $a0, TALLGRASS_COLOR
	
	draw_top_tall_grass:
	bgt $t2, 31 end_draw_top_tall_grass
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_top_tall_grass

	end_draw_top_tall_grass:
	li $t2, 0
	li $a0, FRESHWATER_COLOR
	lw $t0, FreshWaterPosition
	j draw_freshwater
	
	draw_freshwater: 
	bgt $t2, 31 end_draw_freshwater
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_freshwater
	
	end_draw_freshwater: 
	li $t2, 0
	li $a0, SWAMP_COLOR
	lw $t0, SwampPosition
	j draw_swamp
	
	draw_swamp: 
	bgt $t2, 31 end_draw_swamp
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	sw $a0 512($t0)
	sw $a0 640($t0)
	sw $a0 768($t0)
	sw $a0 896($t0)
	
	sw $a0 1024($t0)
	sw $a0 1152($t0)
	sw $a0 1280($t0)
	sw $a0 1408($t0)
	sw $a0 1536($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_swamp
	
	end_draw_swamp: 
	li $t2, 0
	li $a0, SHRUB_COLOR
	lw $t0, ShrubPosition
	j draw_shrub
	
	draw_shrub: 
	bgt $t2, 31 end_draw_shrub
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_shrub
	
	end_draw_shrub: 
	li $t2, 0
	li $a0, TALLGRASS_COLOR
	lw $t0, BottomTallGrassPosition
	j draw_bottom_tall_grass
	
	draw_bottom_tall_grass: 
	bgt $t2, 31 end_draw_bottom_tall_grass
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	sw $a0 512($t0)
	sw $a0 640($t0)
	sw $a0 768($t0)
	sw $a0 896($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_bottom_tall_grass
	
	end_draw_bottom_tall_grass: 
	li $t2, 0
	li $t1, 0
	li $t0, 0
	lw $t1, HeartTaken
	beq $t1, 0, draw_heart
	j update_aligators

draw_heart:
	lw $s1, displayAddress
	li $s2, HEART_COLOR
	sw $s2, 4($s1)
	sw $s2, 12($s1)
	sw $s2, 128($s1)
	sw $s2, 132($s1)
	sw $s2, 136($s1)
	sw $s2, 140($s1)
	sw $s2, 144($s1)
	sw $s2, 260($s1)
	sw $s2, 264($s1)
	sw $s2, 268($s1)
	sw $s2, 392($s1)
	
	j update_aligators
	
update_aligators: 
	move_aligator1:
	lw $t2 Aligator1Moved
	la $t1 Aligator1Moved
	
	aligator_loop1:
	beq $t2, 31, back_aligator1
	lw $t0, Aligator1Position
	la $t6, Aligator1Position
	addi $t0, $t0, 4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_aligator2
	
	back_aligator1:
	la $t3, Aligator1Position
	lw $t4, Aligator1Position
	
	addi $t4, $t4, -124
	sw $t4, 0($t3)
	lw $t2, Aligator1Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_aligator2:
	lw $t2 Aligator2Moved
	la $t1 Aligator2Moved
	
	aligator_loop2:
	beq $t2, 31, back_aligator2
	lw $t0, Aligator2Position
	la $t6, Aligator2Position
	addi $t0, $t0, 4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_aligator3
	
	back_aligator2:
	la $t3, Aligator2Position
	lw $t4, Aligator2Position
	
	addi $t4, $t4, -124
	sw $t4, 0($t3)
	lw $t2, Aligator2Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_aligator3:
	lw $t2 Aligator3Moved
	la $t1 Aligator3Moved
	
	aligator_loop3:
	beq $t2, 31, back_aligator3
	lw $t0, Aligator3Position
	la $t6, Aligator3Position
	addi $t0, $t0, -4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_aligator4
	
	back_aligator3:
	la $t3, Aligator3Position
	lw $t4, Aligator3Position
	
	addi $t4, $t4, 124
	sw $t4, 0($t3)
	lw $t2, Aligator3Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_aligator4:
	lw $t2 Aligator4Moved
	la $t1 Aligator4Moved
	
	aligator_loop4:
	beq $t2, 31, back_aligator4
	lw $t0, Aligator4Position
	la $t6, Aligator4Position
	addi $t0, $t0, -4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_aligator5
	
	back_aligator4:
	la $t3, Aligator4Position
	lw $t4, Aligator4Position
	
	addi $t4, $t4, 124
	sw $t4, 0($t3)
	lw $t2, Aligator4Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_aligator5:
	lw $t2 Aligator5Moved
	la $t1 Aligator5Moved
	
	aligator_loop5:
	beq $t2, 31, back_aligator5
	lw $t0, Aligator5Position
	la $t6, Aligator5Position
	addi $t0, $t0, 4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_aligator6
	
	back_aligator5:
	la $t3, Aligator5Position
	lw $t4, Aligator5Position
	
	addi $t4, $t4, -124
	sw $t4, 0($t3)
	lw $t2, Aligator5Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_aligator6:
	lw $t2 Aligator6Moved
	la $t1 Aligator6Moved
	
	aligator_loop6:
	beq $t2, 31, back_aligator6
	lw $t0, Aligator6Position
	la $t6, Aligator6Position
	addi $t0, $t0, 4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j update_bee
	
	back_aligator6:
	la $t3, Aligator6Position
	lw $t4, Aligator6Position
	
	addi $t4, $t4, -124
	sw $t4, 0($t3)
	lw $t2, Aligator6Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)

update_bee:
	move_bee:
	lw $t2 BeeMoved
	la $t1 BeeMoved
	
	bee_loop:
	beq $t2, 15, back_bee
	lw $t0, BeePosition
	la $t6, BeePosition
	addi $t0, $t0, 8
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j draw_aligators
	
	back_bee:
	la $t3, BeePosition
	lw $t4, BeePosition
	
	addi $t4, $t4, -120
	sw $t4, 0($t3)
	lw $t2, BeeMoved
	addi $t2, $t2, -15
	sw $t2, 0($t1)
	
	
draw_aligators: 
	li $s1, ALIGATOR_COLOR
	lw $t0, Aligator1Position
	jal draw_rectangle
	
	lw $t0, Aligator2Position
	jal draw_rectangle
	
	lw $t0, Aligator3Position
	jal draw_rectangle
	
	lw $t0, Aligator4Position
	jal draw_rectangle
	
	lw $t0, Aligator5Position
	jal draw_rectangle
	
	lw $t0, Aligator6Position
	jal draw_rectangle
	
	j draw_bee

draw_bee:
	li $s1, BEE_COLOR
	lw $t0, BeePosition
	jal draw_rectangle
	
	j draw_frog
	
draw_map:
	lw $t0, TopGrassPosition
	li $a0, GRASS_COLOR
	draw_top_grass:
	bgt $t2, 31 end_draw_top_grass
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	sw $a0 512($t0)
	sw $a0 640($t0)
	sw $a0 768($t0)
	sw $a0 896($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_top_grass

	end_draw_top_grass:
	li $t2, 0
	li $a0, RIVER_COLOR
	lw $t0, RiverPosition
	j draw_river
	
	draw_river: 
	bgt $t2, 31 end_draw_river
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	sw $a0 512($t0)
	sw $a0 640($t0)
	sw $a0 768($t0)
	sw $a0 896($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_river
	
	end_draw_river: 
	li $t2, 0
	li $a0, SAND_COLOR
	lw $t0, SandPosition
	j draw_sand
	
	draw_sand: 
	 bgt $t2, 31 end_draw_sand
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_sand
	
	end_draw_sand: 
	li $t2, 0
	li $a0, ROAD_COLOR
	lw $t0, RoadPosition
	j draw_road
	
	draw_road: 
	bgt $t2, 31 end_draw_road
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	sw $a0 512($t0)
	sw $a0 640($t0)
	sw $a0 768($t0)
	sw $a0 896($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_road
	
	end_draw_road: 
	li $t2, 0
	li $a0, GRASS_COLOR
	lw $t0, BottomGrassPosition
	j draw_bottom_grass
	
	draw_bottom_grass: 
	 bgt $t2, 31 end_draw_bottom_grass
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	j draw_bottom_grass
	
	end_draw_bottom_grass: 
	li $t2, 0
	li $t1, 0
	li $t0, 0
	j check_goal1
	
check_goal1:
	lw $t1, Goal1Reached
	beq $t1, 1, draw_goal1_reached
	beq $t1, 0, draw_goal1_unreached

check_goal2:
	lw $t1, Goal2Reached
	beq $t1, 1, draw_goal2_reached
	beq $t1, 0, draw_goal2_unreached

check_goal3:
	lw $t1, Goal3Reached
	beq $t1, 1, draw_goal3_reached
	beq $t1, 0, draw_goal3_unreached

check_goal4:
	lw $t1, Goal4Reached
	beq $t1, 1, draw_goal4_reached
	beq $t1, 0, draw_goal4_unreached
	
	j update_logs

draw_goal1_reached:
	lw $t0, Goal1Position
	li $a0, 0xFF0000
	j draw_goal1	 
	
draw_goal1_unreached:
	lw $t0, Goal1Position
	li $a0, 0x4098bf
	j draw_goal1	

draw_goal2_reached:
	lw $t0, Goal2Position
	li $a0, 0xFF0000
	j draw_goal2

draw_goal2_unreached:
	lw $t0, Goal2Position
	li $a0, 0x4098bf
	j draw_goal2

draw_goal3_reached:
	lw $t0, Goal3Position
	li $a0, 0xFF0000
	j draw_goal3

draw_goal3_unreached:
	lw $t0, Goal3Position
	li $a0, 0x4098bf
	j draw_goal3

draw_goal4_reached:
	lw $t0, Goal4Position
	li $a0, 0xFF0000
	j draw_goal4

draw_goal4_unreached:
	lw $t0, Goal4Position
	li $a0, 0x4098bf
	j draw_goal4
		
		
draw_goal1: 
	bgt $t2, 3 draw_goal1_end
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	
	j draw_goal1
	
	draw_goal1_end:
	li $t2, 0
	j check_goal2

draw_goal2: 
	bgt $t2, 3 draw_goal2_end
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	
	j draw_goal2
	
	draw_goal2_end:
	li $t2, 0
	j check_goal3

draw_goal3: 
	bgt $t2, 3 draw_goal3_end
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	
	j draw_goal3
	
	draw_goal3_end:
	li $t2, 0
	j check_goal4

draw_goal4: 
	bgt $t2, 3 draw_goal4_end
	sw $a0 0($t0) 
	sw $a0 128($t0)
	sw $a0 256($t0)
	sw $a0 384($t0)
	
	addi $t2, $t2 1 
	addi $t0, $t0 4
	
	j draw_goal4
	
	draw_goal4_end:
	j update_logs

update_logs: 
	move_log1:
	lw $t2 Log1Moved
	la $t1 Log1Moved
	
	log_loop1:
	beq $t2, 31, back_log1
	lw $t0, Log1Position
	la $t6, Log1Position
	addi $t0, $t0, 4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_log2
	
	back_log1:
	la $t3, Log1Position
	lw $t4, Log1Position
	
	addi $t4, $t4, -124
	sw $t4, 0($t3)
	lw $t2, Log1Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_log2:
	lw $t2 Log2Moved
	la $t1 Log2Moved
	
	log_loop2:
	beq $t2, 31, back_log2
	lw $t0, Log2Position
	la $t6, Log2Position
	addi $t0, $t0, 4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_log3
	
	back_log2:
	la $t3, Log2Position
	lw $t4, Log2Position
	
	addi $t4, $t4, -124
	sw $t4, 0($t3)
	lw $t2, Log2Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_log3:
	lw $t2 Log3Moved
	la $t1 Log3Moved
	
	log_loop3:
	beq $t2, 31, back_log3
	lw $t0, Log3Position
	la $t6, Log3Position
	addi $t0, $t0, -4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_log4
	
	back_log3:
	la $t3, Log3Position
	lw $t4, Log3Position
	
	addi $t4, $t4, 124
	sw $t4, 0($t3)
	lw $t2, Log3Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_log4:
	lw $t2 Log4Moved
	la $t1 Log4Moved
	
	log_loop4:
	beq $t2, 31, back_log4
	lw $t0, Log4Position
	la $t6, Log4Position
	addi $t0, $t0, -4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j draw_logs
	
	back_log4:
	la $t3, Log4Position
	lw $t4, Log4Position
	
	addi $t4, $t4, 124
	sw $t4, 0($t3)
	lw $t2, Log4Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)

	
draw_logs: 
	li $s1, LOG_COLOR
	lw $t0, Log1Position
	jal draw_rectangle
	
	lw $t0, Log2Position
	jal draw_rectangle
	
	lw $t0, Log3Position
	jal draw_rectangle
	
	lw $t0, Log4Position
	jal draw_rectangle
	
	j update_cars
	
	
update_cars: 
	move_car1:
	lw $t2 Car1Moved
	la $t1 Car1Moved
	
	car_loop1:
	beq $t2, 31, back_car1
	lw $t0, Car1Position
	la $t6, Car1Position
	addi $t0, $t0, 4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_car2
	
	back_car1:
	la $t3, Car1Position
	lw $t4, Car1Position
	
	addi $t4, $t4, -124
	sw $t4, 0($t3)
	lw $t2, Car1Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_car2:
	lw $t2 Car2Moved
	la $t1 Car2Moved
	
	car_loop2:
	beq $t2, 31, back_car2
	lw $t0, Car2Position
	la $t6, Car2Position
	addi $t0, $t0, 4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_car3
	
	back_car2:
	la $t3, Car2Position
	lw $t4, Car2Position
	
	addi $t4, $t4, -124
	sw $t4, 0($t3)
	lw $t2, Car2Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_car3:
	lw $t2 Car3Moved
	la $t1 Car3Moved
	
	car_loop3:
	beq $t2, 31, back_car3
	lw $t0, Car3Position
	la $t6, Car3Position
	addi $t0, $t0, -4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j move_car4
	
	back_car3:
	la $t3, Car3Position
	lw $t4, Car3Position
	
	addi $t4, $t4, 124
	sw $t4, 0($t3)
	lw $t2, Car3Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
	move_car4:
	lw $t2 Car4Moved
	la $t1 Car4Moved
	
	car_loop4:
	beq $t2, 31, back_car4
	lw $t0, Car4Position
	la $t6, Car4Position
	addi $t0, $t0, -4
	sw $t0, 0($t6)
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	
	j draw_cars
	
	back_car4:
	la $t3, Car4Position
	lw $t4, Car4Position
	
	addi $t4, $t4, 124
	sw $t4, 0($t3)
	lw $t2, Car4Moved
	addi $t2, $t2, -31 
	sw $t2, 0($t1)
	
draw_cars: 
	li $s1, CAR_COLOR
	lw $t0, Car1Position
	jal draw_rectangle
	 
	lw $t0, Car2Position
	jal draw_rectangle
	
	lw $t0, Car3Position
	jal draw_rectangle 
	
	lw $t0, Car4Position
	jal draw_rectangle 
	
	j draw_frog

draw_frog:
	li, $t1, FROG_COLOR
	lw $t0, FrogPosition 	# $t0 stores the base address for display
	sw $t1 4($t0)
	sw $t1 8($t0)
	sw $t1 128($t0)
	sw $t1 132($t0)
	sw $t1 136($t0)
	sw $t1 140($t0)
	sw $t1 260($t0)
	sw $t1 264($t0)
	sw $t1 384($t0)
	sw $t1 388($t0)
	sw $t1 392($t0)
	sw $t1 396($t0)
	
	j draw_lives


draw_lives: 
	lw $t1, displayAddress
	addi $t1, $t1, 3848
	lw $t2, num_lives
	beq $t2, 1, life_one
	beq $t2, 2, life_two
	bgt $t2, 2, life_three
	j Exit
	
	
life_three:
	li $s1, 0xFF0000
	sw $s1, 0($t1) 
	sw $s1, 8($t1)
	sw $s1,16($t1)
	j Exit
	
life_two:	
	li $s1, 0xFF0000
	li $s2, 0x000000
	sw $s1, 0($t1) 
	sw $s1, 8($t1)
	sw $s2,16($t1)
	j Exit

life_one:	
	li $s1, 0xFF0000
	li $s2, 0x000000
	sw $s1, 0($t1) 
	sw $s2, 8($t1)
	sw $s2,16($t1)
	j Exit
	
print_page:
	li $t4, 0xEFE3AD
	lw $t0, displayAddress 
	jal draw_screen 
	

write_letter_A:
	lw $s1, displayAddress
	addi $s1, $s1, 640
	addi $s1, $s1, 36
	li $t1, 0x00FF00
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	sw $t1, 128($s1)
	sw $t1, 140($s1)
	sw $t1, 256($s1)
	sw $t1, 268($s1)
	sw $t1, 384($s1)
	sw $t1, 396($s1)
	sw $t1, 512($s1)
	sw $t1, 524($s1)
	sw $t1, 268($s1)
	sw $t1, 264($s1)
	sw $t1, 260($s1)
	
write_letter_M:
	lw $s1, displayAddress
	addi $s1, $s1, 640
	addi $s1, $s1, 56
	li $t1, 0x00FF00
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	sw $t1, 12($s1)
	sw $t1, 16($s1)
	sw $t1, 144($s1)
	sw $t1, 272($s1)
	sw $t1, 400($s1)
	sw $t1, 528($s1)
	sw $t1, 132($s1)
	sw $t1, 140($s1)
	sw $t1, 264($s1)
	
write_letter_E:
	lw $s1, displayAddress
	addi $s1, $s1, 640
	addi $s1, $s1, 80
	li $t1, 0x00FF00
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	
	sw $t1, 516($s1)
	sw $t1, 520($s1)
	sw $t1, 524($s1)
	
	

write_letter_G:
	lw $s1, displayAddress
	addi $s1, $s1, 640
	addi $s1, $s1, 16
	li $t1, 0x00FF00
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 516($s1)
	sw $t1, 520($s1)
	
	sw $t1, 524($s1)
	sw $t1, 396($s1)
	sw $t1, 268($s1)
	
	sw $t1, 268($s1)
	sw $t1, 264($s1)

write_letter_O:
	lw $s1, displayAddress
	addi $s1, $s1, 1408
	addi $s1, $s1, 36
	li $t1, 0x508800
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 516($s1)
	sw $t1, 520($s1)
	
	sw $t1, 524($s1)
	sw $t1, 396($s1)
	sw $t1, 268($s1)
	sw $t1, 140($s1)
	

write_letter_V:
	lw $s1, displayAddress
	addi $s1, $s1, 1408
	addi $s1, $s1, 56
	li $t1, 0x508800
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	
	sw $t1, 16($s1)
	sw $t1, 144($s1)
	sw $t1, 272($s1)
	
	sw $t1, 388($s1)
	sw $t1, 396($s1)
	
	sw $t1, 520($s1)

write_letter_E2:
	lw $s1, displayAddress
	addi $s1, $s1, 1408
	addi $s1, $s1, 80
	li $t1, 0x508800
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	
	sw $t1, 516($s1)
	sw $t1, 520($s1)
	sw $t1, 524($s1)
	

write_letter_P:
	lw $s1, displayAddress
	addi $s1, $s1, 2176
	addi $s1, $s1, 16
	li $t1, 0xFF0000
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 140($s1)
	sw $t1, 268($s1)
	
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)
	
write_letter_R:
	lw $s1, displayAddress
	addi $s1, $s1, 1408
	addi $s1, $s1, 100
	li $t1, 0x508800
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 140($s1)
	sw $t1, 268($s1)
	
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)
	
	sw $t1, 392($s1)
	sw $t1, 524($s1)


write_letter_R2:
	lw $s1, displayAddress
	addi $s1, $s1, 2176
	addi $s1, $s1, 36
	li $t1, 0xFF0000
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 140($s1)
	sw $t1, 268($s1)
	
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)
	
	sw $t1, 392($s1)
	sw $t1, 524($s1)

write_letter_E3:
	lw $s1, displayAddress
	addi $s1, $s1, 2176
	addi $s1, $s1, 56
	li $t1, 0xFF0000
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	
	sw $t1, 516($s1)
	sw $t1, 520($s1)

	
write_letter_S:
	lw $s1, displayAddress
	addi $s1, $s1, 2176
	addi $s1, $s1, 72
	li $t1, 0xFF0000
	
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	
	sw $t1, 128($s1)
	
	sw $t1, 256($s1)
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	sw $t1, 392($s1)

	sw $t1, 512($s1)
	sw $t1, 516($s1)
	sw $t1, 520($s1)

write_letter_S2:
	lw $s1, displayAddress
	addi $s1, $s1, 2176
	addi $s1, $s1, 88
	li $t1, 0xFF0000
	
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	
	sw $t1, 128($s1)
	
	sw $t1, 256($s1)
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	sw $t1, 392($s1)

	sw $t1, 512($s1)
	sw $t1, 516($s1)
	sw $t1, 520($s1)
	
write_letter_E4:
	lw $s1, displayAddress
	addi $s1, $s1, 2944
	addi $s1, $s1, 60
	li $t1, 0xFFFFFF
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	
	sw $t1, 516($s1)
	sw $t1, 520($s1)
	sw $t1, 524($s1)

write_speech:
	lw $s1, displayAddress
	addi $s1, $s1, 2944
	addi $s1, $s1, 52
	li $t1, 0xFFFFFF
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	
	
	sw $t1, 28($s1)
	sw $t1, 156($s1)

j Exit

print_pause:
	li $t4, BLACK_COLOR
	lw $t0, displayAddress 
	jal draw_screen

draw_pause:
	lw $t1, displayAddress
	addi $t1, $t1, 1072
	li $a1, 0xFFFFFF
	sw $a1, 0($t1)
	sw $a1, 128($t1)
	sw $a1, 256($t1)
	sw $a1, 384($t1)
	sw $a1, 512($t1)
	sw $a1, 640($t1)
	sw $a1, 768($t1)
	
	sw $a1, 4($t1)
	sw $a1, 132($t1)
	sw $a1, 260($t1)
	sw $a1, 388($t1)
	sw $a1, 516($t1)
	sw $a1, 644($t1)
	sw $a1, 772($t1)
	
	sw $a1, 8($t1)
	sw $a1, 136($t1)
	sw $a1, 264($t1)
	sw $a1, 392($t1)
	sw $a1, 520($t1)
	sw $a1, 648($t1)
	sw $a1, 776($t1)
	
	addi $t1, $t1 16
	sw $a1, 0($t1)
	sw $a1, 128($t1)
	sw $a1, 256($t1)
	sw $a1, 384($t1)
	sw $a1, 512($t1)
	sw $a1, 640($t1)
	sw $a1, 768($t1)
	
	sw $a1, 4($t1)
	sw $a1, 132($t1)
	sw $a1, 260($t1)
	sw $a1, 388($t1)
	sw $a1, 516($t1)
	sw $a1, 644($t1)
	sw $a1, 772($t1)
	
	sw $a1, 8($t1)
	sw $a1, 136($t1)
	sw $a1, 264($t1)
	sw $a1, 392($t1)
	sw $a1, 520($t1)
	sw $a1, 648($t1)
	sw $a1, 776($t1)

	
write_letter_Ep:
	lw $s1, displayAddress
	addi $s1, $s1, 2048
	addi $s1, $s1, 56
	li $t1, WHITE_COLOR
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	
	sw $t1, 516($s1)
	sw $t1, 520($s1)
	sw $t1, 524($s1)
	

write_letter_Pp:
	lw $s1, displayAddress
	addi $s1, $s1, 2048
	addi $s1, $s1, 16
	li $t1, 0xFFFFFF
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 140($s1)
	sw $t1, 268($s1)
	
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)
	
write_letter_Rp:
	lw $s1, displayAddress
	addi $s1, $s1, 2048
	addi $s1, $s1, 36
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 140($s1)
	sw $t1, 268($s1)
	
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)
	
	sw $t1, 392($s1)
	sw $t1, 524($s1)


	
write_letter_Sp:
	lw $s1, displayAddress
	addi $s1, $s1, 2048
	addi $s1, $s1, 76
	
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	
	sw $t1, 128($s1)
	
	sw $t1, 256($s1)
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	sw $t1, 392($s1)

	sw $t1, 512($s1)
	sw $t1, 516($s1)
	sw $t1, 520($s1)

write_letter_S2p:
	lw $s1, displayAddress
	addi $s1, $s1, 2048
	addi $s1, $s1, 92
	
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	
	sw $t1, 128($s1)
	
	sw $t1, 256($s1)
	sw $t1, 260($s1)
	sw $t1, 264($s1)

	sw $t1, 392($s1)

	sw $t1, 512($s1)
	sw $t1, 516($s1)
	sw $t1, 520($s1)

write_letter_Pp2:
	lw $s1, displayAddress
	addi $s1, $s1, 2944
	addi $s1, $s1, 48
	li $t1, 0xFF0000
	
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	
	addi $s1, $s1, 8
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	sw $t1, 512($s1)
	
	sw $t1, 4($s1)
	sw $t1, 8($s1)
	sw $t1, 12($s1)
	
	sw $t1, 140($s1)
	sw $t1, 268($s1)
	
	
	sw $t1, 260($s1)
	sw $t1, 264($s1)
	addi $s1, $s1, 20
	sw $t1, 0($s1)
	sw $t1, 128($s1)

	j Exit
	
draw_screen:
# Draw a rectangle:
add $t6, $zero, $zero	# Set index value ($t6) to zero
draw_screen_loop:
beq $t6, 32, end_screen 	# If $t6 == height ($a0), jump to end

# Draw a line:
add $t5, $zero, $zero	# Set index value ($t5) to zero
draw_screen_line_loop:
beq $t5, 32, end_draw_screen_line  # If $t5 == width ($a1), jump to end
sw $t4, 0($t0)		#   - Draw a pixel at memory location $t0
addi $t0, $t0, 4	#   - Increment $t0 by 4
addi $t5, $t5, 1	#   - Increment $t5 by 1
j draw_screen_line_loop	#   - Jump to start of line drawing loop

end_draw_screen_line:

addi $t0, $t0, 0	# Set $t0 to the first pixel of the next line.
			# Note: This value really should be calculated.
addi $t6, $t6, 1	#   - Increment $t6 by 1
j draw_screen_loop	#   - Jump to start of rectangle drawing loop
end_screen:

jr $ra		# jump back to the calling program


draw_rectangle:
# Draw a rectangle:
add $t6, $zero, $zero	# Set index value ($t6) to zero
draw_rect_loop:
beq $t6, 4, end_rect 	# If $t6 == height ($a0), jump to end

# Draw a line:
add $t5, $zero, $zero # Set index value ($t5) to zero
draw_line_loop:
beq $t5, 8, end_draw_line  # If $t5 == width ($a1), jump to end

addi $t9, $zero, 128
div $t0, $t9
mfhi $t8

bne $t8, $zero, next_line
beq $t5, $zero, next_line

addi $t0, $t0, -128
add $t7, $zero, 1
next_line:

sw $s1, 0($t0)		#   - Draw a pixel at memory location $t0
addi $t0, $t0, 4	#   - Increment $t0 by 4
addi $t5, $t5, 1	#   - Increment $t5 by 1
j draw_line_loop	#   - Jump to start of line drawing loop

end_draw_line:
bne $t7, 1, next_line2
addi $t0, $t0, 128	# Set $t0 to the first pixel of the next line.
next_line2:		
addi $t0, $t0, 96
			# Note: This value really should be calculated.
addi $t6, $t6, 1	#   - Increment $t6 by 1
j draw_rect_loop	#   - Jump to start of rectangle drawing loop
end_rect:

li $t7, 0
li $t8, 0	
li $t9, 0
jr $ra 			# jump back to the calling program


Exit:
li $v0, 32 # terminate the program gracefully
li $a0 100
syscall

j main
