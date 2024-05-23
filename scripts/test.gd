extends Node

var database : SQLite
var results_array : Array

#test environment
func _ready():	
	#initilize database
	database = SQLite.new()
	database.path = "res://resources/test_db.db"
	database.open_db()
	
	database.query("SELECT PAYLOAD FROM MQTT_LOG")
	
	#process the query results
	for payload_dict in database.query_result:
		#extract data and convert into a JSON string
		var payload_json = payload_dict["PAYLOAD"]
		
		#convert the JSON string back into a dictionary
		var parsed_payload = parse_json(payload_json)
		
		if typeof(parsed_payload) == TYPE_DICTIONARY:
			#creates a new instance of Results class with parameters and add to array
			var question_node = int(parsed_payload["question_node"])
			var reference_node = int(parsed_payload["reference_node"])
			var answer = parsed_payload["answer"]
			var timestamp = parsed_payload["timestamp"]
			var result = Results.new(question_node, reference_node, answer, timestamp)
			results_array.append(result)
		else:
			print("Failed to parse JSON")
	
	#checking that array is filled		
	for result in results_array:
		result.print_all()


#helper function to parse JSON
func parse_json(json_string):
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		return json.get_data()
	else:
		print("JSON parse error: ", error)
		return null
