package com.fourcab;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;

public class SignInActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_in);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.activity_sign_in, menu);
        return true;
    }
    
    public void signIn(final View view) {
        // Do foursquare sign in here
        Intent intent = new Intent(this, CheckInActivity.class);
        startActivity(intent);
    }

}
