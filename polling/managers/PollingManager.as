package org.bigbluebutton.modules.polling.managers
{
	import com.asfusion.mate.events.Dispatcher;
	import mx.collections.ArrayCollection;
	
	import org.bigbluebutton.modules.polling.views.PollingInstructionsWindow;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.main.events.MadePresenterEvent;
	import org.bigbluebutton.common.events.OpenWindowEvent;
	import org.bigbluebutton.common.events.CloseWindowEvent;

	import org.bigbluebutton.common.IBbbModuleWindow;

	
	import org.bigbluebutton.modules.polling.events.StartPollingEvent;
	import org.bigbluebutton.modules.polling.events.PollingViewWindowEvent;
	import org.bigbluebutton.modules.polling.events.PollingInstructionsWindowEvent;
	import org.bigbluebutton.modules.polling.events.AcceptPollingInstructionsWindowEvent;
	import org.bigbluebutton.modules.polling.events.SavePollEvent;
	import org.bigbluebutton.modules.polling.events.PublishPollEvent;
	import org.bigbluebutton.modules.polling.events.VoteEvent;
	
	import org.bigbluebutton.modules.polling.service.PollingService;

			
	public class PollingManager
	{	
		
		public static const LOGNAME:String = "[PollingManager] ";	
		
		public var toolbarButtonManager:ToolbarButtonManager;
		private var module:PollingModule;
		private var globalDispatcher:Dispatcher;
		private var service:PollingService;
		private var viewWindowManager:PollingWindowManager;
		private var isPolling:Boolean = false;
		public var pollKey:String;

		
		
		public function PollingManager()
		{
				LogUtil.debug(LOGNAME +" inside constructor");
				service = new PollingService();
			    toolbarButtonManager = new ToolbarButtonManager();
			    globalDispatcher = new Dispatcher();
			    viewWindowManager = new PollingWindowManager(service);
					
		}
		
		
		//Starting Module
		public function handleStartModuleEvent(module:PollingModule):void {
			LogUtil.debug(LOGNAME + "Polling Module starting");
			this.module = module;			
			service.handleStartModuleEvent(module);
		}

	
        // Acting on Events when user SWITCH TO/FROM PRESENTER-VIEWER
        //#####################################################################################										
		public function handleMadePresenterEvent(e:MadePresenterEvent):void{
			LogUtil.debug(LOGNAME +" inside handleMadePresenterEvent :: adding toolbar button");
			toolbarButtonManager.addToolbarButton();
			
		}
		
		public function handleMadeViewerEvent(e:MadePresenterEvent):void{
			LogUtil.debug(LOGNAME +" inside handleMadeViewerEvent :: removing toolbar button");
			toolbarButtonManager.removeToolbarButton();
		}
		//######################################################################################
		
		// Handling Window Events
		//#####################################################################################
		
	   //Sharing Polling Window
	   public function handleStartPollingEvent(e:StartPollingEvent):void{
			LogUtil.debug(LOGNAME +" inside handleStartPollingEvent");
			toolbarButtonManager.enableToolbarButton();
			viewWindowManager.handleStartPollingEvent();
		}
        //##################################################################################
		
		// Closing Instructions Window
	   public function  handleClosePollingInstructionsWindowEvent(e:PollingInstructionsWindowEvent):void {
			  LogUtil.debug(LOGNAME +" inside handleCloseInstructionsWindowEvent ");
		      viewWindowManager.handleClosePollingInstructionsWindow(e);
		      toolbarButtonManager.enableToolbarButton();
		     }		
		 //Opening Instructions Window    
	  public function handleOpenPollingInstructionsWindowEvent(e:PollingInstructionsWindowEvent):void {
			  LogUtil.debug(LOGNAME +" inside handleCloseInstructionsWindowEvent ");
		      viewWindowManager.handleOpenPollingInstructionsWindow(e);
		     }		     
				
		//##################################################################################	
						
	  // Opening PollingViewWindow
	  public function handleOpenPollingViewWindow(e:PollingViewWindowEvent):void{
		   if(isPolling) return; 	
		      LogUtil.debug(LOGNAME +" inside handleOpenPollingViewWindow ");
		      viewWindowManager.handleOpenPollingViewWindow(e);
		      toolbarButtonManager.disableToolbarButton();
		}  	
	  // Closing PollingViewWindow	
	  public function handleClosePollingViewWindow(e:PollingViewWindowEvent):void{
		      LogUtil.debug(LOGNAME +" inside handleClosePollingViewWindow ");
		      viewWindowManager.handleClosePollingViewWindow(e);
		      toolbarButtonManager.enableToolbarButton();
		}  	
	//##################################################################################
		
		  // Opening PollingAcceptInstructionsWindow
	  public function handleOpenAcceptPollingInstructionsWindow(e:AcceptPollingInstructionsWindowEvent):void{
		  	
		      LogUtil.debug(LOGNAME +" inside handleOpenAcceptPollingInstructionsWindow ");
		      viewWindowManager.handleOpenAcceptPollingInstructionsWindow(e);
		      toolbarButtonManager.disableToolbarButton();
		}  	
	   // Closing PollingAcceptInstructionsWindow
	   public function handleCloseAcceptPollingInstructionsWindow(e:AcceptPollingInstructionsWindowEvent):void{
		      LogUtil.debug(LOGNAME +" handleCloseAcceptPollingInstructionsWindow ");
		      viewWindowManager.handleCloseAcceptPollingInstructionsWindow(e);
		       toolbarButtonManager.enableToolbarButton();
		}  	
		//##################################################################################
	   public function handleSavePollEvent(e:SavePollEvent):void
		{
			LogUtil.debug(LOGNAME + " inside savePoll(), calling service...");
			pollKey = module.getRoom() +"-"+ e.title ;
			service.savePoll(e.answers, e.question, e.title, e.isMultiple, module.getRoom(), e.votes, e.time);
		}	
		
	
		public function handlePublishPollEvent(e:PublishPollEvent):void
		{
			//var pollKey:String;
			LogUtil.debug(LOGNAME + " inside handlePublishPollEvent(), calling getPoll");
			pollKey = module.getRoom() +"-"+ e.title ;
			service.getPoll(pollKey);
		}	
		
	
		
		public function handleVoteEvent(e:VoteEvent):void
		{
			
			// What need to be done:
			  // we need to have getPollKey() method  inside pollObject that returns pollkey so we don't have to include title in every event....
			   // pollKey here is zero
			   // or other object could be considered, but poll information should be somehow available through "get" methods....
			   
			LogUtil.debug(LOGNAME + " inside handleVoteEvent()");
			e.pollKey = module.getRoom() +"-"+ e.title ;
			service.vote(e.pollKey, e.answerID);
		}
		
   }
}
