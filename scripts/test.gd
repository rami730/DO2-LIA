extends Node

var database : SQLite
var results_array : Array
var path = "res://resources/test_db.db"
var database_table = "MQTT_LOG"

#test environment
func _ready():
	var looping = true
	#gets data from database every 10 seconds
	while looping:
		#try fetch_all_data() and/or fetch_specific_date(start_date, end_date)	
		fetch_all_data()
		print("****************************************************")
		for result in results_array:
			result.print_all()
			
		#fetch_specific_data("2023-01-23", "2023-07-06")
		#print("****************************************************")
		#for result in results_array:
		#	result.print_all()
		
		await get_tree().create_timer(10.0).timeout

	
#helper function to parse JSON
func parse_json(json_string):
	var json = JSON.new()
	if json_string != null:
		var error = json.parse(json_string)
		if error == OK:
			return json.get_data()
		else:
			print("JSON parse error: ", error)
			return null

#helper function to make sure timestamp is correct		
func is_valid_timestamp(timestamp: String):
	#convert timestamp to "yyyy-mm-dd" format
	timestamp = timestamp.substr(0, 10)
	
	#make sure timestamp is in the correct format
	if timestamp[4] != "-" or timestamp[7] != "-":
		return false
	
	#split the timestamp into components
	var components = timestamp.split("-")
	var year = int(components[0])
	var month = int(components[1])
	var day = int(components[2])
	
	#check that date is in acceptable range
	if year < 0000 or year > 9999:
		return false
	elif  month < 1 or month > 12:
		return false
	elif  day < 1 or day > 31:
		return false

	#if all checks pass the timestamp is considered valid
	return true

func fetch_all_data():
	results_array = []
	
	#check that the database exsists
	if !FileAccess.file_exists(path):
		print("Database not found")
		return
	
	#initilize database
	database = SQLite.new()
	database.path = path
	database.open_db()
	
	#check that column exsists in database
	var success = database.query("SELECT PAYLOAD FROM " + database_table)
	if success == false:
		print("Query failed")
		return

	#process the query results
	for payload_dict in database.query_result:
		#extract data and convert into a JSON string
		var payload_json = payload_dict["PAYLOAD"]
		
		#convert the JSON string back into a dictionary
		var parsed_payload = parse_json(payload_json)
		
		if typeof(parsed_payload) == TYPE_DICTIONARY:
			#make sure payload has correct entries
			if parsed_payload.has("question_node") and parsed_payload.has("reference_node") and parsed_payload.has("answer") and parsed_payload.has("is_correct") and parsed_payload.has("timestamp"): 
				var question_node = int(parsed_payload["question_node"])
				var reference_node = int(parsed_payload["reference_node"])
	
				var answer = parsed_payload["answer"]
				if answer.to_lower() != "before" and answer.to_lower() != "after":
					print("answer in payload is invalid")
					continue
						
				var is_correct = parsed_payload["is_correct"]
				if is_correct.to_lower() == "true":
					is_correct = true
				elif is_correct.to_lower() == "false":
					is_correct = false
				else:
					print("is_correct in payload is invalid")
					continue
				
				var timestamp = parsed_payload["timestamp"]
				
				#make sure timestamp is in correct format
				var time = Time.get_unix_time_from_datetime_string(parsed_payload["timestamp"])
				if time != 0 and is_valid_timestamp(parsed_payload["timestamp"]) == true:
					#make new instance of Results class and append to array
					var result = Results.new(question_node, reference_node, answer, is_correct, timestamp)
					results_array.append(result)
		else:
			print("Failed to parse JSON")

	
func fetch_specific_data(_start_date: String, _end_date: String):
	#convert string to Time object
	var start_date = Time.get_unix_time_from_datetime_string(_start_date)
	var end_date = Time.get_unix_time_from_datetime_string(_end_date)
	
	var temp_array : Array
	fetch_all_data()
	
	for result in results_array:
		var current_timestamp = Time.get_unix_time_from_datetime_string(result.timestamp.substr(0, 10))
		#adds current result to temp_array if OK
		if start_date <= current_timestamp and current_timestamp <= end_date:
			temp_array.append(result)
	
	#updates array with new data
	results_array = temp_array
