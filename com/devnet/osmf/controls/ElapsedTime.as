/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011.
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.devnet.osmf.controls
{
	import com.devnet.osmf.core.MediaControl;
	
	import flash.text.TextField;
	
	/**********************************
	 * The ElapsedTime class displays current time
	 * and total time in the 00:00 / 00:00 format.
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class ElapsedTime extends MediaControl
	{
		//*****************************
		// Properties:
		
		private var _currentTime:Number;
		private var _totalTime:Number;
		
		// Stage assets
		public var timeText:TextField;
		
		//*****************************
		// Constructor:
		
		public function ElapsedTime():void
		{
			// Set defaults here...
			currentTime = 0;
			totalTime = 0;
		}
		
		/**
		 * Called when the mediaPlayer reference is set. Use this method to
		 * initialize the control with the OSMF media display.
		 */
		public override function init():void
		{
			// Register with media player here...
		}
		
		//*****************************
		// Methods:
			
		/**
		 * Returns the formatted time from seconds (00:00 / 00:00).
		 * 
		 * @param	sec Number of seconds to format.
		 * @return 		Formatted String.
		 */
		public function getTime( sec:Number ):String 
		{
			var m:Number = Math.floor((sec%3600)/60);
			m = isNaN(m) ? 0 : m;
				
			var s:Number = Math.floor((sec%3600)%60);
			s = isNaN(s) ? 0 : s;
				
			return (m<10 ? "0"+m.toString() : m.toString())+":"+(s<10 ? "0"+s.toString() : s.toString());
		}
			
		/**
		 * Forces an update to the formatted time display.
		 */
		private function updateTime():void 
		{
			timeText.text = getTime(_currentTime) + " / " + getTime(_totalTime);
		}
		
		//*****************************
		// Getter/Setters:
		
		//----------------
		// currentTime
		
		/**
		 * Sets the current time value (in seconds) and
		 * forces an update to the time display.
		 */
		public function set currentTime( value:Number ):void
		{
			_currentTime = value;
			
			// Update text...
			updateTime();
		}
		
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		//----------------
		// totalTime
		
		/**
		 * Sets the total time value (in seconds) and
		 * forces an update to the time display.
		 */
		public function set totalTime( value:Number ):void
		{
			_totalTime = value;
			
			// Update text...
			updateTime();
		}
		
		public function get totalTime():Number
		{
			return _totalTime;
		}
	}
}