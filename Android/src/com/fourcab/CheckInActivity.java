package com.fourcab;

import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.LoaderManager.LoaderCallbacks;
import android.content.AsyncTaskLoader;
import android.content.Context;
import android.content.Loader;
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
import com.google.android.gms.maps.GoogleMap.OnMarkerClickListener;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

public class CheckInActivity extends Activity implements LoaderCallbacks<JSONObject>, OnMarkerClickListener {

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
			mMap.setOnMarkerClickListener(this);
		}

		getLoaderManager().initLoader(0, null, this);
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
	
	private void placeMarker(double latitude, double longitude, String title) {
		LatLng latLng = new LatLng(latitude, longitude);
		MarkerOptions options = new MarkerOptions();
		options.position(latLng);
		options.title(title);
		mMap.addMarker(options);
	}
	
	@Override
	public Loader<JSONObject> onCreateLoader(int id, Bundle args) {
		Log.v("jason", "onCreateLoader");
		return new UserInfoTask(this);
	}

	@Override
	public void onLoadFinished(Loader<JSONObject> loader, JSONObject jsonObj) {
		try {
			Log.v("jason", "onLoadFinished: " + jsonObj.toString(2));

			JSONObject checkin = (JSONObject) jsonObj.getJSONObject("checkins").getJSONArray("items").get(0);
			JSONObject venue = checkin.getJSONObject("venue");
			JSONObject location = venue.getJSONObject("location");
			double lat = location.getDouble("lat");
			double lng = location.getDouble("lng");
			placeMarker(lat, lng, venue.getString("name"));
		} catch (JSONException e) {
			Log.e("jason", "JSONException: ", e);
		}
	}

	@Override
	public void onLoaderReset(Loader<JSONObject> arg0) {
	}
	
	private static class UserInfoTask extends AsyncTaskLoader<JSONObject> {

		public UserInfoTask(Context context) {
			super(context);
		}
		
		@Override
		protected void onStartLoading() {
			forceLoad();
		}

		@Override
		public JSONObject loadInBackground() {
			Log.v("jason", "loadInBackground");
			FourSquareApi api = new FourSquareApi(getContext());
			JSONObject obj = null;
			try {
				obj = api.getUserInfo();
			} catch(Exception e) {
				Log.e("jason", "Exception: ", e);
			}
			return obj;
		}
	}

	@Override
	public boolean onMarkerClick(Marker marker) {
		Log.v("jason", "onMarkerClick");
		marker.showInfoWindow();
		return true;
	}

}
