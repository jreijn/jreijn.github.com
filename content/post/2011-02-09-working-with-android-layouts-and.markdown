---
categories:
- Software Engineering
comments: true
date: "2011-02-09T00:00:00Z"
title: Working with Android Layouts and ListViews
---

I've been the owner of an <a href="http://www.android.com/">Android</a> phone for about 5 months now. The thought of creating an application for the Android platform has appealed to me ever since. That's why I recently started with Android development as a learning project for the next couple of weeks. In this post I will start sharing my experience with developing Android applications.

## Getting started
The basic thing, while starting out with a new technology, is getting to know the fundamentals. There are some great introduction and advanced <a href="http://developer.android.com/videos/index.html#v=M1ZBjlCRfz0">videos</a> by Google on how to develop applications for the Android platform. The use of proper tooling can also help out a lot on this part. Both Eclipse and <a href="http://www.jetbrains.com/idea/">IntelliJ</a> has great <a href="http://blogs.jetbrains.com/idea/tag/android/">support</a> for developing Android application since IntelliJ 10 (and it's free to use).

For this project I'm trying to create a native Android client based on the <a href="http://www.demo.onehippo.com/mobile/">Hippo GoGreen mobile website</a>. If you take a look at the mobile site, there are two main entry points for browsing the site: Products and Events. I started out with Events, where I wanted to create a list of event items and show the event with a nice calendar item on the left next to the title of the event. I wanted the end result to look something like:

<div class="separator" style="clear: both; text-align: center;"><a href="http://4.bp.blogspot.com/_hd6Y7yyFK7E/TVBl_KaBOMI/AAAAAAAAAb4/-wEy0SMnSaU/s1600/listitems.png" imageanchor="1"><img border="0" src="http://4.bp.blogspot.com/_hd6Y7yyFK7E/TVBl_KaBOMI/AAAAAAAAAb4/-wEy0SMnSaU/s320/listitems.png" height="138" width="320" /></a></div>

In Android you can create a screen/page by creating an Activity. Adding a ListView to an Activity is a matter of configuration. With Android you can define the layout of your View either by defining a piece of XML, or by writing the code in Java. For this example I use the XML notation.

``` xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"    
             android:layout_width="fill_parent"
             android:layout_height="fill_parent">

  <ListView android:id="@android:id/list"
            android:layout_width="fill_parent"
            android:layout_height="fill_parent" />

  <TextView android:id="@android:id/empty"
            android:layout_width="fill_parent"
            android:layout_height="fill_parent"
            android:text="@string/empty_events"
            android:gravity="center"  
            android:textAppearance="?android:attr/textAppearanceMedium" />
</FrameLayout>
```

As you can see the layout contains a ListView and a TextView. You can probably guess what the ListView is for, but I've added the TextView to show a message with 'No events' to the end user if no events are found.Adding some text to a list item in a ListView is quite simple and there are some good examples available in the Android tutorials. When I got to the point where I needed to add the dynamic calendar, I really had to start digging into layout options. Android has several kinds of default layouts available.Hovering the text over an image might not be that hard for an experienced Android developer (and there might be other ways than how I solved it), but when you're first introduced to the Android layout system it might be a bit confusing sometimes. My main goal was to show the day of the month and an abbreviation of the month dynamically on top of the calendar image and this is how I did it.

## Customizing the list item view

To be able to show a customized list item View we first need to create a snippet of XML that represents the layout of our list item.

``` xml
<?xml version="1.0" encoding="utf-8"?>
  <RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
     android:id="@+id/list_item_event"
     android:layout_width="fill_parent"
     android:layout_height="fill_parent"
     style="@style/ListItem">    
  <org.onehippo.gogreen.android.ui.view.SimpleCalendarView
           android:id="@+id/calendar_today"        
           android:layout_height="fill_parent"        
           android:layout_width="wrap_content"        
           android:layout_alignParentTop="true"        
           android:layout_alignParentBottom="true"        
           android:gravity="center_horizontal|top"/>    
  <TextView android:gravity="left"        
           android:id="@+id/event_title"
           android:layout_alignParentRight="true"
           android:layout_alignParentBottom="true"
           android:layout_alignWithParentIfMissing="true"
           android:layout_width="fill_parent"
           android:layout_height="wrap_content"
           android:layout_toRightOf="@+id/calendar_today"
           style="@style/EventTitle" />
</RelativeLayout>
```

As you can see in the above snippet, I'm using a RelativeLayout for my list item. The nice thing about the RelativeLayout is that you can define the relative position of the TextView versus the SimpleCalendarView. In my case the text is to the right of the calendar item. In the above layout configuration the list item contains two elements: the calendar (which is our custom View component) and a TextView, which will contain the title.

## Creating the calendar view

For the dynamic calendar I've created a custom View which will position my 'inner' views in such a way that both TextViews containing the day and month position nicely on top of the ImageView. Now let's take a look at some code.

``` java
public class SimpleCalendarView extends FrameLayout {    
  private ImageView calendarImageView = null;    
  private TextView calendarMonthTextView = null;    
  private TextView calendarDayTextView = null;    

  public SimpleCalendarView(Context context) {        
    super(context);    
  }    

  public SimpleCalendarView(Context context, AttributeSet attributeSet) {        
    super(context, attributeSet);        
    setUpImageView(context);        
    setUpDayView(context);        
    setUpMonthView(context);        

    /* Add child views to this object. */        
    addView(calendarImageView);        
    addView(calendarMonthTextView);        
    addView(calendarDayTextView);    
  }    

  private void setUpImageView(final Context context) {        
    calendarImageView = new ImageView(context);
    calendarImageView.setImageResource(R.drawable.bg_calendar);
    calendarImageView.setScaleType(ImageView.ScaleType.FIT_XY);
  }    

  private void setUpMonthView(final Context context) {        
    calendarMonthTextView = new TextView(context);
    calendarMonthTextView.setTextSize(7);
    calendarMonthTextView.setTypeface(Typeface.DEFAULT_BOLD);
    calendarMonthTextView.setPadding(0, 4, 0, 0);
    calendarMonthTextView.setTextColor(Color.WHITE);
    calendarMonthTextView.setGravity(Gravity.CENTER_HORIZONTAL);
  }    

  private void setUpDayView(final Context context) {        
    calendarDayTextView = new TextView(context);        
    calendarDayTextView.setTextSize(10);
    calendarDayTextView.setTypeface(Typeface.DEFAULT_BOLD);
    calendarDayTextView.setPadding(0, 13, 0, 0);
    calendarDayTextView.setTextColor(Color.WHITE);
    calendarDayTextView.setGravity(Gravity.CENTER_HORIZONTAL);
  }     
  public void setDayOfMonth(final int day) {
    this.calendarDayTextView.setText(Integer.toString(day));
  }    

  public void setMonth(final String month) {        
    this.calendarMonthTextView.setText(month);
  }
}
```

If you look at the above code you can see that adding the ImageView and TextViews is quite straight-forward. Because the SimpleCalendarView extends a FrameLayout, all inner views are positioned to the top left of the View by default. By setting the gravity of both TextViews to CENTER_HORIZONTAL the text is positioned in the middle of the image. Now by setting some top padding, the day and month are put into place.So after all it wasn't that hard to do. You just have to get to know the possibilities of the different Layouts. For my own convenience I added two extra methods to the SimpleCalendarView, so that I can easily set the month and day for each event without having to call the individual TextViews.

## What's next?

This has been an interesting lesson in working with layouts, views and lists. My next post will probably be about how to retrieve data from a remote server and use that data to feed the list.

### Resources used

The following resources were used while trying to create this view:
<ul><li><a href="http://developer.android.com/resources/tutorials/views/hello-listview.html">Hello ListView tutorial</a></li><li><a href="http://developer.android.com/resources/tutorials/views/index.html">Hello Views</a></li></ul>
