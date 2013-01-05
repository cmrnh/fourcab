
var http = require('http'),
	fsq = require('./libs/fsq.js'),
	express = require('express');


// CONFIGURATION
var CONFIG = {
	port: 80,
	max_pickup_distance_miles: 0.05,  // about one block
	max_dropoff_distance_miles: 1.0
};



// GLOBAL STATE
g_userdb = {};

// WEB SERVER
var app = express();

// a.lat, a.long, b.lat, b.long are used. Result in miles.
function calcDistance(a,b) {
	return 1.0; // XXX
}


function sendRides(res, userId) {
	var dbEntry = g_userdb[userId];

	// Construct array of [userId, distance between sources, distance between destinations]
	// for all other users who want a ride
	var candidates = [];
	Object.getOwnPropertyNames(g_userdb).forEach(function(otherUserId) {
		var otherDbEntry = g_userdb[userId];

		if(userId != otherUserId && otherDbEntry.recentPoll) {
			candidates.push([
				otherUserId,
				calcDistance(dbEntry.pickup, otherDbEntry.pickup),
				calcDistance(dbEntry.dropoff, otherDbEntry.dropoff)
				]);
		}
	});

	// exclude everything too far away. then sort by the distance between pickup points
	candidates = candidates.filter(x, function(x) {
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


app.post('/api/checkin/', function(req,res) {
	fsq.fetchUserWithOauth(req.body.foursquareOauthToken, function(err,userId) {
		if(err) throw err;
		
		g_userdb[userId] = {
			pickup: req.body.pickup,
			dropoff: req.body.pickup,
			recentPoll: Date.now()
		};

		sendRides(res, userId);
	});
});

app.post('/api/cancel/', function(req,res) {
	var userId = fsq.userProfileFromOauthSync(req.body.foursquareOauthToken);
	var dbEntry = g_userdb[userId];
	if(!g_userdb[userId].recentPoll)
		throw "Cancelling non-existent booking";
	g_userdb[userId].recentPoll = null;
	res.send(200, '200 OK');
	res.end();
});

app.post('/api/rides/', function(req,res) {
	var userId = fsq.userProfileFromOauthSync(req.body.foursquareOauthToken);
	var dbEntry = g_userdb[userId];
	if(!g_userdb[userId].recentPoll)
		throw "Polling non-existent booking";
	
	// update last poll timestamp
	dbEntry.recentPoll = Date.now();

	sendRides(res, userId);
});

app.listen(CONFIG.port);

// Random testing stuff
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







