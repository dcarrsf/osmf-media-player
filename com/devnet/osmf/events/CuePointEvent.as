/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011.
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.devnet.osmf.events
{
	import flash.events.Event;
	
	/**********************************
	 * The CuePointEvent class defines a custom
	 * event for cue points including cue point
	 * related properties.
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class CuePointEvent extends Event
	{
		//*****************************
		// Constants:
		
		public static const CUE_POINT:String = "cuePoint";
		
		//*****************************
		// Properties:
		
		private var _name:String;
		private var _parameters:Object;
		private var _time:Number;
		private var _cuePointType:String;
		
		//*****************************
		// Constructor:
		
		public function CuePointEvent( type:String, bubbles:Boolean, cancelable:Boolean, cpName:String, cpTime:Number, cpType:String, cpParameters:Object=null ):void
		{
			super(type, bubbles, cancelable);
			
			_name = cpName;
			_parameters = cpParameters;
			_time = cpTime;
			_cuePointType = cpType;
		}
		
		//*****************************
		// Methods:
		
		override public function clone():Event 
		{
			return new CuePointEvent( type, bubbles, cancelable, name, time, cuePointType, parameters );
		}
		
		//*****************************
		// Getter/Setters:
		
		/**
		 * Type of cue point (Navigation, Event, or ActionScript).
		 */
		public function get cuePointType():String 
		{
			return _cuePointType;
		}

		public function set cuePointType( value:String ):void 
		{
			_cuePointType = value;
		}
		
		/**
		 * Name of the cue point.
		 */
		public function get name():String 
		{
			return _name;
		}

		public function set name( value:String ):void 
		{
			_name = value;
		}
		
		/**
		 * Parameters associated with a cue point.
		 */
		public function get parameters():Object {
			return _parameters;
		}

		public function set parameters( value:Object ):void {
			_parameters = value;
		}
		
		/**
		 * Time associated with a cue point (in seconds).
		 */
		public function get time():Number {
			return _time;
		}

		public function set time( value:Number ):void {
			_time = value;
		}
	}
}