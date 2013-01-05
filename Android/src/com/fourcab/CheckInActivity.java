package com.fourcab;

import java.util.ArrayList;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.IntentFilter.AuthorityEntry;
import android.content.SharedPreferences.Editor;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;

public class CheckInActivity extends Activity {

	protected static final String TAG = CheckInActivity.class.getSimpleName();
	
	GoogleMap mMap;
	MyLocationHandler mMyLocationHandler;

	static class MyLocationHandler extends Handler {
		private GoogleMap mMap;

		public MyLocationHandler(GoogleMap map) {
			super();
			mMap = map;
		}

		@Override
		public void handleMessage(Message msg) {
			switch(msg.what) {
			case 0:
				Location loc = mMap.getMyLocation();
				if (loc == null) {
					sendMessageDelayed(obtainMessage(0), 200);
				} else {
					zoomToLocation(mMap, loc);
				}
			}
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_check_in);
		mMap = ((MapFragment) getFragmentManager().findFragmentById(R.id.map)).getMap();
		mMyLocationHandler = new MyLocationHandler(mMap);

		if (mMap != null) {
			mMap.setMyLocationEnabled(true);
			mMyLocationHandler.sendMessage(mMyLocationHandler.obtainMessage(0));
		}
		
		getCheckins();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.activity_check_in, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch(item.getItemId()) {
		case R.id.clear_prefs:
			SharedPreferences prefs = getSharedPreferences(Constants.FOURCAB_PREFS, 0);
			Editor editor = prefs.edit();
			editor.clear();
			editor.commit();
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	private static void zoomToLocation(GoogleMap map, Location location) {
		LatLng latlng = new LatLng(location.getLatitude(), location.getLongitude());
		CameraPosition cameraPosition = new CameraPosition.Builder()
		.target(latlng)
		.zoom(13)
		.build();
		map.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
	}
	
	public void getCheckins() {
		new Thread() {
			@Override
			public void run() {
				FourSquareApi api = new FourSquareApi(CheckInActivity.this);
				Log.v("jason", "api returned: " + api.getUserInfo());
			}
		}.start();
	}
}
