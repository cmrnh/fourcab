package com.fourcab;

import java.io.BufferedReader;
import java.io.InputStreamReader;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONObject;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

public class FourSquareApi {

	public static final String API = "https://api.foursquare.com/v2/";

	private static final String TAG = FourSquareApi.class.getSimpleName();

	private String mAuthToken;

	public FourSquareApi(Context context) {
    	SharedPreferences prefs = context.getSharedPreferences(Constants.FOURCAB_PREFS, 0);
    	String token = prefs.getString(Constants.FOURSQUARE_TOKEN_KEY, null);
		this.mAuthToken = token;
	}

	private JSONObject executeHttpGet(String uri) {
		Log.v("jason", "executeHttpGet: " + uri);
		HttpGet req = new HttpGet(uri);

		HttpClient client = new DefaultHttpClient();
		try {
			HttpResponse resLogin = client.execute(req);
			BufferedReader r = new BufferedReader(new InputStreamReader(resLogin
					.getEntity().getContent()));
			StringBuilder sb = new StringBuilder();
			String s = null;
			while ((s = r.readLine()) != null) {
				sb.append(s);
			}

			JSONObject obj = new JSONObject(sb.toString());

			int returnCode = Integer.parseInt(obj
					.getJSONObject("meta").getString("code"));
			if (returnCode == 200) {
				return obj.getJSONObject("response");
			} else {
				Log.e(TAG, "Response Error:");
				Log.e(TAG, "    Code: " + returnCode);
				Log.e(TAG, "    Type: " + obj.getJSONObject("meta").getString("errorType"));
				Log.e(TAG, "  Reason: " + obj.getJSONObject("meta").getString("errorDetail"));
				return null;
			}
		} catch(Exception e) {
			throw new RuntimeException(e);
		}
	}

	public JSONObject getUserInfo() {
		JSONObject userJson = executeHttpGet(API+ "users/self?oauth_token=" + mAuthToken);
		if (userJson == null) return null;
		return userJson;
	}

//	public JSONArray getCheckins(String userId) {
//		JSONObject venuesJson = executeHttpGet(API + userId + "/checkins");
//		
//		return venuesJson;
//	}
}
