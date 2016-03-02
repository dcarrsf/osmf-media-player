# osmf-media-player
The OSMF Media Player wraps the OSMF framework inside of a component for Flash Pro. 

The OSMF Media Player template is a Flash project comprised of a FLA file, an ActionScript code package, and a SWC library containing the Open Source Media Framework code. If desired, you can open the project in Adobe Flash Builder; however, Flash Builder and Flex Framework are not required to work with the files. 

This project was originally developed to support my video template articles on the Adobe Deverloper Connection. The original project is still available on the ADC at the links below. I'm posting them here as well so you can review and use the code.

**How to use the player:**

The MediaDisplay class instantiates the OSMF objects necessary to create a media player and wraps them in a component similar to the Flash FLVPlayback component. Use the MediaDisplay as a standalone media display area or combine it with the ControlBar component to add user interface controls.

Example: This example shows how to configure a MediaDisplay instance as a standalone player.

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
  
**Documentation:**

Check out the original article and ActionScript documentation at the links below. 

http://www.adobe.com/devnet/flash/articles/osmf-media-player.html
http://download.macromedia.com/pub/developer/osmf/OSMFComponents_ASDoc/index.html
