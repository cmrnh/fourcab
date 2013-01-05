package com.fourcab;

import android.app.Activity;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Menu;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;

public class CheckInActivity extends Activity {

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
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_check_in, menu);
        return true;
    }

    private static void zoomToLocation(GoogleMap map, Location location) {
    	LatLng latlng = new LatLng(location.getLatitude(), location.getLongitude());
        CameraPosition cameraPosition = new CameraPosition.Builder()
        .target(latlng)
        .zoom(12)
        .build();
        map.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
    }
}
