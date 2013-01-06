
var http = require('http'),
	fsq = require('./libs/fsq.js'),
	express = require('express'),
	twilioAPI = require('twilio-api');


// CONFIGURATION
var CONFIG = {
	port: 7100,
	//max_pickup_distance_miles: 0.05,  // about one block
	max_pickup_distance_miles: 0.15,  // about three blocks - being cautious for demo purposes
	max_dropoff_distance_miles: 1.0,
	polling_timeout: 3 * 60 * 1000,   // three minutes

	TWILIO_ACCOUNT_SID: "AC57cc1066203ab42b113c5e5152f5c8a9",
	TWILIO_AUTH_TOKEN: "ef4be32135d057ca0ccaef150c063eef",
	TWILIO_APP_SID: "AP6f44db7a601f4411aeadfeebf9742748",
	OUR_PHONE_NUMBER: "3473218386",

	MONITOR_PHONE_NUMBER: "4154308612"  // This is Andrew!
};


// SMS code
var g_twilio = null;

function sendSMS(toNumber, smsContent) {

	g_twilio.sendSMS(
		CONFIG.OUR_PHONE_NUMBER,
		toNumber,
		smsContent,
		function(err, smsObj) {
			if(err) {
				console.log("ERROR queueing SMS to " + toNumber, err);
			} else {
				console.log("Queued SMS to " + toNumber);
				smsObj.once('sendStatus', function(success, st) {
					if(success)
						console.log('Sent SMS to ' + toNumber);
					else
						console.log('ERROR sending SMS to ' + toNumber);
				});
			}
		});

}

// GLOBAL STATE
g_userdb = {};


// State processing

// a.lat, a.long, b.lat, b.long are used. Result in miles.
function calcDistance(a,b) {
	// Haversine formula
	var R = 3963.1696; // miles
	var dLat = (b.lat-a.lat) * Math.PI / 180.0;
	var dLon = (b.lng-a.lng) * Math.PI / 180.0;
	var lat1 = a.lat * Math.PI / 180.0;
	var lat2 = b.lat * Math.PI / 180.0;

	var x = Math.sin(dLat/2) * Math.sin(dLat/2) +
	        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
	var c = 2 * Math.atan2(Math.sqrt(x), Math.sqrt(1-x)); 
	var d = R * c;

	console.log("", d, " miles between (", a.lat, ",", a.lng, ") and (", b.lat, ",", b.lng, ")");
	return d;
}


function sendRides(res, userId) {
	var dbEntry = g_userdb[userId];
	var now = Date.now();

	// Construct array of [userId, distance between sources, distance between destinations]
	// for all other users who want a ride. Time people out after 3 minutes without
	var candidates = [];
	Object.getOwnPropertyNames(g_userdb).forEach(function(otherUserId) {
		var otherDbEntry = g_userdb[otherUserId];

		if(userId != otherUserId
		&& otherDbEntry.recentPoll) {
//		&& now - otherDbEntry.recentPoll >= CONFIG.polling_timeout) {
			candidates.push([
				otherUserId,
				calcDistance(dbEntry.pickup, otherDbEntry.pickup),
				calcDistance(dbEntry.dropoff, otherDbEntry.dropoff)
				]);
		}
	});

	// exclude everything too far away. then sort by the distance between pickup points
	candidates = candidates.filter(function(x) {
		return x[1] <= CONFIG.max_pickup_distance_miles
			&& x[2] <= CONFIG.max_dropoff_distance_miles;
	});

	candidates = candidates.sort(function(a,b) { return a[1] - b[1]; });

	// flesh out the data and return as json
	var data = { possibleCount: 0, waitingCount: 0 };

	if(candidates.length) {
		data = {
			possibleCount: 0,
			waitingCount: candidates.length,
			waiting: candidates.map(function(x) {
				return fsq.userProfileFromIdSync(x[0]);
			})
		};
	}

	res.json(data);
}

//
// WEB SERVER
//

var app = express();
app.use(express.bodyParser());


app.post('/api/checkin/', function(req,res) {
	console.log(req.body);
	fsq.fetchUserWithOauth(req.body.foursquareOauthToken, function(err,userId) {
		if(err) throw err;

		if(!g_userdb[userId]) g_userdb[userId] = {};

		g_userdb[userId].pickup = req.body.pickup;
		g_userdb[userId].dropoff = req.body.dropoff;
		g_userdb[userId].recentPoll = Date.now();

		sendRides(res, userId);
		console.log('AFTER /api/checkin/ CALL:', g_userdb);
	});
});

app.post('/api/cancelall/', function(req,res) {
	g_userdb = {};
	res.send(200, '200 OK');
	res.end();
	console.log('AFTER /api/cancelall/ CALL:', g_userdb);
});
	
app.post('/api/cancel/', function(req,res) {
	var userId = fsq.userProfileFromOauthSync(req.body.foursquareOauthToken).userId;
	var dbEntry = g_userdb[userId];
	if(!g_userdb[userId].recentPoll)
		throw "Cancelling non-existent booking";
	g_userdb[userId].recentPoll = null;
	res.send(200, '200 OK');
	res.end();
	console.log('AFTER /api/cancel/ CALL:', g_userdb);
});

app.post('/api/rides/', function(req,res) {
	var userId = fsq.userProfileFromOauthSync(req.body.foursquareOauthToken).userId;
	var dbEntry = g_userdb[userId];
	if(!dbEntry.recentPoll)
		throw "Polling non-existent booking";
	
	// update last poll timestamp
	dbEntry.recentPoll = Date.now();

	sendRides(res, userId);
	console.log('AFTER /api/rides/ CALL:', g_userdb);
});

app.post('/4push/', function(req,res) {
	console.log('');
	console.log('POST TO /4push/');
	console.log('', req.body);
	console.log('');
});


app.use('/public', express.static(__dirname + '/public'));
app.get('/', express.static(__dirname + '/index.html'));



// Set up web server and twilio

var twilio_cli = new twilioAPI.Client(CONFIG.TWILIO_ACCOUNT_SID, CONFIG.TWILIO_AUTH_TOKEN);
twilio_cli.account.getApplication(CONFIG.TWILIO_APP_SID, function(err, twilio) {
	if(err) throw err;
	g_twilio = twilio;

	app.listen(CONFIG.port);

	sendSMS(MONITOR_PHONE_NUMBER, "fourcab.js has been started");
});


// Random testing stuff
if(0) {
	console.log("FAKE PROFILE:", fsq.userProfileFromIdSync("testid4"));

	fsq.fetchUserWithOauth("VCJX20UMEDND5UU3R2YZFDMUSZ1BNMGWQJJI0JURJAGCBDFF", function(err,res) {
		console.log("REAL ERR:", err);
		console.log("REAL RES:", res);
		console.log("REAL PROFILE:", fsq.userProfileFromIdSync("45028491"));
	});

	fsq.fetchUserWithOauth("testtoken3", function(err,res) {
		console.log("FAKE ERR:", err);
		console.log("FAKE RES:", res);
	});
}

