/**
 * Copyright 2011 Mark Wyszomierski
 */
package com.fourcab;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * https://developer.foursquare.com/docs/oauth.html
 * https://foursquare.com/oauth/
 * 
 * @date May 17, 2011
 * @author Mark Wyszomierski (markww@gmail.com)
 */
public class FoursquareLogInActivity extends Activity 
{
    private static final String TAG = "ActivityWebView";
	
    /**
     * Get these values after registering your oauth app at: https://foursquare.com/oauth/
     */
    public static final String CALLBACK_URL = "http://fourcab.grumpypanda.net/4cb/";
    public static final String CLIENT_ID = "JYZJC2LLZQNFA2T0VJ5ALNBUH1EVZY3F5PRUFCM3REZFOBWO";
	
    @SuppressLint("SetJavaScriptEnabled")
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_webview);
        
        String url =
            "https://foursquare.com/oauth2/authenticate" + 
                "?client_id=" + CLIENT_ID + 
                "&response_type=token" + 
                "&redirect_uri=" + CALLBACK_URL;
        
        // If authentication works, we'll get redirected to a url with a pattern like:  
        //
        //    http://YOUR_REGISTERED_REDIRECT_URI/#access_token=ACCESS_TOKEN
        //
        // We can override onPageStarted() in the web client and grab the token out.
        final WebView webview = (WebView)findViewById(R.id.webview);
        webview.getSettings().setJavaScriptEnabled(true);
        webview.setWebViewClient(new WebViewClient() {
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                String fragment = "#access_token=";
                int start = url.indexOf(fragment);
                if (start > -1) {
                    // You can use the accessToken for api calls now.
                    String accessToken = url.substring(start + fragment.length(), url.length());
        			
//                    Log.v(TAG, "OAuth complete, token: [" + accessToken + "].");
//                    Toast.makeText(FoursquareLogInActivity.this, "Token: " + accessToken, Toast.LENGTH_SHORT).show();

                    SharedPreferences settings = getSharedPreferences(Constants.FOURCAB_PREFS, 0);
                    SharedPreferences.Editor editor = settings.edit();
                    editor.putString(Constants.FOURSQUARE_TOKEN_KEY, accessToken);
                    editor.commit();
                    finish();
                }
            }
        });
        webview.loadUrl(url);
    }
}