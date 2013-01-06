
var http = require('http'),
	request = require('request'),
	assert = require('assert'),
	async = require('async');

// skip tests!
var populate_only = true;

var places = {
	FOURSQUARE_HQ: {
		lat: 40.724169079279605,
		lng: -73.99721145629883,
		foursquare_venue_id: "50e83dc1e4b0c990e7bb15c3",
		name: "Foursquare HQ",
		street_address: "568 Broadway (10th Floor)"
	},

	// one street down from foursquare HQ
	BACK_FORTY_WEST: {
		lat: 40.72377066168169,
		lng: -73.9969003200531,
		foursquare_venue_id: "4f3beff67beb94fcfc7b776a",
		name: "Back Forty West",
		street_address: "70 Prince St"
	},

	// ages away from foursquare
	DING_DONG_LOUNGE: {
		lat: 40.798840875789125,
		lng: -73.96306123830033,
		foursquare_venue_id: "3fd66200f964a52060e81ee3",
		name: "Ding Dong Lounge",
		street_address: "929 Columbus Ave."
	},


	// NY Moore Hostel and Loft Hostel are very close. HI Hostel isn't
	// anywhere near either (and we don't include the foursquare id)
	NY_MOORE_HOSTEL: {
		lat: 40.70429793023355,
		lng: -73.9377817666923,
		foursquare_venue_id: "4ebf61426da15b4ddeda510c",
		name: "Ny Moore Hostel",
		street_address: "179 Moore St"
	},

	LOFT_HOSTEL: {
		lat: 40.70430229121919,
		lng: -73.93395856182873,
		foursquare_venue_id: "4b50c722f964a5200d3227e3",
		name: "New York Loft Hostel",
		street_address: "249 Varet St."
	},

	HI_HOSTEL: {
		lat: 40.79870525978015,
		lng: -73.96682647133838,
		foursquare_venue_id: null, //"4ad504e7f964a5204f0121e3"
		name: "HI Hostel", //"HI New York Hostel"
		street_address: "891 Amsterdam Ave."
	}
};


// last JSON returned when hit() / hitDirect() was used
var last = null;

function hitDirect(url, jsonToPost, callback) {
	last = null;

	console.log("POST TO " + url + ":", jsonToPost);
	request(
		{
			url: "http://localhost" + url,
			method: 'POST',
			json: jsonToPost
		},
		function(err,response,body) {
			if(!err && (response.code < 200 || response.code >= 300))
				err = "response.code isn't 2xx";

			if(err) {
				console.log("SERVER ERROR:", err);
				console.log("SERVER ERROR BODY", body);
				callback(err,null);
			} else {
				console.log("SERVER OK BODY: ", body);
				console.log("");
				last = body;
				callback(null, body);
			}
		}
	);
}
				
function hit(url, jsonToPost) {
	return function(cb) { hitDirect(url, jsonToPost, cb); };
}

var SKIP_WHEN_POPULATING = populate_only
	? (function(cb) { cb(null,null); })
	: null;

async.series([
	// reset all state
	SKIP_WHEN_POPULATING || hit("/api/cancelall/", {}),

	// three users start the app..
	hit("/api/checkin/", {
		foursquareOauthToken: "testtoken1",
		pickup: places.FOURSQUARE_HQ,
		dropoff: places.NY_MOORE_HOSTEL
	}),

	hit("/api/checkin/", {
		foursquareOauthToken: "testtoken2",
		pickup: places.FOURSQUARE_HQ,
		dropoff: places.HI_HOSTEL
	}),

	hit("/api/checkin/", {
		foursquareOauthToken: "testtoken3",
		pickup: places.FOURSQUARE_HQ,
		dropoff: places.LOFT_HOSTEL
	}),

	SKIP_WHEN_POPULATING || function(cb) {
		// testuser3 should see testuser1; they are both going from
		// foursquare to places within a couple of blocks of each other
		assert.ok(last.waitingCount == 1 && last.waiting[0].userId == "testid1");
		cb();
	},

	// make sure testuser1 sees testuser3 as well
	hit("/api/rides/", { foursquareOauthToken: "testtoken1" }),

	SKIP_WHEN_POPULATING || function(cb) {
		assert.equal(last.waitingCount, 1);
		assert.equal(last.waiting[0].userId, "testid3");
		cb();
	},

	// testuser2 shouldn't see anybody at all
	hit("/api/rides/", { foursquareOauthToken: "testtoken2" }),

	SKIP_WHEN_POPULATING || function(cb) {
		assert.ok(last.waitingCount == 0);
		cb();
	},

	// add an entry with testuser4 going from a restaurant near
	// foursquare HQ to HI Hostel. then he and testuser2 should see
	// each other
	hit("/api/checkin/", {
		foursquareOauthToken: "testtoken4",
		pickup: places.BACK_FORTY_WEST,
		dropoff: places.HI_HOSTEL
	}),
	
	SKIP_WHEN_POPULATING || function(cb) {
		assert.equal(last.waitingCount, 1);
		assert.equal(last.waiting[0].userId, "testid2");
		cb();
	},

	hit("/api/rides/", { foursquareOauthToken: "testtoken2" }),

	SKIP_WHEN_POPULATING || function(cb) {
		assert.equal(last.waitingCount, 1);
		assert.equal(last.waiting[0].userId, "testid4");
		cb();
	},

	// have testuser4 cancel. then testuser2 should see nothing again
	hit("/api/cancel/", { foursquareOauthToken: "testtoken4" }),
	hit("/api/rides/", { foursquareOauthToken: "testtoken2" }),

	SKIP_WHEN_POPULATING || function(cb) {
		assert.equal(last.waitingCount, 0);
		cb();
	},

	// have testuser2 go to moore hostel, then it and testusers 1 + 3 should
	// all be able to ride together. make sure this is symmetrical
	hit("/api/checkin/", {
		foursquareOauthToken: "testtoken2",
		pickup: places.FOURSQUARE_HQ,
		dropoff: places.NY_MOORE_HOSTEL
	}),

	SKIP_WHEN_POPULATING || function(cb) {
		assert.equal(last.waitingCount, 2);
		assert.ok(last.waiting[0].userId == "testid1" && last.waiting[1].userId == "testid3"
		      ||  last.waiting[0].userId == "testid3" && last.waiting[1].userId == "testid1");
		cb();
	},

	hit("/api/rides/", { foursquareOauthToken: "testtoken3" }),
	SKIP_WHEN_POPULATING || function(cb) {
		assert.equal(last.waitingCount, 2);
		assert.ok(last.waiting[0].userId == "testid1" && last.waiting[1].userId == "testid2"
		      ||  last.waiting[0].userId == "testid2" && last.waiting[1].userId == "testid1");
		cb();
	},

	// even when we're populating this should always hold true
	function(cb) {
		assert.ok(last.waitingCount >= 2);
		cb();
	},

]);


		
