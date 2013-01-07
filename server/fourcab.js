
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

	sms_considered_current: 30 * 60 * 1000, // half an hour

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

function UserDbItem() {}
UserDbItem.prototype.pickup = null; // MUST BE FIXED UP
UserDbItem.prototype.dropoff = null;
UserDbItem.prototype.recentPoll = null;
UserDbItem.prototype.phoneNumber = null;
UserDbItem.prototype.smsLastSent = null;
UserDbItem.prototype.blockSMSUntil = null;


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

	// Construct array of [userId, distance between sources, distance between destinations, outstanding SMS]
	// for all other users who want a ride. Distance between destinations === false for people
	// who are aren't looking for a ride RIGHT NOW.
	var candidates = [];
	Object.getOwnPropertyNames(g_userdb).forEach(function(otherUserId) {
		var otherDbEntry = g_userdb[otherUserId];

		if(userId != otherUserId) {

			// XXX implement 3 minute timeout
			// && now - otherDbEntry.recentPoll >= CONFIG.polling_timeout) {

			var dropoffDistance = (otherDbEntry.dropoff && otherDbEntry.recentPoll)
				? calcDistance(dbEntry.dropoff, otherDbEntry.dropoff)
				: false;

			candidates.push([
				otherUserId,
				calcDistance(dbEntry.pickup, otherDbEntry.pickup),
				dropoffDistance,
				otherDbEntry.smsLastSent >= now - (CONFIG.sms_considered_current)
				]);
		}
	});

	// exclude everything too far away. then sort by the distance between pickup points
	// we count, but don't actually include, the registered-but-not-looking
	var registeredButNotLooking = 0;
	candidates = candidates.filter(function(x) {
		if(!x[2] && x[3]) {
			++registeredButNotLooking;
			return false;
		}

		return x[1] <= CONFIG.max_pickup_distance_miles
			&& x[2] <= CONFIG.max_dropoff_distance_miles;
	});

	candidates = candidates.sort(function(a,b) { return a[1] - b[1]; });

	// flesh out the data and return as json
	var data = { possibleCount: registeredButNotLooking, waitingCount: 0 };

	if(candidates.length) {
		data = {
			possibleCount: registeredButNotLooking,
			waitingCount: candidates.length,
			waiting: candidates.map(function(x) {
				return fsq.userProfileFromIdSync(x[0]);
			})
		};
	}

	res.json(data);
}


function queueEligibleSmses() {
	var now = Date.now();
	var allUserIds = Object.getOwnPropertyNames(g_userdb);

	allUserIds.forEach(function(userId) {
		var entry = g_userdb[userId];

		if(entry.recentPoll
		|| !entry.phoneNumber
		|| entry.smsLastSent >= now - CONFIG.sms_considered_current
		|| entry.blockSMSUntil && now < entry.blockSMSUntil )
		{
			return;
		}

		var shouldSms = false;
		allUserIds.forEach(function(otherUserId) {
			if(userId == otherUserId)
				return;

			var otherEntry = g_userdb[otherUserId];
			if(otherEntry.recentPoll && calcDistance(entry.pickup, otherEntry.pickup) < CONFIG.max_pickup_distance_miles)
				shouldSms = true;
		});

		if(shouldSms) {
			entry.smsLastSent = now;
			entry.blockSMSUntil = now + CONFIG.sms_considered_current;
			sendSMS(entry.phoneNumber,
				"Someone is using FourCab nearby right now! Open up FourCab to share a ride with them.");
		}
	});
}


//
// WEB SERVER
//

var app = express();
app.use(express.bodyParser());


app.post('/api/checkin/', function(req,res) {
	// XXX validate the data!

	console.log(req.body);
	fsq.fetchUserWithOauth(req.body.foursquareOauthToken, function(err,userId) {
		if(err) throw err;

		if(!g_userdb[userId]) g_userdb[userId] = new UserDbItem();

		g_userdb[userId].pickup = req.body.pickup;
		g_userdb[userId].dropoff = req.body.dropoff;
		g_userdb[userId].recentPoll = Date.now();

		// do this first so sendRides has an accurate "smsed users" count
		queueEligibleSmses();

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
	// XXX check the secret is what it should be
	console.log('');

	var checkin = JSON.parse(req.body.checkin);

	// Does the person have a phone number, and are they checking in somewhere
	// with a location we can use?
	var usefulForSms = !!(
		checkin.user
		&& checkin.user.id
		&& checkin.user.contact
		&& checkin.user.contact.phone && checkin.user.contact.phone.length
		&& checkin.venue
		&& checkin.venue.name && checkin.venue.name.length
		&& checkin.venue.location
		&& checkin.venue.location.lat
		&& checkin.venue.location.lng);

	console.log('POST TO /4push/');
	console.log('', checkin);
	console.log('useful for SMS?', usefulForSms);

	// XXX if they've moved too far from where the last sms was sent.. we want to reset
	// their state. but not otherwise! and blocking more SMSes... argh my head hurts
	if(g_userdb[checkin.user.id])
		g_userdb[checkin.user.id].smsLastSent = null;

	if(usefulForSms) {
		if(!g_userdb[checkin.user.id]) g_userdb[checkin.user.id] = new UserDbItem();
		var dbEntry = g_userdb[checkin.user.id];

		// XXX do something like this if(!dbEntry.recentPoll) {
		dbEntry.pickup = {
			lat: checkin.venue.location.lat,
			lng: checkin.venue.location.lng,
			foursquare_venue_id: checkin.venue.id,
			name: checkin.venue.name,
			street_address: checkin.venue.location.address || null
		};
		//XXX//dbEntry.dropoff = null;
		//XXX//dbEntry.recentPoll = null;
		dbEntry.blockSMSUntil = null; // checkin resets this!
		dbEntry.phoneNumber = checkin.user.contact.phone;

		queueEligibleSmses();
	}
		
});


app.use('/public', express.static(__dirname + '/public'));
app.get('/', express.static(__dirname + '/index.html'));



// Set up web server and twilio

var twilio_cli = new twilioAPI.Client(CONFIG.TWILIO_ACCOUNT_SID, CONFIG.TWILIO_AUTH_TOKEN);
twilio_cli.account.getApplication(CONFIG.TWILIO_APP_SID, function(err, twilio) {
	if(err) throw err;
	g_twilio = twilio;

	app.listen(CONFIG.port);

//	sendSMS(CONFIG.MONITOR_PHONE_NUMBER, "fourcab.js has been started");
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

