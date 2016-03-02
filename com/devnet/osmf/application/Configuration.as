/**************************************
 * Developed for the Adobe Flash Developer Center.
 * Written by Dan Carr (dan@dancarrdesign.com), 2011
 * 
 * Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
 * http://creativecommons.org/licenses/by-sa/3.0/
 */
package com.devnet.osmf.application
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutMode;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.URLResource;
	
	//*********************************
	// Event Metadata:
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	/**********************************
	 * The Configuration class loads and parses the configuration XML file. Use this class
	 * to convert XML markup to OSMF element objects at runtime. You can load the XML markup
	 * from an external source, or create the XML in ActionScript.
	 * 
	 * <p>
	 * <b>Example:</b> This example shows the custom markup format the Configuration class uses.
	 * <listing>
	
	&lt;media_playlist &gt;
		&lt;media layout="serial" width="768" height="428">
			&lt;source&gt;http://mediapm.edgesuite.net/osmf/content/test/manifest-files/dynamic_Streaming.f4m &lt;/source&gt;
		&lt;/media&gt;
	&lt;/media_playlist&gt;
	 * </listing>
	 * Notice that a root node holds a media node which can contain serial or parallel lists of content.
	 * The root media node can contain nested media nodes or source nodes containing media URLs. </p>
	 * <p>
	 * Each media node must include one of the following layout attribute values: <i>serial or parallel.</i></p>
	 * <p>
	 * Each media node can optionally include the following attributes: <i>duration, width, height, x, y, scaleMode, horizontalAlign, verticalAlign</i>.
	 * </p>
	 * 
	 * @see MediaDisplay
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0.0
	 */
	public class Configuration extends EventDispatcher
	{
		//*****************************
		// Properties:
		
		private var _config:XML;
		private var _configLoader:URLLoader;
		private var _configURL:String;
		private var _mediaFactory:DefaultMediaFactory;
		
		//*****************************
		// Constructor:
		
		/**
		 * Pass a reference to the DefaultMediaFactory while
		 * instantiating the Configuration class to allow for
		 * media level element configuration.
		 * 
		 * @param	factory		The DefaultMediaFactory used by the MediaDisplay class.
		 */
		public function Configuration( factory:DefaultMediaFactory ):void
		{
			_mediaFactory = factory;
			
			// Create loader
			_configLoader = new URLLoader();
			_configLoader.addEventListener(Event.COMPLETE, onConfigLoaded);
			_configLoader.addEventListener(IOErrorEvent.IO_ERROR, onConfigError);
		}
		
		//*****************************
		// Events:
		
		protected function onConfigError( event:IOErrorEvent ):void
		{
			// Relay event
			dispatchEvent(event.clone());
		}
		
		protected function onConfigLoaded( event:Event ):void
		{
			_config = new XML(_configLoader.data);
			
			// Relay event
			dispatchEvent(new Event("complete"));
		}
		
		//*****************************
		// Methods:
		
		/**
		 * Returns the root element of the config markup formatted as an OSMF element object. Call
		 * this method without parameters to retrieve the configuration loaded from an external source, 
		 * or pass in XML markup created at runtime.
		 * 
		 * @return 		Parallel or Serial element.
		 */
		public function getPlaylist( fromXML:XML=null ):*
		{
			if( fromXML && fromXML.media ) 
			{
				_config = fromXML;
				return getMediaElements(fromXML.media[0]);
			}
			return getMediaElements(_config.media[0]);
		}
		
		/**
		 * Loads a config file from an external source.
		 * 
		 * @param	configUrl	String representing the URL of the config XML file.
		 */
		public function load( configUrl:String ):void
		{
			_configURL = configUrl;
			_configLoader.load(new URLRequest(configUrl));
		}
		
		//-------------------
		// utils
		
		/**
		 * Parses and returns layout metadata from an XML node.
		 * 
		 * @param	elem	XML to parse for attributes.
		 * @return			Layout metadata resulting from the scan.
		 */
		private function getLayoutMetadata( elem:XML ):LayoutMetadata
		{
			var layoutData:LayoutMetadata = new LayoutMetadata();
			
			if( Number(elem.@width) > 0 ) {
				layoutData.width = Number(elem.@width);
			}
			if( Number(elem.@height) > 0 ) {
				layoutData.height = Number(elem.@height);
			}
			if( Number(elem.@x) > 0 ) {
				layoutData.x = Number(elem.@x);
			}
			if( Number(elem.@y) > 0 ) {
				layoutData.y = Number(elem.@y);
			}
			if( elem.@horizontalAlign == "left" ||
				elem.@horizontalAlign == "center" ||
				elem.@horizontalAlign == "right" ) {
				layoutData.horizontalAlign = elem.@horizontalAlign;
			}
			if( elem.@verticalAlign == "top" || 
				elem.@verticalAlign == "middle" || 
				elem.@verticalAlign == "bottom" ) {
				layoutData.verticalAlign = elem.@verticalAlign;
			}
			if( elem.@scaleMode == "none" || 
				elem.@scaleMode == "letterbox" || 
				elem.@scaleMode == "stretch" || 
				elem.@scaleMode == "zoom") {
				layoutData.scaleMode = elem.@scaleMode;
			}
			return layoutData;
		}
		
		/**
		 * Parses and returns Parallel or Serial elements from an XML node.
		 * 
		 * @param	elem		XML to parse for attributes.
		 * @return				Parallel or Serial element.
		 */
		private function getMediaElements( elem:XML ):*
		{
			var element:*; // either a SerialElement or a ParallelElement
			if( elem.@layout == "parallel" ) {
				element = new ParallelElement();
			}else{
				element = new SerialElement();
			}
			for each(var child:XML in elem.children())
			{
				if( child.name() == "media" ) {
					element.addChild( getMediaElements(child) );
				}else if( child.name() == "source" ) {
					element.addChild( getSource( child ) );
				}
			}
			if( hasLayoutAttr(elem) ){
				element.metadata.addValue( LayoutMetadata.LAYOUT_NAMESPACE,  getLayoutMetadata(elem) );
			}
			return element;
		}
		
		/**
		 * Parses and returns media level elements from an XML node.
		 * 
		 * @param	elem	XML to parse for attributes.
		 * @return			Duration element or media element determined by factory.
		 */
		private function getSource( elem:XML ):*
		{
			var element:*; // either a DurationElement or media type automatically returned form factory
			var elementDur:Number = Number(elem.@duration);
			if( elementDur > 0 ) {
				element = new DurationElement( elementDur, _mediaFactory.createMediaElement( new URLResource( elem.text() ) ) );
			}else{
				element = _mediaFactory.createMediaElement( new URLResource( elem.text() ));
			}
			if( hasLayoutAttr(elem) ){
				element.metadata.addValue( LayoutMetadata.LAYOUT_NAMESPACE,  getLayoutMetadata(elem) );
			}
			return element;
		}
		
		/**
		 * Checks for layout attributes.
		 * 
		 * @param	elem	XML to parse for attributes.
		 * @return			Returns true if layout metadata exists.
		 */
		private function hasLayoutAttr( elem:XML ):Boolean
		{
			if( Number(elem.@width) > 0 ) 
				return true;
			if( Number(elem.@height) > 0 ) 
				return true;
			if( Number(elem.@x) > 0 ) 
				return true;
			if( Number(elem.@y) > 0 ) 
				return true;
			if( elem.@horizontalAlign ) 
				return true;
			if( elem.@verticalAlign ) 
				return true;
			if( elem.@scaleMode ) 
				return true;
				
			return false;
		}
		
		//*************************
		// Getter/Setters:
		
		//----------------
		// playlistAsXML
		
		/**
		 * The playlist is the XML configuration markup
		 * loaded from ActionScript or an external resource.
		 */
		public function get playlistAsXML():XML
		{
			return _config;
		}
	}
}