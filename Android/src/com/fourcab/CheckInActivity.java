package com.fourcab;

import java.lang.ref.WeakReference;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.AsyncTaskLoader;
import android.support.v4.content.Loader;
import android.util.Log;

import com.actionbarsherlock.app.SherlockFragmentActivity;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMap.OnInfoWindowClickListener;
import com.google.android.gms.maps.GoogleMap.OnMapClickListener;
import com.google.android.gms.maps.GoogleMap.OnMapLongClickListener;
import com.google.android.gms.maps.GoogleMap.OnMarkerClickListener;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

public class CheckInActivity extends SherlockFragmentActivity implements LoaderCallbacks<JSONObject>, OnMarkerClickListener, OnInfoWindowClickListener, OnMapClickListener, OnMapLongClickListener {

	protected static final String TAG = CheckInActivity.class.getSimpleName();

	private static final String CONFIRM = "Confirm Destination?";

	private static final String PICKUP = "Pick up at:";
	
	GoogleMap mMap;
	MyLocationHandler mMyLocationHandler;
	Marker mDestination;

	static class MyLocationHandler extends Handler {
		private GoogleMap mMap;
		private WeakReference<Context> mRef;

		public MyLocationHandler(Context context, GoogleMap map) {
			super();
			mMap = map;
			mRef = new WeakReference<Context>(context);
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
					Context context = mRef.get();
					if (context != null)
						saveLocation(context, loc);
				}
			}
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_check_in);
		mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map)).getMap();
		mMyLocationHandler = new MyLocationHandler(this, mMap);

		if (mMap != null) {
	    	SharedPreferences prefs = getSharedPreferences(Constants.FOURCAB_PREFS, 0);
	    	double lat = Double.parseDouble(prefs.getString(Constants.LATITUDE, "0"));
	    	double lng = Double.parseDouble(prefs.getString(Constants.LONGITUDE, "0"));
	    	LatLng latLng = new LatLng(lat,  lng);

			mMap.setMyLocationEnabled(true);
			mMyLocationHandler.sendMessage(mMyLocationHandler.obtainMessage(0));
			mMap.setOnMarkerClickListener(this);
			mMap.setOnInfoWindowClickListener(this);
			mMap.setOnMapClickListener(this);
			mMap.setOnMapLongClickListener(this);
			mMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));
			
		}

		getSupportLoaderManager().initLoader(0, null, this);
	}
	
	@Override
	public boolean onCreateOptionsMenu(com.actionbarsherlock.view.Menu menu) {
		getSupportMenuInflater().inflate(R.menu.activity_check_in, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(
			com.actionbarsherlock.view.MenuItem item) {
		switch(item.getItemId()) {
		case R.id.clear_prefs:
			SharedPreferences prefs = getSharedPreferences(Constants.FOURCAB_PREFS, 0);
			Editor editor = prefs.edit();
			editor.clear();
			editor.commit();
			
			Intent intent = new Intent(this, SignUpActivity.class);
			startActivity(intent);
			finish();
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
	
	private static void saveLocation(Context context, Location location) {
        SharedPreferences settings = context.getSharedPreferences(Constants.FOURCAB_PREFS, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString(Constants.LATITUDE, Double.toString(location.getLatitude()));
        editor.putString(Constants.LONGITUDE, Double.toString(location.getLongitude()));
        editor.commit();
	}
	
	private Marker placeMarker(double latitude, double longitude, String title, String snippet) {
		LatLng latLng = new LatLng(latitude, longitude);
		MarkerOptions options = new MarkerOptions();
		options.position(latLng);
		options.title(title);
		options.snippet(snippet);
		return mMap.addMarker(options);
	}
	
	@Override
	public Loader<JSONObject> onCreateLoader(int id, Bundle args) {
		Log.v("jason", "onCreateLoader");
		return new UserInfoTask(this);
	}

	@Override
	public void onLoadFinished(Loader<JSONObject> loader, JSONObject jsonObj) {
		Marker marker = null;
		if (jsonObj != null) {
			try {
//				Log.v("jason", "onLoadFinished: " + jsonObj.toString(2));

				JSONObject checkin = (JSONObject) jsonObj.getJSONObject("checkins").getJSONArray("items").get(0);
				JSONObject venue = checkin.getJSONObject("venue");
				JSONObject location = venue.getJSONObject("location");
				double lat = location.getDouble("lat");
				double lng = location.getDouble("lng");
				marker = placeMarker(lat, lng, PICKUP, venue.getString("name"));
				marker.showInfoWindow();
			} catch (JSONException e) {
				Log.e("jason", "JSONException: ", e);
			}
		}
		
		// If fail to get last checkin, use current location
		if (marker == null) {
			double lat = mMap.getMyLocation().getLatitude();
			double lng = mMap.getMyLocation().getLongitude();
			marker = placeMarker(lat, lng, PICKUP, getResources().getString(R.string.current_location));
			marker.showInfoWindow();
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

	@Override
	public void onInfoWindowClick(Marker marker) {
		Log.v("jason", "onInfoWindowClick: " + marker.getTitle());
		if (CONFIRM.equals(marker.getTitle())) {
			Intent intent = new Intent(this, PeopleActivity.class);
			LatLng latLng = marker.getPosition();
			intent.putExtra(Constants.LATITUDE, latLng.latitude);
			intent.putExtra(Constants.LONGITUDE, latLng.longitude);
			
			Location location = mMap.getMyLocation();
			intent.putExtra(Constants.MY_LATITUDE, location.getLatitude());
			intent.putExtra(Constants.MY_LONGITUDE, location.getLongitude());
			
			startActivity(intent);
		}
	}

	@Override
	public void onMapClick(LatLng point) {
		setDestination(point);
	}

	@Override
	public void onMapLongClick(LatLng point) {
		setDestination(point);
	}
	
	private void setDestination(LatLng point) {
		if (mDestination != null) {
			mDestination.remove();
			mDestination = null;
		}
		mDestination = placeMarker(point.latitude, point.longitude, CONFIRM, null);
		mDestination.showInfoWindow();
	}
}
