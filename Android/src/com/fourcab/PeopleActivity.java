package com.fourcab;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;

public class PeopleActivity extends Activity {

	GridView mGridView;
	PeopleAdapter mAdapter;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_people);
		// Show the Up button in the action bar.
		getActionBar().setDisplayHomeAsUpEnabled(true);
		
		mAdapter = new PeopleAdapter(this);
		
		// Test data
		List<Person> people = new ArrayList<Person>();
		people.add(new Person("Jason", null));
		people.add(new Person("Cameron", null));
		people.add(new Person("Andrew", null));
		people.add(new Person("Other", null));
		mAdapter.setData(people);
		
		mGridView = (GridView) findViewById(R.id.grid);
		mGridView.setAdapter(mAdapter);
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
		
		public class ViewHolder {
			public TextView tv;
			public ImageView iv;
			
			public void populate(Person people) {
				this.tv.setText(people.name);
				//TODO: lazy load images
			}
		}
		
		public PeopleAdapter(Context context) {
			mContext = context;
			mInflater = LayoutInflater.from(context);
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
			vh.populate((Person) getItem(position));
			
			return convertView;
		}
		
	}
}
