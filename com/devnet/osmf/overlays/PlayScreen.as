/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011.
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.devnet.osmf.overlays
{
	import com.devnet.osmf.controls.SimpleButton;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	//*********************************
	// Event Metadata:
	
	[Event(name="click", type="flash.events.MouseEvent")]
	[Event(name="mouseOver", type="flash.events.MouseEvent")]
	[Event(name="mouseDown", type="flash.events.MouseEvent")]
	[Event(name="mouseUp", type="flash.events.MouseEvent")]
	[Event(name="mouseOut", type="flash.events.MouseEvent")]
	
	/**********************************
	 * The PlayScreen class creates a play button 
	 * overlay for the media player component.
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class PlayScreen extends SimpleButton
	{
		//*****************************
		// Properties:
		
		private var _alphaUp:Number = .75;
		private var _alphaOv:Number = 1;
		
		// Stage assets
		public var background:Sprite;
		public var playButton:Sprite;
		
		//*****************************
		// Constructor:
		
		public function PlayScreen():void
		{
			// Add defaults here...
			playButton.alpha = _alphaUp;
		}
		
		//*****************************
		// Events:
		 
		override protected function onMouseOverHandler(event:MouseEvent):void
		{
			if ( enabled ) {
				playButton.alpha = _alphaOv;
			}
		}
		 
		override protected function onMouseOutHandler( event:MouseEvent ):void
		{
			if ( enabled ) {
				playButton.alpha = _alphaUp;
			}
		}
		 
		override protected function onMouseDownHandler( event:MouseEvent ):void
		{
			if ( enabled ) {
				playButton.alpha = _alphaOv;
			}
		}
		 
		override protected function onMouseUpHandler( event:MouseEvent ):void
		{
			if ( enabled ) {
				playButton.alpha = _alphaOv;
			}
		}
		
		//*****************************
		// Methods:
		
		/**
		 * Sets the size of the play button overlay. This size
		 * will commonly be the same as the media display area.
		 * 
		 * @param	w	Number representing the new width.
		 * @param	h	Number representing the new height.
		 */
		public function setSize( w:Number, h:Number=0 ):void
		{
			background.width = w;
			background.height = h;
			playButton.x = (w - playButton.width) / 2;
			playButton.y = (h - playButton.height) / 2;
		}
	}
}