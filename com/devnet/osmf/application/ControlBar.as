/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011.
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.devnet.osmf.application
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.FullScreenEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.System;
	
	import com.devnet.osmf.controls.*;
	import com.devnet.osmf.core.MediaControl;
	import com.devnet.osmf.events.MediaEvent;
	import com.devnet.osmf.events.ProgressEvent;
	import com.devnet.osmf.overlays.PlayScreen;
	
	/**********************************
	 * The ControlBar class creates a component that manages user
	 * interface controls for the MediaDisplay component. 
	 * 
	 * <p>
	 * <b>Example:</b> This example shows how to assign the media display instance to the control bar instance.
	 * <listing>
	 
	// Link the controls to the display...
	controlBar.mediaPlayer = mediaDisplay;
	 * </listing>
	 * </p>
	 * <p>
	 * <b>Example:</b> This example shows how to configure the ControlBar instance using ActionScript.
	 * <listing>
	 
	// Setup control bar
	controlBar.hdWidth = 768;
	controlBar.hdHeight = 428;
	controlBar.shareUrl = "http://www.adobe.com/devnet/flash/";
	controlBar.useElapsedTime = false;
	controlBar.useFullScreenButton = false;
	controlBar.useVolumeButton = false;
	 * </listing>
	 * The examples above assume that the components exist on the Stage with respective instance names; mediaPlayer and controlBar.
	 * </p>
	 * 
	 * @see MediaDisplay
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class ControlBar extends MediaControl
	{
		//*****************************
		// Properties:
		
		private var _defaultWidth:Number;
		private var _mediaWidth:Number;
		private var _mediaHeight:Number;
		private var _seekEnabled:Boolean = true;
		private var _shareColumns:Number = 2;
		private var _shareDisplayState:Number = 3;
		private var _shareMenu:Object;
		private var _shareMenuLoader:Loader;
		private var _shareUrl:String = "http://www.adobe.com/devnet/flash/";
		
		private var _usePlayOverlay:Boolean = true;
		private var _usePlayPauseButton:Boolean = true;
		private var _useSeekBar:Boolean = true;
		private var _useElapsedTime:Boolean = true;
		private var _useShareButton:Boolean = true;
		private var _useFullScreenButton:Boolean = true;
		private var _useVolumeButton:Boolean = true;
		private var _useVolumeSlider:Boolean = true;
		
		// Setting the HD video width and height properties
		// forces the media player to use hardware acceleration
		// when entering full screen mode.
		private var _hdWidth:Number;
		private var _hdHeight:Number;
		
		// Stage assets...
		public var hline:Sprite;
		public var background:Sprite;
		public var playPauseButton:SimpleButton;
		public var seekBar:SeekBar;
		public var elapsedTime:ElapsedTime;
		public var shareButton:SimpleButton;
		public var fullScreenButton:SimpleButton;
		public var volumeButton:SimpleButton;
		public var volumeSlider:VolumeSlider;
		public var playOverlay:PlayScreen;
		
		//*****************************
		// Constructor:
		
		public function ControlBar():void
		{
			// Setup security...
			Security.loadPolicyFile("http://cache.addthis.com/crossdomain.xml");
			Security.allowDomain("*");
			
			// Save authortime default size
			_defaultWidth = background.width;
			
			// Events
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the mediaPlayer reference is set. Use this method to
		 * initialize the control with the OSMF media display.
		 */
		public override function init():void
		{
			// Listen to media events...
			mediaPlayer.addEventListener(MediaEvent.AUTO_REWOUND, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.BUFFERING_STATE_ENTERED, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.COMPLETE, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.DURATION_CHANGED, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.PAUSED_STATE_ENTERED, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.PLAYHEAD_UPDATE, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.PLAYING_STATE_ENTERED, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.READY, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.STOPPED_STATE_ENTERED, onMediaPlayerEvent);
			mediaPlayer.addEventListener(MediaEvent.VOLUME_CHANGED, onMediaPlayerEvent);
			mediaPlayer.addEventListener(ProgressEvent.MEDIA_PROGRESS, onMediaPlayerProgress);
			
			// Save player size
			_mediaWidth = mediaPlayer.width;
			_mediaHeight = mediaPlayer.height;
			
			// Setup seekbar
			seekBar.mediaPlayer = mediaPlayer;
			
			// Update layout
			setSize(_mediaWidth, height);
		}
		
		//*****************************
		// Events:
		
		protected function addedToStageHandler(event:Event):void
		{
			// Play puase button
			playPauseButton.toggle = true;
			playPauseButton.addEventListener(MouseEvent.CLICK, onPlayPauseClick);
			
			// SeekBar
			seekBar.seekEnabled = _seekEnabled;
			
			// Share button
			shareButton.addEventListener(MouseEvent.CLICK, onShareClick);
			
			// Full screen button
			fullScreenButton.toggle = true;
			fullScreenButton.addEventListener(MouseEvent.CLICK, onFullScreenClick);
			
			// Volume button
			volumeButton.toggle = false;
			volumeButton.useDownState = false;
			volumeButton.addEventListener(MouseEvent.CLICK, onVolumeClick);
			
			// Volume slider
			volumeSlider.visible = false;
			volumeSlider.addEventListener(Event.CHANGE, onVolumeChange);
			
			// Play overlay
			playOverlay.mouseEnabled = false;
			playOverlay.addEventListener(MouseEvent.CLICK, onPlayClick);
			
			// Stage
			stage.addEventListener( FullScreenEvent.FULL_SCREEN, onFullScreenChange );
		}
		
		protected function onFullScreenClick(event:MouseEvent):void
		{
			// Show full screen
			if( fullScreenButton.selected ) {
				if( hdWidth > 0 && hdHeight > 0 )
				{
					// Set the Flash Player resolution to full
					// size for HD video. Ex. 720p (1280x720).
					var rect:Rectangle = getFullScreenSourceRect(Capabilities.screenResolutionX, Capabilities.screenResolutionY, hdWidth, hdHeight);
					
					// Update display and controlbar size...
					mediaPlayer.width = rect.width;
					mediaPlayer.height = rect.height;
					setSize(rect.width, rect.height);
					
					// Activate hardware scaling based on HD state...
					stage.fullScreenSourceRect = rect;
				}
				try{
					stage.displayState = StageDisplayState.FULL_SCREEN;
				}catch (e:Error) {
					// If full screen fails it's most likely because
					// the allowFullScreen HTML parameter is not set
					// to true.
					fullScreenButton.selected = false;
				}
			}else{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
 		
		protected function onFullScreenChange(event:FullScreenEvent):void
		{
			if( event.fullScreen == false &&
				hdWidth > 0 && hdHeight > 0 ) 
			{
				mediaPlayer.width = _mediaWidth;
				mediaPlayer.height = _mediaHeight;
				setSize(_mediaWidth, _mediaHeight + background.height);
			}
			fullScreenButton.selected = event.fullScreen;
		}
		
		protected function onMediaPlayerEvent(event:MediaEvent):void
		{
			switch( event.type )
			{
				case MediaEvent.AUTO_REWOUND:
					
					if( mediaPlayer.loop == false ){
						playOverlay.visible = true;
					}
					playPauseButton.selected = false;
					break;
					
				case MediaEvent.BUFFERING_STATE_ENTERED:
					
					// The buffer bar is not represented in this version
					// of the control bar component.
					break;
					
				case MediaEvent.CLOSE:
					
					playOverlay.visible = true;
					playPauseButton.selected = false;
					break;
					
				case MediaEvent.COMPLETE:
					
					if( mediaPlayer.autoRewind == false &&
						mediaPlayer.loop == false ){
						playOverlay.visible = true;
					}
					break;
					
				case MediaEvent.DURATION_CHANGED:
				
					// This event is closer to the FLVPlaybacks READY
					// event then the OSMF READY event is...
					
					elapsedTime.totalTime = mediaPlayer.totalTime;
					seekBar.setSeekBar(mediaPlayer.playheadTime, mediaPlayer.totalTime);
					break;
					
				case MediaEvent.PAUSED_STATE_ENTERED:
					
					playOverlay.visible = true;
					playPauseButton.selected = false;
					break;
					
				case MediaEvent.PLAYING_STATE_ENTERED:
				
					playOverlay.visible = false;
					playPauseButton.selected = true;
					break;
					
				case MediaEvent.PLAYHEAD_UPDATE:
					
					elapsedTime.currentTime = mediaPlayer.playheadTime;
					seekBar.setSeekBar(mediaPlayer.playheadTime, mediaPlayer.totalTime);
					break;
					
				case MediaEvent.READY:
					
					// Handle *early* ready event timing...
					playOverlay.mouseEnabled = true;
					break;
					
				case MediaEvent.STOPPED_STATE_ENTERED:
					
					playOverlay.visible = true;
					playPauseButton.selected = false;
					break;
					
				case MediaEvent.VOLUME_CHANGED:
					
					volumeSlider.volume = mediaPlayer.volume;
					break;
			}
		}
		
		protected function onMediaPlayerProgress( event:ProgressEvent ):void
		{
			seekBar.setProgress(event.bytesLoaded, event.bytesTotal);
		}
		
		protected function onPlayClick(event:MouseEvent):void
		{
			mediaPlayer.play();
		}
		
		protected function onPlayPauseClick(event:MouseEvent):void
		{
			if( playPauseButton.selected ) {
				mediaPlayer.play();
			}else{
				mediaPlayer.pause();
			}
		}
		
		protected function onShareClick(event:MouseEvent):void
		{
			if( shareUrl )
			{
				// Load share menu...
				if(!_shareMenu ) {
					_shareMenuLoader = new Loader();
					_shareMenuLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onShareMenuLoaded);
					_shareMenuLoader.load(new URLRequest("AddThisMenuAPI.swf"));
					addChild(_shareMenuLoader);
				}else{
					_shareMenu.show(_shareColumns,_shareDisplayState);
				}
			}
		}
		
		protected function onShareMenuLoaded(event:Event):void
		{
			// Configure menu...
			_shareMenu = event.currentTarget.content;
			_shareMenu.configure(shareUrl);
			_shareMenu.show(_shareColumns,_shareDisplayState);
			_shareMenu.x = shareButton.x + shareButton.width - _shareMenu.width;
			_shareMenu.y = shareButton.y - 3 - _shareMenu.height;
		}
		
		protected function onVolumeClick(event:MouseEvent):void
		{
			if( _useVolumeSlider ) {
				// Toggle slider visiblity
				volumeSlider.visible = !volumeSlider.visible;
			}else{
				// Behave as a mute button
				mediaPlayer.volume = volumeButton.selected ? 0 : 1;
			}
		}
		
		protected function onVolumeChange(event:Event):void
		{
			// Show mute state if slider volume is 0
			volumeButton.selected = ( volumeSlider.volume == 0 );
			
			// Update player
			mediaPlayer.volume = volumeSlider.volume;
		}
		
		//*****************************
		// Methods:
		
		/**
		 * Computes the optimal size of the fullScreenSource rectangle.
		 * 
		 * @param	screenWidth		Capabilties.screenResolutionX.
		 * @param	screenHeight	Capabilties.screenResolutionY.
		 * @param	videoWidth		Video HD width parameter.
		 * @param	videoHeight		Video HD height parameter.
		 * @return
		 */
 		private function getFullScreenSourceRect(screenWidth:int, screenHeight:int, videoWidth:int, videoHeight:int):Rectangle
 		{
 			var ratio:Number = (screenWidth / screenHeight) / ( videoWidth / videoHeight);
			var sourceWidth:Number = videoWidth;
 			var sourceHeight:Number = videoHeight;
 			if( ratio > 1 ){
 				sourceWidth = videoWidth * ratio;					
 			}else{
 				sourceHeight = videoHeight / ratio;
 			}
			return new Rectangle(mediaPlayer.x, mediaPlayer.y, sourceWidth, sourceHeight);
 		}
		
		/**
		 * Sets the size of the control bar. Adjust this method if 
		 * you change the layout of controls.
		 * 
		 * @param	w	Number representing the new width.
		 * @param	h	Number representing the new height.
		 */
		public function setSize( w:Number, h:Number ):void
		{
			var xPos:Number = w;
			var yPos:Number = h - background.height;
			
			// Volume
			if( _useVolumeSlider ) {
				volumeSlider.y = h - volumeSlider.height - background.height - 3;
				volumeSlider.x = w - volumeSlider.width;
			}
			if( _useVolumeButton ) {
				volumeButton.y = yPos;
				volumeButton.x = xPos = w - volumeButton.width;
			}
			// Full screen
			if( _useFullScreenButton ) {
				fullScreenButton.y = yPos;
				fullScreenButton.x = xPos = xPos - fullScreenButton.width;
			}
			// Share
			if( _useShareButton ) {
				shareButton.y = yPos;
				shareButton.x = xPos = xPos - shareButton.width;
			}
			// Elapsed time
			if( _useElapsedTime ) {
				elapsedTime.y = yPos;
				elapsedTime.x = xPos = xPos - elapsedTime.width;
			}
			// Seekbar
			if ( _useSeekBar ) {
				
				seekBar.y = yPos;
				seekBar.x = usePlayPauseButton ? playPauseButton.x + playPauseButton.width : 0;
				seekBar.setSize( xPos - seekBar.x, height);
			}
			// Play pause button
			playPauseButton.y = yPos;
			
			// Background
			hline.x = 0;
			hline.y = yPos - 1;
			hline.width = w + 2;
			background.width = w;
			background.y = yPos;
			
			// Play overlay
			playOverlay.setSize(w, h);
		}
		
		//*************************
		// Getter/Setters:
		
		//----------------
		// hdWidth
		
		/**
		 * Set the actual size of the video width here in
		 * order to trigger hardware accerlation scaling during
		 * full screen mode. Leaving this parameter null forces
		 * the media display to use standard Flash Player scaling
		 * during full screen mode.
		 */
		[Inspectable(defaultValue=0,type="Number")]
		public function set hdWidth( value:Number ):void
		{
			_hdWidth = value;
		}
		public function get hdWidth():Number
		{
			return _hdWidth;
		}
		
		//----------------
		// hdHeight
		
		/**
		 * Set the actual size of the video height here in
		 * order to trigger hardware accerlation scaling during
		 * full screen mode. Leaving this parameter null forces
		 * the media display to use standard Flash Player scaling
		 * during full screen mode.
		 */
		[Inspectable(defaultValue=0,type="Number")]
		public function set hdHeight( value:Number ):void
		{
			_hdHeight = value;
		}
		public function get hdHeight():Number
		{
			return _hdHeight;
		}
		
		//-----------------
		// seekEnabled
		
		/**
		 * Set seekEnabled to false when using progressive video
		 * whose encoding creates unpredictable seek times. Doing so
		 * switches the seek bar to a progress indicator.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set seekEnabled( value:Boolean ):void
		{
			_seekEnabled = value;
			
			// Enable or disable seekbar
			seekBar.seekEnabled = value;
		}
		
		public function get seekEnabled():Boolean
		{
			return _seekEnabled;
		}
		
		//----------------
		// shareColumns
		
		/**
		 * Set the number of icon columns in the AddThis share
		 * menu widget.
		 */
		[Inspectable(defaultValue=2,type="Number")]
		public function set shareColumns( value:Number ):void
		{
			_shareColumns = value;
		}
		public function get shareColumns():Number
		{
			return _shareColumns;
		}
		
		//----------------
		// shareDisplayState
		
		/**
		 * Set the display layout state of the AddThis share menu.
		 */
		[Inspectable(defaultValue=3,type="Number")]
		public function set shareDisplayState( value:Number ):void
		{
			_shareDisplayState = value;
		}
		public function get shareDisplayState():Number
		{
			return _shareDisplayState;
		}
		
		//----------------
		// shareUrl
		
		/**
		 * Set the URL to share when an AddThis share option is 
		 * selected.
		 */
		[Inspectable(defaultValue="http://www.adobe.com/devnet/flash/",type="String")]
		public function set shareUrl( value:String ):void
		{
			_shareUrl = value;
		}
		public function get shareUrl():String
		{
			return _shareUrl;
		}
		
		//----------------
		// usePlayOverlay
		
		/**
		 * Set to true to show the play button overlay or false to hide it.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set usePlayOverlay( value:Boolean ):void
		{
			_usePlayOverlay = value;
			
			// Show control
			playOverlay.visible = value;
		}
		
		public function get usePlayOverlay():Boolean
		{
			return _usePlayOverlay;
		}
		
		//----------------
		// usePlayPauseButton
		
		/**
		 * Set to true to show the play pause button or false to hide it.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set usePlayPauseButton( value:Boolean ):void
		{
			_usePlayPauseButton = value;
			
			// Show control
			playPauseButton.visible = value;
		}
		
		public function get usePlayPauseButton():Boolean
		{
			return _usePlayPauseButton;
		}
		
		//----------------
		// useSeekBar
		
		/**
		 * Set to true to show the seek bar or false to hide it.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set useSeekBar( value:Boolean ):void
		{
			_useSeekBar = value;
			
			// Show control
			seekBar.visible = value;
		}
		
		public function get useSeekBar():Boolean
		{
			return _useSeekBar;
		}
		
		//----------------
		// useElapsedTime
		
		/**
		 * Set to true to show the elapsed time control or false to hide it.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set useElapsedTime( value:Boolean ):void
		{
			_useElapsedTime = value;
			
			// Show control
			elapsedTime.visible = value;
		}
		
		public function get useElapsedTime():Boolean
		{
			return _useElapsedTime;
		}
		
		//----------------
		// useShareButton
		
		/**
		 * Set to true to show the share button and menu or false to hide it.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set useShareButton( value:Boolean ):void
		{
			_useShareButton = value;
			
			// Show control
			shareButton.visible = value;
		}
		
		public function get useShareButton():Boolean
		{
			return _useShareButton;
		}
		
		//----------------
		// useFullScreenButton
		
		/**
		 * Set to true to show the full screen button or false to hide it.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set useFullScreenButton( value:Boolean ):void
		{
			_useFullScreenButton = value;
			
			// Show control
			fullScreenButton.visible = value;
		}
		
		public function get useFullScreenButton():Boolean
		{
			return _useFullScreenButton;
		}
		
		//----------------
		// useVolumeButton
		
		/**
		 * Set to true to show the volume button or false to hide it. 
		 * If set to false, the volume slider is unavailable.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set useVolumeButton( value:Boolean ):void
		{
			_useVolumeButton = value;
			
			// Show control
			if( !value ){
				_useVolumeSlider = false;
				volumeSlider.visible = false;
			}
			volumeButton.visible = value;
		}
		
		public function get useVolumeButton():Boolean
		{
			return _useVolumeButton;
		}
		
		//----------------
		// useVolumeSlider
		
		/**
		 * Set to true to show the volume slider or false to hide it. 
		 * If set to false, the volume button becomes a mute toggle button.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set useVolumeSlider( value:Boolean ):void
		{
			_useVolumeSlider = value;
			
			// Show control
			volumeButton.toggle = !value;
			volumeButton.useDownState = value;
		}
		
		public function get useVolumeSlider():Boolean
		{
			return _useVolumeSlider;
		}
	}
}