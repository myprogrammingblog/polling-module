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

	import org.bigbluebutton.modules.polling.events.*;
	
	import org.bigbluebutton.modules.polling.service.PollingService;
	
	import org.bigbluebutton.core.managers.UserManager;
	import org.bigbluebutton.main.model.users.Conference 
	import org.bigbluebutton.main.model.users.BBBUser;
	import org.bigbluebutton.common.Role;

			
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
		public var participants:int;
		private var conference:Conference;

		
		
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
				
	  // Checking the polling status to prevent a presenter from publishing two polls at a time
	  public function handleCheckStatusEvent(e:PollingStatusCheckEvent):void{
		  LogUtil.debug(LOGNAME +" inside handleCheckStatusEvent ");
		  viewWindowManager.handleCheckStatusEvent(e);
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
		      LogUtil.debug(LOGNAME +" Event is " + e);
		      viewWindowManager.handleClosePollingViewWindow(e);
		      toolbarButtonManager.enableToolbarButton();
		}  	
	  // Stop polling and close all viewer's poll windows	
	  public function handleStopPolling(e:StopPollEvent):void{
		      LogUtil.debug(LOGNAME +" inside handleStopPolling ");
		      LogUtil.debug(LOGNAME +" Event is " + e);
		      viewWindowManager.handleStopPolling(e);
		      
		      pollKey = module.getRoom() +"-"+ e.poll.title ;
		      service.closeAllPollingWindows();
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
			e.poll.room = module.getRoom();
			pollKey = e.poll.room +"-"+ e.poll.title ;
			LogUtil.debug(LOGNAME + " poll.didNotVote is " + e.poll.didNotVote + " in Manager.HandleSavePoll");
			service.savePoll(e.poll);
		}	
		
	
		public function handlePublishPollEvent(e:PublishPollEvent):void
		{
			if (!service.getPollingStatus() && (e.poll.title != null)){
				LogUtil.debug(LOGNAME + " inside handlePublishPollEvent(), calling getPoll");
				pollKey = module.getRoom() +"-"+ e.poll.title ;
				service.getPoll(pollKey, "publish");
			}else{
				if (service.getPollingStatus())
					LogUtil.debug(LOGNAME + "Publishing denied; poll is still open!");
				if (e.poll.title == null)
					LogUtil.debug(LOGNAME + "Publishing denied; poll title is null");
			}
		}	
		
		public function handleRepostPollEvent(e:PublishPollEvent):void
		{
			for (var v:int = 0; v < e.poll.votes.length; v++){
				e.poll.votes[v] = 0;
			}
			e.poll.totalVotes = 0;
			participants = 0;
			var p:BBBUser;
			conference = UserManager.getInstance().getConference();
			for (var i:int = 0; i < conference.users.length; i++) {
				LogUtil.debug(LOGNAME + "In for loop");
				p = conference.users.getItemAt(i) as BBBUser;
				if (p.role != Role.MODERATOR) {
					participants++;
				}
			} 
			LogUtil.debug(LOGNAME + " This room has " + participants + " non-moderators right before poll reposts.");
			e.poll.didNotVote = participants;
			pollKey = module.getRoom() +"-"+ e.poll.title ;
			service.savePoll(e.poll);
			service.getPoll(pollKey, "publish");
		}
		
		public function handleVoteEvent(e:VoteEvent):void
		{			   
			LogUtil.debug(LOGNAME + " inside handleVoteEvent()");
			e.pollKey = module.getRoom() +"-"+ e.title ;
			service.vote(e.pollKey, e.answerID);
		}
		
		//##################################################################################	
		
		  // Opening PollingStatsWindow
		  public function handleOpenPollingStatsWindow(e:PollingStatsWindowEvent):void{
			      LogUtil.debug(LOGNAME +" inside handleOpenPollingStatsWindow ");
			      e.poll.room = module.getRoom();
			      viewWindowManager.handleOpenPollingStatsWindow(e);
			}  	
		  // Closing PollingStatsWindow	
		  public function handleClosePollingStatsWindow(e:PollingStatsWindowEvent):void{
			      LogUtil.debug(LOGNAME +" inside handleClosePollingStatsWindow ");
			      viewWindowManager.handleClosePollingStatsWindow(e);
			}
		  // Refreshing PollingStatsWindow	
		  public function handleRefreshPollingStatsWindow(e:PollRefreshEvent):void{
			      LogUtil.debug(LOGNAME +" inside handleRefreshPollingStatsWindow ");
			      viewWindowManager.handleRefreshPollingStatsWindow(e);
		  }
		  
		  public function handleGetPollingStats(e:PollRefreshEvent):void{
		      LogUtil.debug(LOGNAME +" inside handleGetPollingStats ");
		      e.poll.room = module.getRoom();
		      e.pollKey = e.poll.room +"-"+ e.poll.title ;
		      LogUtil.debug(LOGNAME + " pollKey is " + e.pollKey);
		      service.getPoll(e.pollKey, "refresh");
		  }  
		
		//##################################################################################

		  // Make a call to the service to update the list of titles and statuses for the Polling Menu
		  public function handleInitializePollMenuEvent(e:PollGetTitlesEvent):void{
			  LogUtil.debug(LOGNAME +" inside handleInitializePollMenuEvent ");
			  toolbarButtonManager.button.roomID = module.getRoom();
			  service.initializePollingMenu(module.getRoom());
		  }
		  
		  public function handleUpdateTitlesEvent(e:PollGetTitlesEvent):void{
			  LogUtil.debug(LOGNAME +" inside handleUpdateTitleEvent ");
			  toolbarButtonManager.button.roomID = module.getRoom();
			  service.updateTitles();
		  }

		  public function handleReturnTitlesEvent(e:PollReturnTitlesEvent):void{
			  LogUtil.debug(LOGNAME +" inside handleReturnTitleEvent ");
			  toolbarButtonManager.button.titleList = e.titleList;
			  LogUtil.debug(LOGNAME +" inside handleReturnTitleEvent Title List is " + toolbarButtonManager.button.titleList);
		  }

		  public function handleGetPollEvent(e:PollGetPollEvent):void{
			  LogUtil.debug(LOGNAME +" inside handleGetPollEvent ");
			  service.getPoll(e.pollKey, "menu");
		  }
		  
		  public function handlePopulateMenuEvent(e:PollGetPollEvent):void{
			  LogUtil.debug(LOGNAME +" inside handlePopulateMenuEvent ");
			  toolbarButtonManager.button.pollList.addItem(e.poll);
		  }
		  
		   public function handleReturnPollEvent(e:PollGetPollEvent):void{
			  LogUtil.debug(LOGNAME +" inside handleReturnPollEvent with poll title " + e.poll.title);
			  LogUtil.debug(LOGNAME +" inside handleReturnPollEvent with poll object " + e.poll);
			  			  
			  var unique:Boolean = true;

			  if (toolbarButtonManager.button.pollList.length != null){
				  LogUtil.debug(LOGNAME +" About to enter for-loop with length " + toolbarButtonManager.button.pollList.length);
				  for (var i:int = 0; i < toolbarButtonManager.button.pollList.length; i++){
					  var listKey:String = toolbarButtonManager.button.pollList.getItemAt(i).room+"-"+toolbarButtonManager.button.pollList.getItemAt(i).title;
					  if (e.pollKey == listKey){
						  LogUtil.debug(LOGNAME + " Match found, unique is false.");
						  unique = false;
						  // Delete and replace the offending poll
						  toolbarButtonManager.button.pollList.setItemAt(e.poll, i);
					  } // _compare pollKeys
				  } // _for-loop
			  } // _if pollList is null
			  LogUtil.debug(LOGNAME +" For-loop is done, checking unique");
			  if (unique){
				  LogUtil.debug(LOGNAME + " Match not found, adding item.");
				  toolbarButtonManager.button.pollList.addItem(e.poll);
			  }
		  }
		
		  public function handleCheckTitlesEvent(e:PollGetTitlesEvent):void{
			  LogUtil.debug(LOGNAME +" inside handleCheckTitleEvent ");
			  if (e.type == "CHECK"){
				  LogUtil.debug(LOGNAME +" Event type is CHECK ");
				  service.checkTitles();
			  }
			  else if (e.type == "RETURN"){
				  LogUtil.debug(LOGNAME +" Event type is RETURN ");
				  viewWindowManager.handleCheckTitlesInInstructions(e);
			  }
			  else{
				  LogUtil.debug(LOGNAME +" Invalid event type: " + e.type);
			  }
		  }
		//##################################################################################
		  
		  public function handleOpenSavedPollEvent(e:OpenSavedPollEvent):void{
		  	LogUtil.debug(LOGNAME +" Checking poll progress through event path, event poll is: ");
		  	e.poll.checkObject();
		  	viewWindowManager.handleOpenPollingInstructionsWindowWithExistingPoll(e);
		  }
		  
		  public function handleReviewResultsEvent(e:ReviewResultsEvent):void{
			  LogUtil.debug(LOGNAME +" Reviewing results event, event poll is: ");
			  e.poll.checkObject();
			  viewWindowManager.handleReviewResultsEvent(e);
		  }
		//##################################################################################
   }
}
