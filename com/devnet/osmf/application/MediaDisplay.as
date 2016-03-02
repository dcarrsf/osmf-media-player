/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011.
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.devnet.osmf.application
{
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutRenderer;
	import org.osmf.layout.LayoutRendererBase;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	import org.osmf.metadata.TimelineMarker;
	import org.osmf.metadata.TimelineMetadata;
	
	import com.devnet.osmf.application.Configuration;
	import com.devnet.osmf.events.CuePointEvent;
	import com.devnet.osmf.events.MediaEvent;
	import com.devnet.osmf.events.ProgressEvent;
	
	//*********************************
	// Event Metadata:
	
	[Event(name="autoRewind", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="bufferingStateEntered", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="close", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="complete", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="configError", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="configLoaded", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="durationChange", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="pausedStateEntered", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="playbackError", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="playheadUpdate", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="playingStateEntered", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="ready", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="seeked", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="stateChange", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="stoppedStateEntered", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="volumeChanged", type="com.dancarrdesign.osmf.events.MediaEvent")]
	[Event(name="cuePoint", type="com.dancarrdesign.osmf.events.CuePointEvent")]
	[Event(name="mediaProgress", type="com.dancarrdesign.osmf.events.ProgressEvent")]
	[Event(name="mediaError", type="org.osmf.events.MediaErrorEvent")]
	[Event(name="pluginLoad", type="org.osmf.events.MediaFactoryEvent")]
	[Event(name="pluginLoadError", type="org.osmf.events.MediaFactoryEvent")]
	[Event(name="mediaElementCreate", type="org.osmf.events.MediaFactoryEvent")]
	[Event(name="mediaPlayerStateChange", type="org.osmf.events.MediaPlayerStateChangeEvent")]
			
	/**********************************
	 * The MediaDisplay class instantiates the OSMF objects necessary
	 * to create a media player and wraps them in a component similar 
	 * to the Flash FLVPlayback component. Use the MediaDisplay as a standalone 
	 * media display area or combine it with the ControlBar component to add user 
	 * interface controls.
	 * 
	 * <p><b>Example:</b> This example shows how to configure a MediaDisplay instance as a standalone player.
	 * <listing>
	
	import com.dancarrdesign.osmf.application.MediaDisplay;
	import com.dancarrdesign.osmf.events.CuePointEvent;
			
	// Create player.
	var mediaDisplay:MediaDisplay = new MediaDisplay();
	mediaDisplay.autoPlay = true;
	mediaDisplay.loop = true;
	mediaDisplay.addASCuePoint(0, "Cuepoint at 0 seconds");
	mediaDisplay.addASCuePoint(4, "Cuepoint at 4 seconds");
	mediaDisplay.addASCuePoint(8, "Cuepoint at 8 seconds");
	mediaDisplay.addEventListener(CuePointEvent.CUE_POINT, onCuePoint);
	mediaDisplay.setSize(768, 428);
	mediaDisplay.source = "http://mediapm.edgesuite.net/osmf/content/test/manifest-files/dynamic_Streaming.f4m";
	addChild(mediaDisplay);
			
	// Respond to cue point events.
	function onCuePoint( event:CuePointEvent ):void
	{
		trace(event.name + ", time = " + event.time);
	}
	 * </listing></p>
	 * 
	 * @see Configuration
	 * @see ControlBar
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class MediaDisplay extends Sprite
	{
		//*****************************
		// Constants:
		
		public static const ALIGN_LEFT:String = "left";
		public static const ALIGN_CENTER:String = "center";
		public static const ALIGN_RIGHT:String = "right";
		public static const ALIGN_TOP:String = "top";
		public static const ALIGN_MIDDLE:String = "middle";
		public static const ALIGN_BOTTOM:String = "bottom";
		
		public static const CAPABILITY_BUFFER:String = "buffer";
		public static const CAPABILITY_LOAD:String = "load";
		public static const CAPABILITY_PAUSE:String = "pause";
		public static const CAPABILITY_PLAY:String = "play";
		public static const CAPABILITY_SEEK:String = "seek";
		
		public static const FEATURE_AUDIO:String = "audio";
		public static const FEATURE_DRM:String = "drm";
		public static const FEATURE_DVR:String = "dvr";
		public static const FEATURE_DYNAMIC_STREAM:String = "dynamicStream";
		
		public static const SCALEMODE_NONE:String = "none";
		public static const SCALEMODE_LETTERBOX:String = "letterbox";
		public static const SCALEMODE_STRETCH:String = "stretch";
		public static const SCALEMODE_ZOOM:String = "zoom";
		
		//*****************************
		// Properties:
		
		private var _autoPlay:Boolean = true;
		private var _autoRewind:Boolean = true;
		private var _backgroundAlpha:Number = 1;
		private var _backgroundColor:uint = 0x000000;
		private var _bufferTime:Number = 0.1;
		private var _clipChildren:Boolean = false;
		private var _configFile:String;// = "config.xml";
		private var _cuePoints:Array = new Array();
		private var _cuePointsLoaded:Boolean = false;
		private var _deferredCuePoints:Array = new Array();
		private var _dynamicTimelineMetadata:TimelineMetadata;
		private var _embeddedTimelineMetadata:TimelineMetadata;
		private var _horizontalAlign:String = MediaDisplay.ALIGN_CENTER;
		private var _ignoreDynamicCuePoints:Boolean = false;
		private var _layoutMetadata:LayoutMetadata = new LayoutMetadata();
		private var _loop:Boolean = true;
		private var _playheadTime:Number = 0;
		private var _scaleMode:String = MediaDisplay.SCALEMODE_LETTERBOX;
		private var _source:String;
		private var _state:String;
		private var _verticalAlign:String = MediaDisplay.ALIGN_MIDDLE;
		private var _volume:Number = 1;
		
		// Size
		private var _prefWidth:Number;
		private var _prefHeight:Number;
		
		// OSMF
		private var _container:MediaContainer;
		private var _factory:DefaultMediaFactory;
		private var _media:*;
		private var _player:MediaPlayer;
		private var _renderer:LayoutRendererBase;
			
		// XML Parser
		private var _configuration:Configuration;
		
		// Stage assets
		private var _mask:Sprite;
		public var boundingBox:Sprite;
		
		//*****************************
		// Constructor:
		
		public function MediaDisplay():void
		{
			//------------------
			// Measure layout:
			
			_prefWidth = width;
			_prefHeight = height;
			
			// Reset scale
			scaleX = 1;
			scaleY = 1;
			
			// Resize the bounding box
			boundingBox.alpha = 0;
			boundingBox.width = _prefWidth;
			boundingBox.height = _prefHeight;
			
			//------------------
			// Create OSMF objects:
			
			_factory = new DefaultMediaFactory();
			_player = new MediaPlayer();
			_renderer = new LayoutRenderer();
			_container = new MediaContainer(_renderer);
			
			// Setup events
			_factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginError);
			_factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
			
			// Setup mask
			_mask = new Sprite();
			_mask.graphics.beginFill(0);
			_mask.graphics.drawRect(0, 0, _prefWidth, _prefHeight);
			_mask.graphics.endFill();
			addChild(_mask);
		
			// Container layout
			_container.mask = _mask;
			_container.clipChildren = _clipChildren;
			_container.backgroundAlpha = _backgroundAlpha;
			_container.backgroundColor = _backgroundColor;
			
			// Setup player
			_player.autoPlay = _autoPlay;
			_player.autoRewind = _autoRewind;
			_player.bufferTime = _bufferTime;
			_player.currentTimeUpdateInterval = 25;
			_player.loop = _loop;
			_player.volume = _volume;
			_player.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, onProgressChange);
			_player.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			_player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE, onCapabilityChange);
			_player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE, onCapabilityChange);
			_player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onCapabilityChange);
			_player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, onCapabilityChange);
			_player.addEventListener(MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE, onCapabilityChange);
			_player.addEventListener(MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE, onCapabilityChange);
			_player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange);
			_player.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekChange);
			_player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onPlaybackChange);
			_player.addEventListener(TimeEvent.COMPLETE, onPlaybackChange);
			_player.addEventListener(TimeEvent.DURATION_CHANGE, onPlaybackChange);
			
			// Config data
			_configuration = new Configuration(_factory);
			_configuration.addEventListener(Event.COMPLETE, onConfigLoaded);
			_configuration.addEventListener(IOErrorEvent.IO_ERROR, onConfigError);
			
			// Load XML
			if( _configFile && !_source ){
				setConfigFile(_configFile);
			}
			// Add view container to Stage.
			addChild(_container);
			
			// Update size...
			setSize(_prefWidth, _prefHeight);
		}
		
		//*****************************
		// Events:
		
		protected function onCapabilityChange( event:MediaPlayerCapabilityChangeEvent ):void
		{
			// Relay event
			dispatchEvent(event.clone());
		}
		
		protected function onConfigLoaded( event:Event ):void
		{
			// Configure and load the media list...
			setMedia( _configuration.getPlaylist() );
		
			// Relay event
			dispatchEvent(new MediaEvent(MediaEvent.CONFIG_LOADED));
		}
		
		protected function onConfigError( event:IOErrorEvent ):void
		{
			// TODO: Show status on fail...
			
			// Relay event
			dispatchEvent(new MediaEvent(MediaEvent.CONFIG_ERROR));
		}
		
		protected function onCuePoint( event:TimelineMetadataEvent ):void
		{
			var cuePoint:CuePoint = event.marker as CuePoint;
				
		//	trace("cuePoint.time="+cuePoint.time+", name ="+cuePoint.name);
								
			// If we are getting embedded cue points, let's ignore the dynamic cue points coming from
			// the framework, these are being dispatched from the list of cue points found in the 
			// metadata for the file.
			if( event.target == _embeddedTimelineMetadata ){
				_ignoreDynamicCuePoints = true;
			}
			if( _ignoreDynamicCuePoints && event.target == _dynamicTimelineMetadata ){
				return;
			}
			// Relay event
			dispatchEvent(new CuePointEvent(CuePointEvent.CUE_POINT, false, false, cuePoint.name, cuePoint.time, cuePoint.type, cuePoint.parameters));
		}
		
		protected function onCuePointAdd( event:TimelineMetadataEvent ):void
		{
			updateCuePoints( event.marker as CuePoint );
		}
		
		protected function onPlaybackChange( event:TimeEvent ):void
		{
			switch( event.type )
			{
				case TimeEvent.COMPLETE:
					
					// Relay event
					dispatchEvent(new MediaEvent(MediaEvent.COMPLETE));
					break;
					
				case TimeEvent.CURRENT_TIME_CHANGE:
				
					var currentTime:Number = event.time;
					if( currentTime == 0 && _playheadTime > 0 )
					{
						// Relay event
						dispatchEvent(new MediaEvent(MediaEvent.AUTO_REWOUND));
					}
					// Cache value...
					_playheadTime = event.time;
					
					// Relay event
					dispatchEvent(new MediaEvent(MediaEvent.PLAYHEAD_UPDATE));
					break;
					
				case TimeEvent.DURATION_CHANGE:
					
					// Relay event
					dispatchEvent(new MediaEvent(MediaEvent.DURATION_CHANGED));
					break;
			}
		}
		
		protected function onMediaError( event:MediaErrorEvent ):void
		{
			// Relay event
			dispatchEvent(event.clone());
		}
			
		protected function onMetadataAdd( event:MediaElementEvent ):void
		{
			_cuePointsLoaded = true;
			
			if( player.media ){
			//	setCuePointsOnMedia(event.target as MediaElement, (event.namespaceURL == CuePoint.EMBEDDED_CUEPOINTS_NAMESPACE));
			}
		}
		
		protected function onPluginError( event:MediaFactoryEvent ):void
		{
			// Relay event
			dispatchEvent(event.clone());
		}
		
		protected function onPluginLoaded( event:MediaFactoryEvent ):void
		{
			// Relay event
			dispatchEvent(event.clone());
		}
		
		protected function onProgressChange( event:LoadEvent ):void
		{
			// Relay event
			dispatchEvent(new ProgressEvent(ProgressEvent.MEDIA_PROGRESS, false, false, _player.bytesLoaded, _player.bytesTotal));
		}
		
		protected function onSeekChange( event:SeekEvent ):void
		{
			// Relay event
			dispatchEvent(new MediaEvent(MediaEvent.SEEKED));
		}
		
		protected function onStateChange( event:MediaPlayerStateChangeEvent ):void
		{
			_state = event.state;
			
			switch( event.state )
			{
				case MediaPlayerState.BUFFERING:
				
					// Relay event
					dispatchEvent(new MediaEvent(MediaEvent.BUFFERING_STATE_ENTERED));
					break;
					
				case MediaPlayerState.PLAYBACK_ERROR:
				
					// Relay event
					dispatchEvent(new MediaEvent(MediaEvent.PLAYBACK_ERROR));
					break;
					
				case MediaPlayerState.PLAYING:
				
					// Relay event
					dispatchEvent(new MediaEvent(MediaEvent.PLAYING_STATE_ENTERED));
					break;
					
				case MediaPlayerState.PAUSED:
				
					// Relay event
					dispatchEvent(new MediaEvent(MediaEvent.PAUSED_STATE_ENTERED));
					break;
					
				case MediaPlayerState.READY:
					
					// Relay event
					dispatchEvent(new MediaEvent(MediaEvent.READY));
					break;
			}
			// Relay event
			dispatchEvent(new MediaEvent(MediaEvent.STATE_CHANGE));
		}
		
		//*****************************
		// Methods:
		
		//---------------
		// internal
		
		/**
		 * Loads the configuration XML file and settings.
		 * 
		 * @param	fileUrl		URL of XML config file.
		 */
		private function setConfigFile( fileUrl:String ):void
		{
			if( fileUrl ){
				_configFile = fileUrl;
				_configuration.load(fileUrl);
			}
		}
		
		/**
		 * Builds cue points list from ActionScript cue points.
		 * Used by the component parameters or runtime scripting.
		 * 
		 * @param	a	List of cue point objects to add.
		 */
		private function setCuePoints(a:Array):void
		{
			var len:uint = a.length;
			
			// Adjust for parameters built with Components Inspector
			if( a[0] == "t" ) 
			{
				var markers:Array = parseParameterCuePoints(a);
				len = markers.length;
				
				for(var i:uint = 0; i < len; i++) {
					addASCuePoint(markers[i].time, markers[i].name, markers[i].parameters);
				}
			}
			// Or use a preformatted array (AS3 or FlashVars)...
			else{
				for(var j:uint = 0; j < len; j++) {
					addASCuePoint(a[j].time, a[j].name, a[j].parameters);
				}
			}
		}
		
		/**
		 * The Cue Points component parameter value returned
		 * from the Properties panel in Flash professional uses
		 * the format of a linear array to represent any number 
		 * of cue points. This function parses the array based
		 * on a known pattern.
		 * 
		 * @param	a	The Cue Point component parameter to parse.
		 * @return		Returns a formatted array of cue point objects.
		 */
		private function parseParameterCuePoints( a:Array ):Array
		{
			var markers:Array = new Array();
			var markerProps:Array = new Array();
			var markerPropsIndex:int = -1;
			var len:uint = a.length;
			
			for(var i:uint = 0; i < len; i++) 
			{
				if( a[i] == "t" && a[i + 2] == "n" ) {
					markerPropsIndex++;
				}
				if( markerProps[markerPropsIndex] == null ) {
					markerProps[markerPropsIndex] = new Array();
				}
				markerProps[markerPropsIndex].push(a[i]);
			}
			len = markerProps.length;
				
			for(var j:uint = 0; j < len; j++) 
			{
				var cp:Object = new Object();
				cp.name = markerProps[j][3];
				cp.time =  Number(markerProps[j][1]) / 1000;
				cp.parameters = getParameters(markerProps[j].slice(10));
				markers.push(cp);
			}
			return markers;
		}
		
		/**
		 * Retrieves name value pairs from the end of the
		 * cue point array.
		 * 
		 * @param	a	The cue point array to parse.
		 * @return		Returns an object containing the name value pairs.
		 */
		private function getParameters( a:Array ):Object
		{
			var o:Object;
			var varName:String;
			var varValue:String;
			var nameVal:uint = 0;
			var len:uint = a.length;
			
			for(var i:uint = 0; i < len; i++) 
			{ 
				if( o == null ) {
					o = new Object();
				}
				if( nameVal == 0 ) {
					nameVal = 1;
					varName = a[i];
				}else{
					nameVal = 0;
					o[varName] = a[i];
				}
			}
			return o;
		}
		
		/**
		 * Adds cue points to a media element and sets up listeners for cue point events.
		 * 
		 * @param	mediaElement		Media element to associate the cue points with.
		 * @param	isEmbeddedMetadata	Flags indicating if the cue points are embedded or runtime.
		 */
		private function setCuePointsOnMedia( mediaElement:MediaElement, isEmbeddedMetadata:Boolean ):void
		{
			var timelineMetadata:TimelineMetadata = null;
			if( isEmbeddedMetadata ){
				_embeddedTimelineMetadata = mediaElement.getMetadata(CuePoint.EMBEDDED_CUEPOINTS_NAMESPACE) as TimelineMetadata;
				timelineMetadata = _embeddedTimelineMetadata;
			}else{
				if( _dynamicTimelineMetadata == null ){
					_dynamicTimelineMetadata = mediaElement.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
				}
				// Load deferred ActionScript cue points
				while( _deferredCuePoints.length > 0 )
				{
					var cp:CuePoint = _deferredCuePoints.shift();
					addASCuePoint(cp.time, cp.name, cp.parameters);
				}
				timelineMetadata = _dynamicTimelineMetadata;
			}
			if( timelineMetadata ){
				timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
				timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_ADD, onCuePointAdd);

				// Show all the cue points found in the media.
				var len:uint = timelineMetadata.numMarkers;
				for(var i:int = 0; i < len; i++)
				{
					_cuePoints.push(timelineMetadata.getMarkerAt(i));
				}
			}
		}
				
		/**
		 * Updates the internal list of cue point objects.
		 * 
		 * @param	newCuePoint		Cue point to evaluate.
		 */
		private function updateCuePoints( newCuePoint:CuePoint ):void
		{
			// See if there is an existing value, if so replace it
			var len:uint = _cuePoints.length;
			for(var i:int = 0; i < len; i++)
			{
				if( _cuePoints[i].time == newCuePoint.time){
					_cuePoints.splice(i, 1);
					break;
				}
			}
			_cuePoints.push(newCuePoint);
		}
		
		//---------------
		// public
		
		/**
		 * Adds an ActionScript cue point marker to the media.
		 * 
		 * @param	time		Time at which the cue point occurs
		 * @param	name		Name of the cue point.
		 * @param	parameters	Parameters (name/value pairs) to associate with the cue point.
		 */
		public function addASCuePoint( time:Number, name:String, parameters:Object=null ):void
		{
			var cuePoint:CuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, time, name, parameters);
			
			if( player.media )
			{
				// Add marker to metadata
				if( _dynamicTimelineMetadata == null ){
					_dynamicTimelineMetadata = new TimelineMetadata(player.media);
					player.media.addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, _dynamicTimelineMetadata);
				}
				_dynamicTimelineMetadata.addMarker(cuePoint);
				
				// Update cache...
				updateCuePoints(cuePoint);
			}
			else{
				_deferredCuePoints.push(cuePoint);
			}
		}
		
		/**
		 * Returns true if the media player currently supports a capability.
		 * 
		 * @param	value	The capability to evaluate.
		 * @return
		 */
		public function can( value:String ):Boolean
		{
			switch( value )
			{
				case CAPABILITY_BUFFER:
					return _player.canBuffer;
				case CAPABILITY_LOAD:
					return _player.canLoad;
				case CAPABILITY_PAUSE:
					return _player.canPause;
				case CAPABILITY_PLAY:
					return _player.canPlay;
				case CAPABILITY_SEEK:
					return _player.canSeek;
			}
			return false;
		}
		
		/**
		 * Returns true if the media can seek to a specified time.
		 * 
		 * @param	time	Time to evaluate against.
		 * @return
		 */
		public function canSeekTo( time:Number ):Boolean
		{
			return _player.canSeekTo(time);
		}
		
		/**
		 * Searches for a cue point at a specified time.
		 * 
		 * @param	time	Time in seconds to evaluate.
		 * @param	type	Type of cue point to search for.
		 * @return			Returns the cue point object if the match exists.
		 */
		public function findCuePoint( time:Number, type:String=null ):Object
		{
			var marker:CuePoint;
			var len:uint;
			
			if( type == CuePointType.NAVIGATION || type == null )
			{
				len = _embeddedTimelineMetadata.numMarkers;
				for(var n:uint = 0; n < len; n++ ) 
				{
					marker = _embeddedTimelineMetadata.getMarkerAt(n) as CuePoint;
					
					if( marker.time == time )
					{
						return marker;
					}
				}
			}
			if( type == CuePointType.EVENT || type == null )
			{
				len = _embeddedTimelineMetadata.numMarkers;
				for(var j:uint = 0; j < len; j++ ) 
				{
					marker = _embeddedTimelineMetadata.getMarkerAt(j) as CuePoint;
					
					if( marker.time == time )
					{
						return marker;
					}
				}
			}
			if( type == CuePointType.ACTIONSCRIPT || type == null )
			{
				len = _dynamicTimelineMetadata.numMarkers;
				for (var i:uint = 0; i < len; i++ ) 
				{
					marker = _dynamicTimelineMetadata.getMarkerAt(i) as CuePoint;
					
					if( marker.time == time )
					{
						return marker;
					}
				}
			}
			return null;
		}
		
		/**
		 * Finds the nearest cue point to a specific time.
		 * 
		 * @param	time	Time to evaluate against.
		 * @param	type	Type of cue point to match.
		 * @return			Returns the cue point object if a match exists.
		 */
		public function findNearestCuePoint( time:Number, type:String=null ):Object
		{
			var marker1:CuePoint;
			var marker2:CuePoint;
			var len:uint;
			
			if( type == CuePointType.NAVIGATION || type == null )
			{
				len = _embeddedTimelineMetadata.numMarkers;
				for(var n:uint = 0; n < len; n++ ) 
				{
					if( i < len - 2 )
					{
						marker1 = _embeddedTimelineMetadata.getMarkerAt(i) as CuePoint;
						marker2 = _embeddedTimelineMetadata.getMarkerAt(i + 1) as CuePoint;
						
						if( marker1.time < time && time < marker2.time )
						{
							return marker2;
						}
					}else{
						break;
					}
				}
			}
			if( type == CuePointType.EVENT || type == null )
			{
				len = _embeddedTimelineMetadata.numMarkers;
				for(var j:uint = 0; j < len; j++ ) 
				{
					if( i < len - 2 )
					{
						marker1 = _embeddedTimelineMetadata.getMarkerAt(i) as CuePoint;
						marker2 = _embeddedTimelineMetadata.getMarkerAt(i + 1) as CuePoint;
						
						if( marker1.time < time && time < marker2.time )
						{
							return marker2;
						}
					}else{
						break;
					}
				}
			}
			if( type == CuePointType.ACTIONSCRIPT || type == null )
			{
				len = _dynamicTimelineMetadata.numMarkers;
				for(var i:uint = 0; i < len; i++ ) 
				{
					if( i < len - 2 )
					{
						marker1 = _dynamicTimelineMetadata.getMarkerAt(i) as CuePoint;
						marker2 = _dynamicTimelineMetadata.getMarkerAt(i + 1) as CuePoint;
						
						if( marker1.time < time && time < marker2.time )
						{
							return marker2;
						}
					}else{
						break;
					}
				}
			}
			return null;
		}
		
		/**
		 * Returns true if the media player currently supports a feature.
		 * 
		 * @param	value	Feature to evaluate.
		 * @return			Returns true if feature is supported.
		 */
		public function has( value:String ):Boolean
		{
			switch( value )
			{
				case FEATURE_AUDIO:
					return _player.hasAudio;
				case FEATURE_DRM:
					return _player.hasDRM;
				case FEATURE_DVR:
					return _player.isDVRRecording;
				case FEATURE_DYNAMIC_STREAM:
					return _player.isDynamicStream;
			}
			return false;
		}
		
		/**
		 * Loads media source from a URL.
		 * 
		 * @param	src			URL of media.
		 * @param	duration	Total time of media (currently ignored - used for compatibility with FLVPlayback code).
		 * @param	isLive		Defines whether the media is live video streaming from a Flash Media Server (currently ignored).
		 */
		public function load( src:String, duration:Number=NaN, isLive:Boolean=false ):void
		{
			source = src;
		}
		
		/**
		 * Loads a plugin from a resource URL.
		 * 
		 * @param	resource	The URL resource as a String.
		 */
		public function loadPlugin( resource:String ):void
		{
			_factory.loadPlugin(new URLResource(resource));
		}
		
		/**
		 * Pauses the media file.
		 */
		public function pause():void
		{
			if( can(CAPABILITY_PAUSE) ){
				_player.pause();
			}
		}
		
		/**
		 * Plays the media file.
		 */
		public function play():void
		{
			if( can(CAPABILITY_PLAY) ){
				_player.play();
			}
		}
		
		/**
		 * Removes an ActionScript cue point from the player.
		 * 
		 * @param	time	Time in seconds of the cuepoint to remove.
		 * @return			Returns the removed cue point object.
		 */
		public function removeASCuePoint( time:Number ):Object
		{
			return _dynamicTimelineMetadata.removeValue(time.toString());
		}
		
		/**
		 * Seeks to a timecode in the media.
		 * 
		 * @param	time	Number to seek to in seconds.
		 */
		public function seek( time:Number ):void
		{
			if ( can(CAPABILITY_SEEK) && canSeekTo( time ) ) {
				_player.seek(time);
			}
		}
		
		/**
		 * Set the media source in the player.
		 * 
		 * @param	value	Media element object.
		 * @param	layout	Layout metadata object.
		 */
		public function setMedia( value:MediaElement ):void
		{
			if( value != _media &&
				value != null )
			{
				if( _media ) {
					_media.removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
					_media.removeMetadata(LayoutMetadata.LAYOUT_NAMESPACE);
					
					// Remove the current media
					container.removeMediaElement(_media);
				}
				_cuePointsLoaded = false;
				_media = value;
				
				// Set the new media element
				player.media = value;
				
				// Size media (you can override this by using the layout parameter or config.xml parameters)
				_layoutMetadata = new LayoutMetadata();
				_layoutMetadata.width = _prefWidth;
				_layoutMetadata.height = _prefHeight;
				_layoutMetadata.scaleMode = _scaleMode;
				_layoutMetadata.horizontalAlign = _horizontalAlign;
				_layoutMetadata.verticalAlign = _verticalAlign;
				_layoutMetadata.includeInLayout = true;
				
				// Metadata
				_media.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, _layoutMetadata);
				_media.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
						
				// Add the media to the container
				container.addMediaElement(_media);
				
				// Handle embedded cue points
				_embeddedTimelineMetadata = _media.getMetadata(CuePoint.EMBEDDED_CUEPOINTS_NAMESPACE) as TimelineMetadata;
				
				if( _embeddedTimelineMetadata ){
					setCuePointsOnMedia(_media, true);
				}
				// Handle dynamic cue points
				_dynamicTimelineMetadata = _media.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
				
				if( _dynamicTimelineMetadata == null ){
					setCuePointsOnMedia(_media, false);
				}
			}
		}
		
		/**
		 * Sets the size of the media display area.
		 * 
		 * @param	w	Number representing the new width.
		 * @param	h	Number representing the new height.
		 */
		public function setSize( w:Number, h:Number ):void
		{
			_prefWidth = w;
			_prefHeight = h;
			
			_layoutMetadata.width = _prefWidth;
			_layoutMetadata.height = _prefHeight;
			_mask.width = _prefWidth;
			_mask.height = _prefHeight;
			
			container.width = _prefWidth;
			container.height = _prefHeight;
			boundingBox.width = _prefWidth;
			boundingBox.height = _prefHeight;
		}
		
		// Don't resize the wrapper sprite!
		override public function set width(value:Number):void 
		{
			//super.width = value; 
			setSize(value, _prefHeight);
		}
		
		// Don't resize the wrapper sprite!
		override public function set height(value:Number):void 
		{
			//super.width = value; 
			setSize(_prefWidth, value);
		}
		
		/**
		 * Stops the media from playing.
		 */
		public function stop():void
		{
			_player.stop();
		}
		
		//*****************************
		// Getter/Setters:
		
		//----------------
		// autoPlay
		
		/**
		 * Sets the media to auto play when ready.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set autoPlay( value:Boolean ):void
		{
			_autoPlay = value;
			_player.autoPlay = value;
		}
		
		public function get autoPlay():Boolean
		{
			return _player.autoPlay;
		}
		
		//----------------
		// autoRewind
		
		/**
		 * Sets the media to rewind to the beginning upon completion.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set autoRewind( value:Boolean ):void
		{
			_autoRewind = value;
			_player.autoRewind = value;
		}
		
		public function get autoRewind():Boolean
		{
			return _player.autoRewind;
		}
		
		//----------------
		// backgroundAlpha
		
		/**
		 * Sets the background alpha of the OSMF container.
		 */
		[Inspectable(defaultValue=1,type="Number")]
		public function set backgroundAlpha( value:Number ):void
		{
			_backgroundAlpha = value;
			_container.backgroundAlpha = value;
		}
		
		public function get backgroundAlpha():Number
		{
			return _container.backgroundAlpha;
		}
		
		//----------------
		// backgroundColor
		
		/**
		 * Sets the background color of the OSMF container.
		 */
		[Inspectable(defaultValue=0x000000,type="Color")]
		public function set backgroundColor( value:Number ):void
		{
			_backgroundColor = value;
			_container.backgroundColor = value;
		}
		
		public function get backgroundColor():Number
		{
			return _container.backgroundColor;
		}
		
		//----------------
		// bufferTime
		
		/**
		 * Sets the buffer time for the media.
		 */
		[Inspectable(defaultValue=0.1,type="Number")]
		public function set bufferTime( value:Number ):void
		{
			_bufferTime = value;
			_player.bufferTime = value;
		}
		
		public function get bufferTime():Number
		{
			return _player.bufferTime;
		}
		
		//----------------
		// clipChildren
		
		/**
		 * Sets the clipChildren property of the OSMF container.
		 */
		public function set clipChildren( value:Boolean ):void
		{
			_clipChildren = value;
			_container.clipChildren = value;
		}
		
		public function get clipChildren():Boolean
		{
			return _container.clipChildren;
		}
		
		//----------------
		// configFile
		
		/**
		 * Sets the URL of the configuration file containing OSMF
		 * media playlist information written in custom XML markup. Note
		 * that this property is ignored if the source property is set.
		 */
		[Inspectable(defaultValue="",type="String")]
		public function set configFile( value:String ):void
		{
			setConfigFile(value);
		}
		
		public function get configFile():String
		{
			return _configFile;
		}
		
		//----------------
		// cuePoints
		
		/**
		 * An array of cue point objects each containing a name, time,
		 * and parameters property.
		 */
		public function set cuePoints( value:Array ):void
		{
			setCuePoints(value);
		}
		
		[Inspectable(type="Video Cue Points")]
		public function get cuePoints():Array
		{
			return _cuePoints;
		}
		
		//----------------
		// horizontalAlign
		
		/**
		 * The horizontal alignment of the media in the OSMF container (left, center, right).
		 */
		[Inspectable(defaultValue="center",type="List",enumeration="left,center,right")]
		public function set horizontalAlign( value:String ):void
		{
			_horizontalAlign = value;
		}
		
		public function get horizontalAlign():String
		{
			return _horizontalAlign;
		}
		
		//----------------
		// loop
		
		/**
		 * Sets the media to loop upon completion.
		 */
		[Inspectable(defaultValue=true,type="Boolean")]
		public function set loop( value:Boolean ):void
		{
			_loop = value;
			_player.loop = value;
		}
		
		public function get loop():Boolean
		{
			return _player.loop;
		}
		
		//----------------
		// scaleMode
		
		/**
		 * Defines how the media will within the OSMF container area (none, letterbox, stretch, zoom).
		 */
		[Inspectable(defaultValue="stretch",type="List",enumeration="none,letterbox,stretch,zoom")]
		public function set scaleMode( value:String ):void
		{
			_scaleMode = value;
		}
		
		public function get scaleMode():String
		{
			return _scaleMode;
		}
		
		//----------------
		// source
		
		/**
		 * Sets the source URL for the media and overrides the configFile property.
		 */
		[Inspectable(defaultValue="",type="String")]
		public function set source( value:String ):void
		{
			_source = value;
			
			// Use factory to load media...
			setMedia( factory.createMediaElement(new URLResource(value)) );
		}
		
		public function get source():String
		{
			return _source;
		}
		
		//----------------
		// verticalAlign
		
		/**
		 * The vertical alignment of the media in the OSMF container (top, middle, bottom).
		 */
		[Inspectable(defaultValue="middle",type="List",enumeration="top,middle,bottom")]
		public function set verticalAlign( value:String ):void
		{
			_verticalAlign = value;
		}
		
		public function get verticalAlign():String
		{
			return _verticalAlign;
		}
		
		//----------------
		// volume
		
		/**
		 * Sets the volume of the media (0-1).
		 */
		[Inspectable(defaultValue=1,type="Number")]
		public function set volume( value:Number ):void
		{
			_volume = value;
			_player.volume = value;
		}
		
		public function get volume():Number
		{
			return _player.volume;
		}
		
		//----------------
		// read-only:
		
		/**
		 * True if the media is buffering.
		 */
		public function get buffering():Boolean
		{
			return _player.buffering;
		}
		
		/**
		 * Length of the media buffer.
		 */
		public function get bufferLength():Number
		{
			return _player.bufferLength;
		}
		
		/**
		 * Number of bytes loaded for the current media.
		 */
		public function get bytesLoaded():uint
		{
			return _player.bytesLoaded;
		}
		
		/**
		 * Number of bytes total for the current media.
		 */
		public function get bytesTotal():uint
		{
			return _player.bytesTotal;
		}
		
		/**
		 * True if cue points have been initialized for the current media.
		 */
		public function get cuePointsLoaded():Boolean
		{
			return _cuePointsLoaded;
		}
		
		/**
		 * True if the media is paused.
		 */
		public function get paused():Boolean
		{
			return _player.paused;
		}
		
		/**
		 * The playhead time of the current media.
		 */
		public function get playheadTime():Number
		{
			return _player.currentTime;
		}
		
		/**
		 * True if the media is playing.
		 */
		public function get playing():Boolean
		{
			return _player.playing;
		}
		
		/**
		 * The state of the current media.
		 */
		public function get state():String
		{
			return _state;
		}
		
		/**
		 * The total time duration of the current media.
		 */
		public function get totalTime():Number
		{
			return _player.duration;
		}
		
		//---------------
		// OSMF access:
		
		/**
		 * Reference to the Configuration object.
		 */
		public function get configuration():Configuration
		{
			return _configuration;
		}
		
		/**
		 * Reference to the OSMF MediaContainer object.
		 */
		public function get container():MediaContainer
		{
			return _container;
		}
		
		/**
		 * Reference to the OSMF MediaFactory object.
		 */
		public function get factory():MediaFactory
		{
			return _factory;
		}
		
		/**
		 * Reference to the current OSMF MediaElement object.
		 */
		public function get media():MediaElement
		{
			return _media;
		}
		
		/**
		 * Reference to the OSMF MediaPlayer object.
		 */
		public function get player():MediaPlayer
		{
			return _player;
		}
	}
}