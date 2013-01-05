
// foursquare RPC with some slight wrapping for caching
// and our tests

var foursquare_config = {
	secrets: {
		clientId: "JYZJC2LLZQNFA2T0VJ5ALNBUH1EVZY3F5PRUFCM3REZFOBWO",
		clientSecret: "D5FVLI1E2WKIFNJMXI5Z4XPBOGEXB5I3UQGWCZXMFW13S1RP",
		redirectUrl: "http://localhost/" // XXX?
	}
};

var foursquare = require('node-foursquare')(foursquare_config),
	async = require('async');


var oauth_to_userid_cache = {};

var user_profiles = {};

function insertUserDataIntoCache(oauthToken, response) {
	var lastInitial = (response.user['lastName'] && response.user.lastName.length)
		? " " + response.user.lastName[0] + "."
		: "";

	oauth_to_userid_cache[oauthToken] = response.user.id;

	user_profiles[response.user.id] = {
		userId: response.user.id,
		name: response.user.firstName + lastInitial,
		photo_prefix: response.user.photo.prefix,
		photo_suffix: response.user.photo.suffix
	};
}


// offline test stubs
(function() {
	for(var i = 1; i < 10; ++i) {
		insertUserDataIntoCache("testtoken" + i,
			{ user: {
				"id": "testid" + i,
				"firstName" : "Testuser" + i,
				"lastName": "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[i-1],
				"photo": { prefix: "http://example.com/", suffix: "/NoPic.jpg" }
			} });
	}
})();
			
// Pass in a standard callback(err, result). Result will
// be the actual foursquare user id corresponding to the
// oauth token. You must call this first for a particular
// user to be able to call userProfileSync
exports.fetchUserWithOauth = function(oauthToken, callback) {
	async.series([
		function(cb) {
			if(oauth_to_userid_cache[oauthToken]) cb(null,null);
			else {
				foursquare.Users.getUser("self", oauthToken, function(err,res) {
					if(!err)
						insertUserDataIntoCache(oauthToken, res);
					cb(err,null);
				});
			}
		}],

		function(err,junk) {
			callback(err, err ? null : oauth_to_userid_cache[oauthToken]);
		});
};


exports.userProfileFromIdSync = function(userId) {
	var result = user_profiles[userId];
	if(!result)
		throw "Could not locate user " + userId + " in cache.";
	return result;
};



exports.userProfileFromOauthSync = function(oauthToken) {
	var result = user_profiles[oauth_to_userid_cache[oauthToken]];
	if(!result)
		throw "Could not locate oauth token " + oauthToken + " in cache.";
	return result;
}

	
