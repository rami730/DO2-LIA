import sqlite3
import json

connection = sqlite3.connect("test_db.db")
cursor = connection.cursor()

#CREATE
cursor.execute("CREATE TABLE MQTT_LOG (ID INTEGER PRIMARY KEY, TOPIC TEXT, PAYLOAD BLOB, TIME_STAMP TEXT)")

#INSERT
payload1 = json.dumps({"question_node": "2", "reference_node": "1", "answer": "before", "timestamp": "2024-05-22 13:14:50.260921"})
cursor.execute("INSERT INTO MQTT_LOG (TOPIC, PAYLOAD, TIME_STAMP) VALUES(?, ?, ?)",
                ("blekingemuseum/timeline/value", payload1, "2024-05-22 13:14:51.260921"))

payload2 = json.dumps({"question_node": "3", "reference_node": "2", "answer": "after", "timestamp": "2024-05-23 13:14:51.260921"})
cursor.execute("INSERT INTO MQTT_LOG (TOPIC, PAYLOAD, TIME_STAMP) VALUES(?, ?, ?)",
               ("blekingemuseum/timeline/value", payload2, "2024-05-22 13:15:51.260921"))

payload3 = json.dumps({"question_node": "14", "reference_node": "3", "answer": "after", "timestamp": "2024-05-23 13:17:51.260921"})
cursor.execute("INSERT INTO MQTT_LOG (TOPIC, PAYLOAD, TIME_STAMP) VALUES(?, ?, ?)",
               ("blekingemuseum/timeline/value", payload3, "2024-05-22 13:15:51.260921"))


#READ
print("READ EXAMPLE: ")
for row in cursor.execute("SELECT * FROM MQTT_LOG"):
    print(row)

#DELETE
#cursor.execute("DELETE FROM MQTT_LOG WHERE ID = 1 OR ID = 2")
#print("DELETE EXAMPLE: ")
#for row in cursor.execute("SELECT * FROM MQTT_LOG"):
#    print(row)

connection.commit()
connection.close()