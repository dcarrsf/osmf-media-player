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
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	//*********************************
	// Event Metadata:
	
	[Event(name="change", type="flash.events.Event")]
	
	/**********************************
	 * The VolumeSlider class creates a slider
	 * control for setting the media volume.
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class VolumeSlider extends MediaControl
	{
		//*****************************
		// Properties:

		private var _dragging:Boolean = false;		
		private var _volume:Number = 1;
		
		// Stage assets
		public var track:Sprite;
		public var handle:SimpleButton;
		
		//*****************************
		// Constructor:
		
		public function VolumeSlider():void
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
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
		// Events:
		
		protected function onAddedToStage( event:Event ):void
		{
			track.buttonMode = true;
			
			// Listen for mouse events
			track.addEventListener(MouseEvent.CLICK, onTrackClick);
			handle.addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			stage.addEventListener(MouseEvent.MOUSE_UP, onDragStop);
		}
		 
		protected function onDragStart( event:MouseEvent ):void
		{
			// Constrain to vertical track
			var rx:uint = handle.x;
			var ry:uint = track.y;
			var rw:uint = 0;
			var rh:uint = track.height;
			var rect:Rectangle = new Rectangle(rx, ry, rw, rh);
			
			// Start drag!
			_dragging = true;
			handle.startDrag(true, rect);
			
			// Update volume during drag...
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		 
		protected function onDragStop( event:MouseEvent ):void
		{
			if( _dragging ) {
				_dragging = false;
				
				// Stop drag!
				handle.stopDrag();
				onEnterFrame();
				
				// Clean up...
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		protected function onEnterFrame( event:Event=null ):void
		{
			// Update volume
			_volume = 1 - ((handle.y - track.y) / track.height);
			
			// Relay event
			dispatchEvent(new Event(Event.CHANGE));
		}
		 
		protected function onTrackClick( event:MouseEvent ):void
		{
			// Adjust vertical position...
			handle.y = mouseY < handle.y ? mouseY : mouseY - handle.width;
			
			// Update volume
			_volume = 1 - ((handle.y - track.y) / track.height);
			
			// Relay event
			dispatchEvent(new Event(Event.CHANGE));
		}
		 
		//*******************
		// Methods:
		
		/**
		 * Updates the volume display.
		 * 
		 * @param	value	Volume represented as a Number between 0 and 1.
		 */
		public function setVolume( value:Number ):void
		{
			_volume = value;
			
			// Handle position
			handle.y = track.y + (track.height * value);
		}
		
		//*****************************
		// Getter/Setters:
		
		//----------------
		// volume
		
		/**
		 * Sets the volume level display.
		 */
		public function set volume( value:Number ):void
		{
			setVolume(value);
		}
		
		public function get volume():Number
		{
			return _volume;
		}
	}
}