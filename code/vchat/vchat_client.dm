//These are sent to the client via browse_rsc() in advance so the HTML can access them.
var/list/chatResources = list(
	"code/vchat/js/polyfills.js", //Functions because IE is bad
	"code/vchat/js/vchat.js", //Main VChat stuff
	"code/vchat/js/vue.js", //UI framework
	"code/vchat/css/semantic.css", //UI framework
	"code/vchat/css/vchat-font-embedded.css", //Mini icons file
	"code/vchat/css/ss13styles.css" //Ingame styles
)

/proc/__to_chat(var/target, var/message)
	if(isclient(target))
		var/client/C = target
		vchat_add_message(C.ckey,message)
	else if(ismob(target))
		var/mob/M = target
		if(M.ckey)
			vchat_add_message(M.ckey,message)

	to_chat_immediate(target, world.time, message)

//Should match the value set in the browser js
#define MAX_COOKIE_LENGTH 5
#define BACKLOG_LENGTH 20 MINUTES

//This is used to convert icons to base64 <image> strings, because byond stores icons in base64 in savefiles.
GLOBAL_DATUM_INIT(iconCache, /savefile, new("data/iconCache.sav")) //Cache of icons for the browser output

//The main object attached to clients, created when they connect, and has start() called on it in client/New()
/datum/chatOutput
	var/client/owner = null
	var/loaded = 0
	var/list/message_queue = list()
	var/cookieSent = 0
	var/broken = FALSE

	var/last_topic_time = 0
	var/too_many_topics = 0
	var/topic_spam_limit = 5 //Just enough to get over the startup and such

/datum/chatOutput/New(client/C)
	. = ..()

	owner = C

/datum/chatOutput/Destroy()
	owner = null
	. = ..()

//Called from client/New() in a spawn()
/datum/chatOutput/proc/start()
	if(!owner)
		qdel(src)
		return FALSE

	if(!winexists(owner, "htmloutput"))
		spawn()
			alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		broken = TRUE
		return FALSE

	if(!owner) // In case the client vanishes before winexists returns
		qdel(src)
		return FALSE

	if(winget(owner, "htmloutput", "is-disabled") == "false")
		done_loading()

	else
		load()

	return TRUE

//Attempts to actually load the HTML page into the client's UI
/datum/chatOutput/proc/load()
	set waitfor = FALSE
	if(!owner)
		qdel(src)
		return

	//Perform sqllite setup/load
	load_database()

	//Attempt to actually push the files and HTML page into their cache and browser respectively. Loaded will be set by Topic() when the JS in the HTML fires it.
	for(var/attempts in 1 to 5)
		for(var/asset in global.chatResources)
			owner << browse_rsc(file(asset))

		for(var/subattempts in 1 to 3)
			owner << browse(file2text("code/vchat/html/htmlchat.html"), "window=htmloutput")
			sleep(100)
			if(!owner)
				qdel(src)
				return
			if(loaded)
				return

//var/list/joins = list() //Just for testing with the below
//Called by Topic, when the JS in the HTML page finishes loading
/datum/chatOutput/proc/done_loading()
	if(loaded)
		return

	loaded = TRUE
	winset(owner, "htmloutput", "is-disabled=false")
	push_queue()
	send_playerinfo()

	/*
	spawn(20)
		if(owner.ckey in joins)
			return
		joins += owner.ckey
		to_chat(owner,"<span class='game say'><b>Test Person</b> says, \"Testing say message.\"</span>")
		to_chat(owner,"<span class='notice'>Testing notice message.</span>")
		to_chat(owner,"<span class='danger'>Testing danger message.</span>")
		to_chat(owner,"<span class='secradio'>\[Security\] <b>Secu Person</b> says, \"Testing radio message.\"</span>")
		to_chat(owner,"<span class='ooc'><span class='everyone'>Testing OOC message.</span></span>")
		to_chat(owner,"<span class='ooc'><span class='looc'>Testing LOOC message.</span></span>") //Yeah that's really how the game does it
		to_chat(owner,"<span class='admin_channel'>Testing asay message.</span>")

		to_chat(owner,"<span class='game say'><b>Test Person</b> says, \"Testing say message 2.\"</span>")
		to_chat(owner,"<span class='notice'>Testing notice message 2.</span>")
		to_chat(owner,"<span class='danger'>Testing danger message 2.</span>")
		to_chat(owner,"<span class='secradio'>\[Security\] <b>Secu Person</b> says, \"Testing radio message 2\".</span>")
		to_chat(owner,"<span class='ooc'><span class='everyone'>Testing OOC message 2.</span></span>")
		to_chat(owner,"<span class='ooc'><span class='looc'>Testing LOOC message 2.</span></span>")
		to_chat(owner,"<span class='admin_channel'>Testing asay message 2.</span>")

		to_chat(owner,"<span class='game say'><b>Test Person</b> says, \"Testing say message 3.\"</span>")
		to_chat(owner,"<span class='notice'>Testing notice message 3.</span>")
		to_chat(owner,"<span class='danger'>Testing danger message 3.</span>")
		to_chat(owner,"<span class='secradio'>\[Security\] <b>Secu Person</b> says, \"Testing radio message 3\".</span>")
		to_chat(owner,"<span class='ooc'><span class='everyone'>Testing OOC message 3.</span></span>")
		to_chat(owner,"<span class='ooc'><span class='looc'>Testing LOOC message 3.</span></span>")
		to_chat(owner,"<span class='admin_channel'>Testing asay message 3.</span>")

		to_chat(owner,"<span class='game say'><b>Test Person</b> says, \"Testing say message 4.\"</span>")
		to_chat(owner,"<span class='notice'>Testing notice message 4.</span>")
		to_chat(owner,"<span class='danger'>Testing danger message 4.</span>")
		to_chat(owner,"<span class='secradio'>\[Security\] <b>Secu Person</b> says, \"Testing radio message 4\".</span>")
		to_chat(owner,"<span class='ooc'><span class='everyone'>Testing OOC message 4.</span></span>")
		to_chat(owner,"<span class='ooc'><span class='looc'>Testing LOOC message 4.</span></span>")
		to_chat(owner,"<span class='admin_channel'>Testing asay message 4.</span>")

		to_chat(owner,"<span class='game say'><b>Test Person</b> says, \"Testing say message 5.\"</span>")
		to_chat(owner,"<span class='notice'>Testing notice message 5.</span>")
		to_chat(owner,"<span class='danger'>Testing danger message 5.</span>")
		to_chat(owner,"<span class='secradio'>\[Security\] <b>Secu Person</b> says, \"Testing radio message 5\".</span>")
		to_chat(owner,"<span class='ooc'><span class='everyone'>Testing OOC message 5.</span></span>")
		to_chat(owner,"<span class='ooc'><span class='looc'>Testing LOOC message 5.</span></span>")
		to_chat(owner,"<span class='admin_channel'>Testing asay message 5.</span>")

		to_chat(owner,"<span class='game say'><b>The Clown</b> says, \"Honk!\"</span>")
		to_chat(owner,"<span class='game say'><b>The Clown</b> says, \"Honk!\"</span>")
		to_chat(owner,"<span class='game say'><b>The Clown</b> says, \"Honk!\"</span>")
		to_chat(owner,"<span class='game say'><b>The Clown</b> says, \"Honk!\"</span>")
		to_chat(owner,"<span class='game say'><b>The Clown</b> says, \"Honk!\"</span>")
		to_chat(owner,"<span class='game say'><b>The Clown</b> says, \"Honk!\"</span>")

		var/mob/fox/fox = new()
		to_chat(owner,"<span class='notice'>[bicon(fox)] Image Testing</span>")
		*/

//Perform DB shenanigans
/datum/chatOutput/proc/load_database()
	var/list/results = vchat_get_messages(owner.ckey, world.time - BACKLOG_LENGTH)
	for(var/list/message in results)
		message_queue[++message_queue.len] = message

//Empty the message queue
/datum/chatOutput/proc/push_queue()
	for(var/list/pending in message_queue)
		to_chat_immediate(owner, pending["time"], pending["message"])

	message_queue.Cut()
	message_queue = null

//Provide the JS with who we are
/datum/chatOutput/proc/send_playerinfo()
	if(!owner)
		qdel(src)
		return

	var/list/playerinfo = list("evttype" = "byond_player", "cid" = owner.computer_id, "ckey" = owner.ckey, "address" = owner.address)
	send_event(playerinfo)

//Ugh byond doesn't handle UTF-8 well so we have to do this.
/proc/jsEncode(var/list/message) {
	if(!islist(message))
		CRASH("Passed a non-list to encode.")
		return; //Necessary?

	return url_encode(url_encode(json_encode(message)))
}

//Send a side-channel event to the chat window
/datum/chatOutput/proc/send_event(var/event, var/client/C = owner)
	C << output(jsEncode(event), "htmloutput:get_event")

//Just produces a message for using in keepalives from the server to the client
/datum/chatOutput/proc/keepalive()
	return list("evttype" = "keepalive_server")

//Redirected from client/Topic when the user clicks a link that pertains directly to the chat (when src == "chat")
/datum/chatOutput/Topic(var/href, var/list/href_list)
	if(usr.client != owner)
		return 1

	if(last_topic_time > (world.time - 30))
		too_many_topics++
		if(too_many_topics >= topic_spam_limit)
			log_and_message_admins("Kicking [key_name(owner)] - VChat Topic() spam")
			to_chat(owner,"<span class='danger'>You have been kicked due to spamming VChat Topic(). Don't just spam settings changes.")
			qdel(owner)
			qdel(src)
			return
	else
		too_many_topics = 0
	last_topic_time = world.time

	var/list/params = list()
	for(var/key in href_list)
		if(length(key) > 7 && findtext(key, "param"))
			var/param_name = copytext(key, 7, -1)
			var/item = href_list[key]
			params[param_name] = item

	var/data
	switch(href_list["proc"])
		if("not_ready")
			CRASH("Tried to send a message to [owner.ckey] chatOutput before it was ready!")
		if("done_loading")
			data = done_loading(arglist(params))
		if("keepalive_client")
			data = keepalive(arglist(params))
		if("ident")
			data = bancheck(arglist(params))
		if("darkmode")
			data = owner.toggle_darkmode(arglist(params))

	if(data)
		send_event(event = data)

//Check relevant client info reported from JS
/datum/chatOutput/proc/bancheck(var/clientdata)
	var/list/info = json_decode(clientdata)
	var/ckey = info["ckey"]
	var/ip = info["ip"]
	var/cid = info["cid"]

	//Never connected? How sad!
	if(!cid && !ip && !ckey)
		return

	var/list/ban = world.IsBanned(key = ckey, address = ip, computer_id = cid)
	if(ban)
		log_and_message_admins("[key_name(owner)] has a cookie from a banned account! (Cookie: [ckey], [ip], [cid])")

//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(var/icon/icon, var/iconKey = "misc")
	if (!isicon(icon)) return FALSE

	GLOB.iconCache[iconKey] << icon
	var/iconData = GLOB.iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext(partial[2], 3, -5), "\n", "")

/proc/bicon(var/obj, var/use_class = 1, var/custom_classes = "")
	var/class = use_class ? "class='icon misc [custom_classes]'" : null
	if (!obj)
		return

	var/static/list/bicon_cache = list()
	if (isicon(obj))
		if (!bicon_cache["\ref[obj]"]) // Doesn't exist yet, make it.
			bicon_cache["\ref[obj]"] = icon2base64(obj)

		return "<img [class] src='data:image/png;base64,[bicon_cache["\ref[obj]"]]'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = obj
	var/key = "[istype(A.icon, /icon) ? "\ref[A.icon]" : A.icon]:[A.icon_state]"
	if (!bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I = icon(A.icon, A.icon_state, SOUTH, 1)
		if (ishuman(obj))
			I = getFlatIcon(obj,SOUTH) //Ugly
		bicon_cache[key] = icon2base64(I, key)
	if(use_class)
		class = "class='icon [A.icon_state] [custom_classes]'"

	return "<img [class] src='data:image/png;base64,[bicon_cache[key]]'>"

//Checks if the message content is a valid to_chat message
/proc/is_valid_tochat_message(message)
	return istext(message)

//Checks if the target of to_chat is something we can send to
/proc/is_valid_tochat_target(target)
	return !istype(target, /savefile) && (ismob(target) || islist(target) || isclient(target) || target == world)

//Actually delivers the message to the client's browser window via client << output()
// Call using macro: to_chat(target, message)
var/to_chat_filename
var/to_chat_line
var/to_chat_src
/proc/to_chat_immediate(target, time, message)
	if(!is_valid_tochat_message(message) || !is_valid_tochat_target(target))
		target << message

		// Info about the "message"
		if(isnull(message))
			message = "(null)"
		else if(istype(message, /datum))
			var/datum/D = message
			message = "([D.type]): '[D]'"
		else if(!is_valid_tochat_message(message))
			message = "(bad message) : '[message]'"

		// Info about the target
		var/targetstring = "'[target]'"
		if(istype(target, /datum))
			var/datum/D = target
			targetstring += ", [D.type]"

		// The final output
		log_debug("to_chat called with invalid message/target: [to_chat_filename], [to_chat_line], [to_chat_src], Message: '[message]', Target: [targetstring]")
		return

	else if(is_valid_tochat_message(message))
		if(istext(target))
			log_debug("Somehow, to_chat got a text as a target")
			return

		message = replacetext(message, "\n", "<br>")

		if(findtext(message, "\improper"))
			message = replacetext(message, "\improper", "")
		if(findtext(message, "\proper"))
			message = replacetext(message, "\proper", "")

		if(isnull(time))
			time = world.time

		var/client/C
		if(istype(target, /client))
			C = target
		if(ismob(target))
			C = target:client

		if(C && C.chatOutput)
			if(C.chatOutput.broken)
				C << message
				return

			if(!C.chatOutput.loaded && C.chatOutput.message_queue && islist(C.chatOutput.message_queue))
				C.chatOutput.message_queue[++C.chatOutput.message_queue.len] = list("time" = time, "message" = message)
				return

		var/list/tojson = list("time" = time, "message" = message);
		target << output(jsEncode(tojson), "htmloutput:putmessage")

#undef MAX_COOKIE_LENGTH