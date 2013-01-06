package com.fourcab;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

public class SignUpActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_in);
    }
    
    @Override
    protected void onResume() {
    	super.onResume();
    	SharedPreferences prefs = getSharedPreferences(Constants.FOURCAB_PREFS, 0);
    	String token = prefs.getString(Constants.FOURSQUARE_TOKEN_KEY, null);
    	
    	// if we have a token, just kill this activity
    	if (token != null) {
    		Log.v("jason", "token=" + token);
            Intent intent = new Intent(this, CheckInActivity.class);
            startActivity(intent);
            finish();
    	}
    }
    
    public void signIn(final View view) {
        Intent intent = new Intent(this, FoursquareLogInActivity.class);
        startActivity(intent);
    }
}
