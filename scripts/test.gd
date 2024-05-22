extends Node

#test environment
func _ready():
	#creates a new instance of Results class with parameters
	var my_result = Results.new("Node 1", "Node 2", "Before", "2024-05-22 17:28")
	my_result.print_all()
	print(my_result.answer)
