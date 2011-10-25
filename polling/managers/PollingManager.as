package org.bigbluebutton.modules.polling.managers
{
	import com.asfusion.mate.events.Dispatcher;
	
	import org.bigbluebutton.modules.polling.views.PollingInstructionsWindow;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.main.events.MadePresenterEvent;
	import org.bigbluebutton.common.events.OpenWindowEvent;
	import org.bigbluebutton.common.events.CloseWindowEvent;
	import org.bigbluebutton.common.IBbbModuleWindow;

    import org.bigbluebutton.modules.polling.events.OpenInstructionsEvent;
	import org.bigbluebutton.modules.polling.events.CloseInstructionsEvent;
	import org.bigbluebutton.modules.polling.events.StartPollingEvent;
	import org.bigbluebutton.modules.polling.service.PollingService;

			
	public class PollingManager
	{		
		
		public var toolbarButtonManager:ToolbarButtonManager;
		private var module:PollingModule;
		private var globalDispatcher:Dispatcher;
		private var service:PollingService;
		private var viewWindowManager:ViewerWindowManager;

		
		
		public function PollingManager()
		{
				LogUtil.debug("Polling:: init Polling Manager");
			    toolbarButtonManager = new ToolbarButtonManager();
			    globalDispatcher = new Dispatcher();
			    viewWindowManager = new ViewerWindowManager(service);
					
		}

	
										
		public function handleMadePresenterEvent(e:MadePresenterEvent):void{
			//LogUtil.debug("Polling::call  addToolBarButton when user changes to presenter");
			toolbarButtonManager.addToolbarButton();
			
		}
		
		public function handleMadeViewerEvent(e:MadePresenterEvent):void{
			//LogUtil.debug("Polling::remove  addToolBarButton when user changes to viewer");
			toolbarButtonManager.removeToolbarButton();
		}
		
		public function handleOpenViewWindowEvent(e:StartPollingEvent):void{
			toolbarButtonManager.enableToolbarButton();
		}
		
		public function handleCloseInstructionsWindow(e:CloseInstructionsEvent):void {
		  toolbarButtonManager.enableToolbarButton();	
		}
		
		
		
		public function  handleCloseInstructionsWindowEvent(window:IBbbModuleWindow):void {
				LogUtil.debug("Polling:: inside Polling Manager :: Going to close Polling instructions window");
				var windowEvent:CloseWindowEvent = new CloseWindowEvent(CloseWindowEvent.CLOSE_WINDOW_EVENT);
				windowEvent.window = window;
				globalDispatcher.dispatchEvent(windowEvent);
		     }		
						
	
	public function handleOpenPollingViewWindow(window:IBbbModuleWindow):void{
		    	
			LogUtil.debug("Polling:: View Window :: inside Polling Manager handleOpenPollingViewWindow");
			
			 var windowEvent:OpenWindowEvent = new OpenWindowEvent(OpenWindowEvent.OPEN_WINDOW_EVENT);
			windowEvent.window = window;
			globalDispatcher.dispatchEvent(windowEvent);
		}
	     
      	// Opening Instructions Window 	
		
	 
}
}
