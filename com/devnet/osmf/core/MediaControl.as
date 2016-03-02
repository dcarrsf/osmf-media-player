/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011.
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.devnet.osmf.core
{
	import com.devnet.osmf.application.MediaDisplay;
	
	import flash.display.MovieClip;
	
	/**********************************
	 * The MediaControl class holds common
	 * functionality for all top level controls
	 * related to the media display component.
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class MediaControl extends MovieClip
	{
		//*****************************
		// Properties:
		
		private var _mediaPlayer:MediaDisplay;
		
		//*****************************
		// Constructor:
		
		public function MediaControl():void{
		}
		
		public function init():void
		{
			// Override in subclasses to configure
			// how the component interacts with the
			// media player.
		}
		
		//*************************
		// Getter/Setters:
		
		/**
		 * Set the mediaPlayer property to associate a 
		 * media display instance with a control instance.
		 */
		public function set mediaPlayer( value:MediaDisplay ):void
		{
			_mediaPlayer = value;
			
			// Initialize...
			init();
		}
		
		public function get mediaPlayer():MediaDisplay
		{
			return _mediaPlayer;
		}
	}
}