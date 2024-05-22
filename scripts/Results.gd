class_name Results

#variable decleration
var question_node: String
var reference_node: String
var answer: String
var timestamp: String

#constructor
func _init(_question_node: String, _reference_node: String, _answer: String, _timestamp: String):
	question_node = _question_node
	reference_node = _reference_node
	answer = _answer
	timestamp = _timestamp

#prototype print function
func print_all():
	print(question_node + " " + reference_node + " " + answer + " " + timestamp)
