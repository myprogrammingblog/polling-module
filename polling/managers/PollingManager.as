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
	import org.bigbluebutton.modules.polling.events.PollingViewWindowEvent;//testing to be deleted
	import org.bigbluebutton.modules.polling.service.PollingService;

			
	public class PollingManager
	{	
		
		public static const LOGNAME:String = "[PollingManager] ";	
		
		public var toolbarButtonManager:ToolbarButtonManager;
		private var module:PollingModule;
		private var globalDispatcher:Dispatcher;
		private var service:PollingService;
		private var viewWindowManager:ViewerWindowManager;
		private var isPolling:Boolean = false;

		
		
		public function PollingManager()
		{
				LogUtil.debug(LOGNAME +" inside constructor");
				service = new PollingService();
			    toolbarButtonManager = new ToolbarButtonManager();
			    globalDispatcher = new Dispatcher();
			    viewWindowManager = new ViewerWindowManager(service);
					
		}
		
		public function handleStartModuleEvent(module:PollingModule):void {
			LogUtil.debug(LOGNAME + "Polling Module starting");
			this.module = module;			
			service.handleStartModuleEvent(module);
		}

	
        // Acting on Events when user SWITCH TO/FROM PRESENTER-VIEWER
        //------------------------------------------------------------------------------										
		public function handleMadePresenterEvent(e:MadePresenterEvent):void{
			LogUtil.debug(LOGNAME +" inside handleMadePresenterEvent :: adding toolbar button");
			toolbarButtonManager.addToolbarButton();
			
		}
		
		public function handleMadeViewerEvent(e:MadePresenterEvent):void{
			LogUtil.debug(LOGNAME +" inside handleMadeViewerEvent :: removing toolbar button");
			toolbarButtonManager.removeToolbarButton();
		}
		//------------------------------------------------------------------------------------
		
		// ENABLING TOOLBAR BUTTON AFTER EVENTS
		//----------------------------------------------------------------------
		public function handleStartPollingEvent(e:StartPollingEvent):void{
			LogUtil.debug(LOGNAME +" inside handleStartPollingEvent");
			toolbarButtonManager.enableToolbarButton();
			viewWindowManager.handleStartPollingEvent();
		}
		
		public function handleCloseInstructionsWindow(e:CloseInstructionsEvent):void {
			LogUtil.debug(LOGNAME +" inside handleCloseInstructionsWindow");
		  toolbarButtonManager.enableToolbarButton();	
		  isPolling=false;
		}
		//------------------------------------------------------------------------
		
		// Closing Instructions Window
		public function  handleCloseInstructionsWindowEvent(window:IBbbModuleWindow):void {
				LogUtil.debug(LOGNAME +" inside handleCloseInstructionsWindowEvent");
				var windowEvent:CloseWindowEvent = new CloseWindowEvent(CloseWindowEvent.CLOSE_WINDOW_EVENT);
				windowEvent.window = window;
				globalDispatcher.dispatchEvent(windowEvent);
		     }		
						
	// Opening PollingViewWindow
	public function handleOpenPollingViewWindow(e:PollingViewWindowEvent):void{
		   if(isPolling) return; 	
		      LogUtil.debug(LOGNAME +" inside handleOpenPollingViewWindow ");
		      viewWindowManager.handleOpenPollingViewWindow(e);
		     // LogUtil.debug(LOGNAME +" passing to sendPolling Request variable room: [ " +module.getRoom() + " ]");
			   //viewWindowManager.sendPollingRequest(module.getRoom());
			   //isPolling=true;
		}  	

}
}