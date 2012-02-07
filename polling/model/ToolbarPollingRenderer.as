package org.bigbluebutton.modules.polling.model
{
   import mx.controls.menuClasses.MenuItemRenderer;
   import org.bigbluebutton.modules.polling.model.ValueObject;
	
   [Bindable]
   public class ToolbarPollingRenderer extends MenuItemRenderer {
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
    	  // Get the style name from Menu VO and set to the menu item	
    	  // Replace this with Poll Objects maybe? Another object that encapsulates a poll object and displays the title? I dunno.
    	  super.updateDisplayList(unscaledWidth, unscaledHeight);
      }
   }
}