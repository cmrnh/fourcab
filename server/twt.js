
// twilio test
var CONFIG = {
	TWILIO_ACCOUNT_SID: "AC57cc1066203ab42b113c5e5152f5c8a9",
	TWILIO_AUTH_TOKEN: "ef4be32135d057ca0ccaef150c063eef",
	TWILIO_APP_SID: "AP6f44db7a601f4411aeadfeebf9742748",
	OUR_PHONE_NUMBER: "3473218386",

};

var twilioAPI = require('twilio-api'),
	cli = new twilioAPI.Client(CONFIG.TWILIO_ACCOUNT_SID, CONFIG.TWILIO_AUTH_TOKEN);

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

cli.account.getApplication(CONFIG.TWILIO_APP_SID, function(err, twilio) {
	if(err) throw err;
	g_twilio = twilio;

	sendSMS("4154308612", "TEST SMS SENT FROM NODE.JS #3");
});


