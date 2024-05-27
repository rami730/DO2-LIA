extends Node

var database : SQLite
var results_array : Array
var path = "res://resources/test_db.db"

#test environment
func _ready():
	#try fetch_all_data() and/or fetch_specific_date(start_date, end_date)	
	fetch_all_data()
	print("****************************************************")
	for result in results_array:
		result.print_all()
		
	#fetch_specific_data("2023-05-23", "2023-06-06")
	#print("****************************************************")
	#for result in results_array:
	#	result.print_all()

	
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
	#regular expression to match "yyyy-mm-dd" format
	var regex = "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
	
	#check if the timestamp matches the format
	if timestamp.match(regex) == null:
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
	var success = database.query("SELECT PAYLOAD FROM MQTT_LOG")
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
			if parsed_payload.has("question_node") and parsed_payload.has("reference_node") and parsed_payload.has("answer") and parsed_payload.has("timestamp"): 
				var question_node = int(parsed_payload["question_node"])
				var reference_node = int(parsed_payload["reference_node"])
				var answer = parsed_payload["answer"]
				var timestamp = parsed_payload["timestamp"]
				
				#make sure timestamp is in correct format
				var time = Time.get_unix_time_from_datetime_string(parsed_payload["timestamp"])
				if time != 0 and is_valid_timestamp(parsed_payload["timestamp"]) == true:
					#make new instance of Results class and append to array
					var result = Results.new(question_node, reference_node, answer, timestamp)
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
