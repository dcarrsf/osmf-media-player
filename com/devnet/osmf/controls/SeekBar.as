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
	
	//*********************************
	// Event Metadata:
	
	[Event(name="change", type="flash.events.Event")]
	
	/**********************************
	 * The SeekBar class creates a visual representation
	 * of the media's loading progress and current time position
	 * versus total time position. The seek bar can also be used
	 * to seek to a position within the video (if the seekEnabled
	 * property is set to true).
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class SeekBar extends MediaControl
	{
		//*****************************
		// Properties:
		
		private var _dragging:Boolean = false;
		private var _bytesLoaded:Number = 0;
		private var _bytesTotal:Number = 0;
		private var _currentTime:Number = 0;
		private var _playing:Boolean = false;
		private var _seekEnabled:Boolean = true;
		private var _totalTime:Number = 0;
		
		// Stage assets...
		public var track:Sprite;
		public var progressBar:Sprite;
		public var scrubBar:Sprite;
		public var handle:SimpleButton;
		
		//*****************************
		// Constructor:
		
		public function SeekBar():void
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
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
		
		protected function addedToStageHandler(event:Event):void
		{
			setProgress(0, 100);
			setSeekBar(0, 100);
					
			// Listen to mouse events...
			this.addEventListener(MouseEvent.CLICK, onTrackClick);
			handle.addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			stage.addEventListener(MouseEvent.MOUSE_UP, onDragStop);
		}
		
		protected function onDragStart(event:MouseEvent):void
		{
			if( enabled && _seekEnabled ) 
			{
				// Draw bounds
				var bx:Number = 0;
				var by:Number = 0;
				var bw:Number = track.width - handle.width;
				var bh:Number = 0;
				var bnds:Rectangle = new Rectangle(bx, by, bw, bh);
				
				// Start drag...
				_dragging = true;
				handle.startDrag(false, bnds);
				
				// Update view
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		protected function onDragStop(event:MouseEvent):void
		{
			if( enabled && _dragging )
			{
				handle.stopDrag();
					
				// Seek
				var seekTime:Number = mediaPlayer.totalTime * (scrubBar.width / track.width);
				mediaPlayer.seek(seekTime);
				
				// Update view...
				_dragging = false;
				
				// Clean up
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				
				// Relay event
				dispatchEvent(new Event("change"));
			}
		}
		
		protected function onEnterFrame(event:Event):void
		{
			if( enabled && _dragging )
			{
				scrubBar.width = handle.x - scrubBar.x;
				
				// Seek (This throws off the media player!)
			//	var seekTime:Number = mediaPlayer.totalTime * (scrubBar.width / track.width);
			//	mediaPlayer.seek(seekTime);
			}
		}
		
		protected function onTrackClick(event:MouseEvent):void
		{
			if( enabled && _seekEnabled ) 
			{
				// Seek
				var seekTime:Number = mediaPlayer.totalTime * (mouseX / track.width);
				mediaPlayer.seek(seekTime);
				handle.x = mouseX;
				scrubBar.width = handle.x - scrubBar.x;
				
				// Relay event
				dispatchEvent(new Event("change"));
			}
		}
		
		//*****************************
		// Methods:
		
		/**
		 * Updates the loading progress display on the seek bar.
		 * 
		 * @param	bl	Number representing bytes loaded.
		 * @param	bt	Number representing bytes total.
		 */
		public function setProgress(bl:Number, bt:Number):void
		{
			_bytesLoaded = bl;
			_bytesTotal = bt;
			
			// Set progress bar width
			progressBar.width = track.width * bl / bt;
		}
		
		/**
		 * Updates the seek bar position.
		 * 
		 * @param	ct	Number representing the current time.
		 * @param	tt	Number representing the total time.
		 */
		public function setSeekBar(ct:Number, tt:Number):void
		{
			if(!_dragging )
			{
				_currentTime = ct;
				_totalTime = tt;
				
				// Set progress bar width
				scrubBar.width = track.width * ct / tt;
				handle.x = scrubBar.width;
			}
		}
		
		/**
		 * Sets the size of the seek bar. Currently only the 
		 * width value is taken into account.
		 * 
		 * @param	w	Number representing the new width.
		 * @param	h	Number representing the new height.
		 */
		public function setSize(w:Number, h:Number):void
		{
			track.width = w;
			
			// Update layout
			scrubBar.width = track.width * _currentTime / _totalTime;
			progressBar.width = track.width * _bytesLoaded / _bytesTotal;
			handle.x = scrubBar.width;
			
			// h (height) is ignored in this version of the seekbar
		}
		
		//*************************
		// Getter/Setters:
		
		//-----------------
		// seekEnabled
		
		/**
		 * Set seekEnabled to true to allow seeking and scrubbing
		 * along the seekbar. Or set to false to disable seeking for
		 * progressive video downloads with seeking issues.
		 */
		public function set seekEnabled( value:Boolean ):void
		{
			_seekEnabled = value;
			
			// Enable or disable handle button...
			handle.buttonMode = _seekEnabled;
		}
		
		public function get seekEnabled():Boolean
		{
			return _seekEnabled;
		}
		
		//-----------------
		// read-only:
		
		/**
		 * True if the scrub handle is currently pressed and dragging.
		 */
		public function get dragging():Boolean
		{
			return _dragging;
		}
	}
}