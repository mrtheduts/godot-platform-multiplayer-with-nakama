extends Node

signal matched

const SERVER_KEY := "defaultkey"
const HOST := "localhost"
const PORT := 7350
const SCHEME := "http"

var user_id: String = ""
var hash_key: String = ""

var _client: NakamaClient
var _session: NakamaSession
var _socket: NakamaSocket
var _ticket

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)
	_client.timeout = 30 # seconds


# Creates a Nakama Session and a Socket for given user
func authenticate(username: String) -> int:
	user_id = username
	
	for i in 10:
		hash_key += String(randi() % 10)
	
	_session = yield(_client.authenticate_device_async(user_id + hash_key), "completed")
	if _session.is_exception():
		print("An error occurred: %s" % _session)
		return 1
	
	_socket = Nakama.create_socket_from(_client)
	var connected: NakamaAsyncResult = yield(_socket.connect_async(_session), "completed")
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return 2
	
	_socket.connect("received_matchmaker_matched", self, "_on_matchmaker_matched")
	return 0


# Assigns a match to current socket
func assign_match() -> void:
	var result = yield(_socket.add_matchmaker_async("*", 2, 2), "completed")
	
	if result.is_exception():
		pass
#		leave()
#		emit_signal("error", "Unable to join match making pool")
	else:
		_ticket = result.ticket


func _on_matchmaker_matched(data: NakamaRTAPI.MatchmakerMatched) -> void:
	print("MatchmakerMatched data: %s" % data)
	
	var result = yield(_socket.join_matched_async(data), "completed")
	print("Result:  %s" % result)
	emit_signal("matched")


func create_match() -> void:
	var data = yield(_socket.create_match_async(), "completed")
	print("Match data: %s" % data)


func join_match() -> void:
	var result = yield(_socket.add_matchmaker_async("*", 2, 2), "completed")
