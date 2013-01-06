package com.fourcab;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.androidquery.AQuery;

import android.app.Activity;
import android.app.LoaderManager.LoaderCallbacks;
import android.content.AsyncTaskLoader;
import android.content.Context;
import android.content.Loader;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

public class PeopleActivity extends Activity implements LoaderCallbacks<JSONObject> {

	private static final String TAG = PeopleActivity.class.getSimpleName();
	public static final String IMAGE_SIZE = "512";
	
	GridView mGridView;
	PeopleAdapter mAdapter;
	ProgressBar mProgress;
	TextView mNoResultsView;
	double[] mCoords;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_people);
		// Show the Up button in the action bar.
		getActionBar().setDisplayHomeAsUpEnabled(true);
		
		Bundle extras = getIntent().getExtras();
		if (extras != null) {
			mCoords = new double[4];
			mCoords[0] = extras.getDouble(Constants.MY_LATITUDE);
			mCoords[1] = extras.getDouble(Constants.MY_LONGITUDE);
			mCoords[2] = extras.getDouble(Constants.LATITUDE);
			mCoords[3] = extras.getDouble(Constants.LONGITUDE);
		}
		
		mAdapter = new PeopleAdapter(this);
		
//		// Test data
		List<Person> people = new ArrayList<Person>();
//		String image = "https://irs2.4sqi.net/img/user/512x512/A0UXAHBVGNX0PZV3.jpg";
//		people.add(new Person("Jason", image));
//		people.add(new Person("Cameron", image));
//		people.add(new Person("Andrew", image));
//		people.add(new Person("Other", image));
//		mAdapter.setData(people);
		
		mGridView = (GridView) findViewById(R.id.grid);
		mGridView.setAdapter(mAdapter);
		mProgress = (ProgressBar) findViewById(R.id.progress);
		mNoResultsView = (TextView) findViewById(R.id.no_results_text);
		
		getLoaderManager().initLoader(0, null, this);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_people, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			NavUtils.navigateUpFromSameTask(this);
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	public static class Person {
		public String name;
		public String imageUrl;
		
		public Person(String name, String imageUrl) {
			this.name = name;
			this.imageUrl = imageUrl;
		}
	}
	
	public static class PeopleAdapter extends BaseAdapter {
		List<Person> mPeople = new ArrayList<Person>();
		LayoutInflater mInflater;
		Context mContext;
		AQuery mAquery;
		
		public class ViewHolder {
			public TextView tv;
			public ImageView iv;
			
			public void populate(Person people) {
				this.tv.setText(people.name);
			}
		}
		
		public PeopleAdapter(Context context) {
			mContext = context;
			mInflater = LayoutInflater.from(context);
			mAquery = new AQuery(context);
		}

		public void setData(List<Person> list) {
			mPeople = list;
			notifyDataSetChanged();
		}
		
		@Override
		public int getCount() {
			return mPeople.size();
		}

		@Override
		public Object getItem(int position) {
			return mPeople.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ViewHolder vh = null;
			if (convertView == null) {
				convertView = mInflater.inflate(R.layout.people_item, null);
				vh = new ViewHolder();
				vh.tv = (TextView) convertView.findViewById(R.id.name);
				vh.iv = (ImageView) convertView.findViewById(R.id.image);
				convertView.setTag(vh);
			}
			vh = (ViewHolder) convertView.getTag();
			Person person = (Person) getItem(position);
			vh.tv.setText(person.name);
			mAquery.id(vh.iv).image(person.imageUrl);
			
			return convertView;
		}
		
	}

	@Override
	public Loader<JSONObject> onCreateLoader(int id, Bundle args) {
		return new PeopleLoader(this, mCoords);
	}

	@Override
	public void onLoadFinished(Loader<JSONObject> loader, JSONObject obj) {
		if (obj != null) {
			int count = 0;
			try {
				count = obj.getInt("waitingCount");
			} catch (JSONException e) {
				Log.e(TAG, "JSONException: ", e);
				return;
			}
			if (count >= 1) {
				mProgress.setVisibility(View.INVISIBLE);
				mGridView.setVisibility(View.VISIBLE);
				
				try {
					List<Person> list = new ArrayList<PeopleActivity.Person>();
					JSONArray array = obj.getJSONArray("waiting");
					for (int i = 0; i<array.length(); i++) {
						JSONObject rider = (JSONObject) array.get(i);
						String photo = rider.getString("photo_prefix") + IMAGE_SIZE + "x" + IMAGE_SIZE + rider.getString("photo_suffix");
						Person p = new Person(rider.getString("name"), photo);
						list.add(p);
					}
					mAdapter.setData(list);
				} catch (JSONException e) {
					Log.e(TAG, "JSONException:", e);
				}
			} else {
				mProgress.setVisibility(View.INVISIBLE);
				mGridView.setVisibility(View.INVISIBLE);
				mNoResultsView.setVisibility(View.VISIBLE);
				mNoResultsView.setText(R.string.no_rides);
			}
		} else {
			mProgress.setVisibility(View.INVISIBLE);
			mGridView.setVisibility(View.INVISIBLE);
			mNoResultsView.setVisibility(View.VISIBLE);
			mNoResultsView.setText(R.string.no_api_result);
		}
	}

	@Override
	public void onLoaderReset(Loader<JSONObject> arg0) {
	}
	
	public static class PeopleLoader extends AsyncTaskLoader<JSONObject> {
		private static final int TRIES = 1;
		double[] locs;
		
		public PeopleLoader(Context context,double [] coords) {
			super(context);
			locs = coords;
		}

		@Override
		protected void onStartLoading() {
			super.onStartLoading();
			forceLoad();
		}

		@Override
		public JSONObject loadInBackground() {
			FourCabAPI api = new FourCabAPI(getContext());
			
			JSONObject request = api.checkIn(locs[0], locs[1], locs[2], locs[3]);
			
			JSONObject result = null;
			int iter = 0;
			while (result == null && iter < TRIES) {
				result = api.getRides();
				try {
					Thread.sleep(2000);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				iter += 1;
			}
			return result;
		}
	}
	
	public void onCancelClicked(final View view) {
		new Thread() {
			@Override
			public void run() {
				FourCabAPI api = new FourCabAPI(PeopleActivity.this);
				api.cancel();
				PeopleActivity.this.runOnUiThread(new Runnable() {
					
					@Override
					public void run() {
						finish();
					}
				});
			}
		}.start();
	}
}
