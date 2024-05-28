class_name Results

#variable decleration
var question_node: int
var reference_node: int
var answer: String
var is_correct: bool
var timestamp: String

#constructor
func _init(_question_node: int, _reference_node: int, _answer: String, _is_correct: bool, _timestamp: String):
	question_node = _question_node
	reference_node = _reference_node
	answer = _answer
	is_correct = _is_correct
	timestamp = _timestamp

#prototype print function
func print_all():
	print(str(question_node) + " " + str(reference_node) + " " + answer + " " + str(is_correct) + " " + timestamp)
