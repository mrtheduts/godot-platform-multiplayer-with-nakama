extends Node

const SERVER_KEY := "defaultkey"
const HOST := "localhost"
const PORT := 7350
const SCHEME := "http"

var _user_id: String = ""

var _client: NakamaClient
var _session: NakamaSession
var _socket: NakamaSocket

# Called when the node enters the scene tree for the first time.
func _ready():
	_client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)
	_client.timeout = 30 # seconds
	
	print(_client)


func authenticate(username: String) -> int:
	_user_id = username
	
	_session = yield(_client.authenticate_device_async(_user_id), "completed")
#	print("_session: %s" % _session)
	if _session.is_exception():
		print("An error occurred: %s" % _session)
		return 1
	
#	print("Successfully authenticated: %s" % _session)
	
	_socket = Nakama.create_socket_from(_client)
	var connected : NakamaAsyncResult = yield(_socket.connect_async(_session), "completed")
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return 2
	print("Socket connected.")
	
	return 0

func create_match() -> void:
	var data = yield(_socket.create_match_async(), "completed")
	
	print("Match data: %s" % data)

