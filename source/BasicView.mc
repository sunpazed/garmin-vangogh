using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Timer as Timer;

enum {
  SCREEN_SHAPE_CIRC = 0x000001,
  SCREEN_SHAPE_SEMICIRC = 0x000002,
  SCREEN_SHAPE_RECT = 0x000003
}

class BasicView extends Ui.WatchFace {

    // globals
    var debug = false;
    var timer1;
    var timer_timeout = 80;
    var timer_steps = timer_timeout;
    var count = 0;
    var disable = true;

    // sensors / status
    var battery = 0;
    var bluetooth = true;

    // time
    var hour = null;
    var minute = null;
    var day = null;
    var day_of_week = null;
    var month_str = null;
    var month = null;

    // layout
    var vert_layout = false;
    var canvas_h = 0;
    var canvas_w = 0;
    var canvas_shape = 0;
    var canvas_rect = false;
    var canvas_circ = false;
    var canvas_semicirc = false;
    var canvas_tall = false;
    var canvas_r240 = false;

    // settings
    var set_leading_zero = false;

    // bitmaps
    var b_van = null;


    function initialize() {
     Ui.WatchFace.initialize();
    }


    function onLayout(dc) {

      // w,h of canvas
      canvas_w = dc.getWidth();
      canvas_h = dc.getHeight();

      // check the orientation
      if ( canvas_h > (canvas_w*1.2) ) {
        vert_layout = true;
      } else {
        vert_layout = false;
      }

      // let's grab the canvas shape
      var deviceSettings = Sys.getDeviceSettings();
      canvas_shape = deviceSettings.screenShape;

      if (debug) {
        Sys.println(Lang.format("canvas_shape: $1$", [canvas_shape]));
      }

      // find out the type of screen on the device
      canvas_tall = (vert_layout && canvas_shape == SCREEN_SHAPE_RECT) ? true : false;
      canvas_rect = (canvas_shape == SCREEN_SHAPE_RECT && !vert_layout) ? true : false;
      canvas_circ = (canvas_shape == SCREEN_SHAPE_CIRC) ? true : false;
      canvas_semicirc = (canvas_shape == SCREEN_SHAPE_SEMICIRC) ? true : false;
      canvas_r240 =  (canvas_w == 240 && canvas_w == 240) ? true : false;

      // set offsets based on screen type
      // positioning for different screen layouts
      if (canvas_tall) {
      }
      if (canvas_rect) {
      }
      if (canvas_circ) {
        if (canvas_r240) {
        } else {
        }
      }
      if (canvas_semicirc) {
      }


    }


    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }


    //! Update the view
    function onUpdate(dc) {


      // grab time objects
      var clockTime = Sys.getClockTime();
      var date = Time.Gregorian.info(Time.now(),0);

      // define time, day, month variables
      hour = clockTime.hour;
      minute = clockTime.min;
      day = date.day;
      month = date.month;
      day_of_week = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).day_of_week;
      month_str = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).month;

      // grab battery
      var stats = Sys.getSystemStats();
      var batteryRaw = stats.battery;
      battery = batteryRaw > batteryRaw.toNumber() ? (batteryRaw + 1).toNumber() : batteryRaw.toNumber();

      // do we have bluetooth?
      var deviceSettings = Sys.getDeviceSettings();
      bluetooth = deviceSettings.phoneConnected;

      // 12-hour support
      if (hour > 12 || hour == 0) {
          if (!deviceSettings.is24Hour)
              {
              if (hour == 0)
                  {
                  hour = 12;
                  }
              else
                  {
                  hour = hour - 12;
                  }
              }
      }

      // add padding to units if required
      if( minute < 10 ) {
          minute = "0" + minute;
      }

      if( hour < 10 && set_leading_zero) {
          hour = "0" + hour;
      }

      if( day < 10 ) {
          day = "0" + day;
      }

      if( month < 10 ) {
          month = "0" + month;
      }


      // clear the screen
      dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_BLACK);
      dc.clear();

      // w,h of canvas
      var dw = dc.getWidth();
      var dh = dc.getHeight();

      var b_width = 240/2;

      // here's where the magic happens.
      // we load, render, then unload each quadrant of the image to the framebuffer

      // render quadrant 01
      if (count % 4 == 0 || disable ) {
        b_van = Ui.loadResource(Rez.Drawables.van_01);
        dc.drawBitmap(0, 0, b_van);
      }

      // render quadrant 02
      if (count % 4 == 1 || disable) {
        b_van = Ui.loadResource(Rez.Drawables.van_02);
        dc.drawBitmap(b_width, 0, b_van);
      }

      // render quadrant 03
      if (count % 4 == 2 || disable) {
        b_van = Ui.loadResource(Rez.Drawables.van_03);
        dc.drawBitmap(0, b_width, b_van);
      }

      // render quadrant 04
      if (count % 4 == 3 || disable) {
        b_van = Ui.loadResource(Rez.Drawables.van_04);
        dc.drawBitmap(b_width, b_width, b_van);
      }

      // render the time
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
      dc.drawText((dw/2)+2,(dh/5)-(dc.getFontHeight(Gfx.FONT_SYSTEM_NUMBER_HOT)/2)+2,Gfx.FONT_SYSTEM_NUMBER_HOT,hour.toString() + ":" + minute.toString(),Gfx.TEXT_JUSTIFY_CENTER);

      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      dc.drawText(dw/2,(dh/5)-(dc.getFontHeight(Gfx.FONT_SYSTEM_NUMBER_HOT)/2),Gfx.FONT_SYSTEM_NUMBER_HOT,hour.toString() + ":" + minute.toString(),Gfx.TEXT_JUSTIFY_CENTER);

    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    // this is our animation loop callback
    function callback1() {

      // redraw the screen
      Ui.requestUpdate();
      count = count + 1;

      // timer not greater than 500ms? then let's start the timer again
      if (timer_steps < 500) {
        timer1 = new Timer.Timer();
        timer1.start(method(:callback1), timer_steps, false );
      } else {
        // timer exists? stop it
        if (timer1) {
          timer1.stop();
        }
      }


    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {

      // let's start our animation loop
      disable = false;
      timer1 = new Timer.Timer();
      timer1.start(method(:callback1), timer_steps, false );

    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {

      disable = true;
      Ui.requestUpdate();

      // bye bye timer
      if (timer1) {
        timer1.stop();
      }

      timer_steps = timer_timeout;


    }

}
