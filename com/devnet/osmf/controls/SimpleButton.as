/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.devnet.osmf.controls
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	//*********************************
	// Event Metadata:
	
	[Event(name="click", type="flash.events.MouseEvent")]
	[Event(name="mouseOver", type="flash.events.MouseEvent")]
	[Event(name="mouseDown", type="flash.events.MouseEvent")]
	[Event(name="mouseUp", type="flash.events.MouseEvent")]
	[Event(name="mouseOut", type="flash.events.MouseEvent")]
	
	/**********************************
	 * The SimpleButton class creates a custom timeline-based button component. The component works by 
	 * navigating to named labels on the timeline which hold button graphic states.
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class SimpleButton extends MovieClip
	{
		//*****************************
		// Constants:
		
		public static const UP:String = "up";
		public static const OVER:String = "ov";
		public static const DOWN:String = "dn";
		public static const DOWN_OVER:String = "dnov";
		
		//*****************************
		// Properties:
		
		private var _selected:Boolean = false;
		private var _toggle:Boolean = false;
		private var _useDownState:Boolean = true;
		
		//*****************************
		// Constructor:
		
		public function SimpleButton():void
		{
			// Show hand cursor
			this.buttonMode = true;
			
			// Show graphic states triggered by mouse events.
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
		}
		
		//*****************************
		// Events:
		 
		protected function onMouseOverHandler(event:MouseEvent):void
		{
			if( enabled ){
				if(!_selected ){
					gotoAndStop(SimpleButton.OVER);
				}else if (_toggle) {
					gotoAndStop(SimpleButton.DOWN_OVER);
				}
			}
		}
		 
		protected function onMouseOutHandler( event:MouseEvent ):void
		{
			if( enabled ){
				if(!_selected ){
					gotoAndStop(SimpleButton.UP);
				}else if (_toggle) {
					gotoAndStop(SimpleButton.DOWN);
				}
			}
		}
		 
		protected function onMouseDownHandler( event:MouseEvent ):void
		{
			if( enabled ){
				if( !_toggle && _useDownState ){
					gotoAndStop(SimpleButton.DOWN);
				}
				else if( _toggle ){
					selected = !_selected;
				}
			}
		}
		 
		protected function onMouseUpHandler( event:MouseEvent ):void
		{
			if(!_selected && enabled ){
				gotoAndStop(SimpleButton.OVER);
			}
		}
	
		//*******************
		// Methods:
		
		/**
		 * Sets the selected state to true or false.
		 * 
		 * @param	value 	Set to true to show the selected state.
		 */
		public function setSelected( value:Boolean ):void
		{
			if( enabled ){
				if( value ) {
					gotoAndStop(SimpleButton.DOWN);
				}else{
					gotoAndStop(SimpleButton.UP);
				}
			}
			_selected = value;
		}
		
		//*****************************
		// Getter/Setters:
		
		//----------------
		// selected
		
		/**
		 * Set to true to trigger the selected (dn) 
		 * state in a toggle button.
		 */
		public function set selected( value:Boolean ):void
		{
			setSelected(value);
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		//----------------
		// toggle
		
		/**
		 * Set to true to allow the button to behave as 
		 * a toggle button.
		 */
		public function get toggle():Boolean
		{
			return _toggle;
		}
		
		public function set toggle( value:Boolean ):void
		{
			_toggle = value;
		}
		
		//----------------
		// useDownState
		
		/**
		 * Signals whether or not the down (dn) state should
		 * be used for a button set to toggle.
		 */
		public function get useDownState():Boolean
		{
			return _useDownState;
		}
		
		public function set useDownState( value:Boolean ):void
		{
			_useDownState = value;
		}
	}
}