extends Node

signal matched
signal player_joined
signal player_left

const SERVER_KEY := "defaultkey"
const HOST := "localhost"
const PORT := 7350
const SCHEME := "http"

var user_id: String = ""
var hash_key: String = ""

var _client: NakamaClient
var _session: NakamaSession
var _bridge: NakamaMultiplayerBridge
var _socket: NakamaSocket

var _players: Dictionary = {}

class ConnectionPlayer:
	var session_id: String
	var peer_id: int
	var username: String
	
	func _init(_session_id: String, _username: String, _peer_id: int) -> void:
		session_id = _session_id
		username = _username
		peer_id = _peer_id

	static func from_presence(presence: NakamaRTAPI.UserPresence, _peer_id: int) -> ConnectionPlayer:
		return ConnectionPlayer.new(presence.session_id, presence.username, _peer_id)

	static func from_dict(data: Dictionary) -> ConnectionPlayer:
		return ConnectionPlayer.new(data['session_id'], data['username'], int(data['peer_id']))

	func to_dict() -> Dictionary:
		return {
			session_id = session_id,
			username = username,
			peer_id = peer_id,
		}
	
	func get_clean_username() -> String:
		return username.get_basename()

static func serialize_players(_players: Dictionary) -> Dictionary:
	var result := {}
	for key in _players:
		result[key] = _players[key].to_dict()
	return result

static func unserialize_players(_players: Dictionary) -> Dictionary:
	var result := {}
	for key in _players:
		result[key] = Player.from_dict(_players[key])
	return result
	

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	
	_client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)
	_client.timeout = 30 # seconds


# Creates a Nakama Session and a Socket for given user
func authenticate(username: String) -> int:
	user_id = username
	
	for i in 30:
		hash_key += String(randi() % 10)
	
	_session = yield(_client.authenticate_device_async(hash_key, user_id + "." + hash_key), "completed")
	if _session.is_exception():
		print("An error occurred: %s" % _session)
		return 1
	
	_socket = Nakama.create_socket_from(_client)
	var connected: NakamaAsyncResult = yield(_socket.connect_async(_session), "completed")
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return 2
	
	_bridge = NakamaMultiplayerBridge.new(_socket)
	_bridge.connect("match_joined", self, "_on_matchmaker_matched")
	get_tree().network_peer = _bridge.multiplayer_peer
	return 0


# Assigns a match to current socket
func assign_match() -> void:
	var result = yield(_socket.add_matchmaker_async("*", 2, 2), "completed")
	
	if result.is_exception():
		return
	_bridge.start_matchmaking(result)


func _on_matchmaker_matched() -> void:
	var my_peer_id := get_tree().get_network_unique_id()
	var presence: NakamaRTAPI.UserPresence = _bridge.get_user_presence_for_peer(my_peer_id)
	var player = ConnectionPlayer.from_presence(presence, my_peer_id)
	_players[my_peer_id] = player
	emit_signal("matched", my_peer_id)


func _on_network_peer_connected(peer_id: int) -> void:
	print("Peer connected: %s" % str(peer_id))
	var presence: NakamaRTAPI.UserPresence = _bridge.get_user_presence_for_peer(peer_id)
	var player = ConnectionPlayer.from_presence(presence, peer_id)
	_players[peer_id] = player
	emit_signal("player_joined", player)


func _on_network_peer_disconnected(peer_id: int) -> void:
	var player = _players.get(peer_id)
	if player != null:
		emit_signal("player_left")
		_players.erase(peer_id)

