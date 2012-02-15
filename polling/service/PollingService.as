/**
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
*
* Copyright (c) 2010 BigBlueButton Inc. and by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 2.1 of the License, or (at your option) any later
* version.
*
* BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
* 
*/
package org.bigbluebutton.modules.polling.service
{
	import com.asfusion.mate.events.Dispatcher;  
	import flash.events.AsyncErrorEvent;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;

	import flash.net.NetConnection;
	import flash.net.SharedObject;
	import flash.net.Responder;
	import mx.collections.ArrayCollection;
    
	
	import mx.controls.Alert;
	import org.bigbluebutton.core.managers.UserManager;
	
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.modules.polling.events.PollingViewWindowEvent;
	import org.bigbluebutton.modules.polling.events.PollingStatsWindowEvent;
	import org.bigbluebutton.modules.polling.events.PollRefreshEvent;
	import org.bigbluebutton.modules.polling.events.PollGetTitlesEvent;
	import org.bigbluebutton.modules.polling.events.PollGetStatusEvent;
	import org.bigbluebutton.modules.polling.events.PollReturnTitlesEvent;
	import org.bigbluebutton.modules.polling.events.PollReturnStatusEvent;
	import org.bigbluebutton.modules.polling.events.PollGetPollEvent;
	
	import org.bigbluebutton.modules.polling.views.PollingViewWindow;
	import org.bigbluebutton.modules.polling.views.PollingInstructionsWindow;
	
	import org.bigbluebutton.modules.polling.managers.PollingWindowManager;
	import org.bigbluebutton.common.events.OpenWindowEvent;
	import org.bigbluebutton.common.IBbbModuleWindow;
	
	import org.bigbluebutton.modules.polling.model.PollObject;

	public class PollingService
	{	
		public static const LOGNAME:String = "[PollingService] ";



		private var pollingSO:SharedObject;
		private var nc:NetConnection;
		private var uri:String;
		private var module:PollingModule;
		private var dispatcher:Dispatcher;
		private var attributes:Object;
		private var windowManager: PollingWindowManager;
		public var pollGlobal:PollObject;
		
		public var test:String;
		
		private static const SHARED_OBJECT:String = "pollingSO";
		private var isPolling:Boolean = false;
		private var isConnected:Boolean = false;
		
		private var viewWindow:PollingViewWindow;
		private var instructions:PollingInstructionsWindow;
					
	public function PollingService()
		{
			LogUtil.debug(LOGNAME + " Inside constructor");
			dispatcher = new Dispatcher();
					
		}
		
		public function handleStartModuleEvent(module:PollingModule):void {
			
			this.module = module;
			nc = module.connection
			LogUtil.debug(LOGNAME + "Connection in constructor: " + nc);
			uri = module.uri;
			connect();
		}
		
		
		 // CONNECTION
		/*###################################################*/
		public function connect():void {
			LogUtil.debug(LOGNAME + "inside connect ()  ");
			pollingSO = SharedObject.getRemote(SHARED_OBJECT, uri, false);
	 		pollingSO.addEventListener(SyncEvent.SYNC, sharedObjectSyncHandler);
			pollingSO.addEventListener(NetStatusEvent.NET_STATUS, handleResult);
				pollingSO.client = this;
				pollingSO.connect(nc); 	
			LogUtil.debug(LOGNAME + "shared object pollingSO connected via uri: "+uri);   
			LogUtil.debug(LOGNAME + "Connection in connect(): " + nc); 
			LogUtil.debug(LOGNAME + " getConnection " +getConnection());
		}
		
			public function getConnection():NetConnection{
	   		LogUtil.debug(LOGNAME + "Inside getConnection() returning: " + module.connection);
			return module.connection;
		}
          
          
          
           // Dealing with PollingViewWindow
          /*#######################################################*/
          
         public function sharePollingWindow(poll:PollObject):void{
         		LogUtil.debug(LOGNAME + "inside sharePollingWindow calling pollingSO.send()");
         		LogUtil.debug(LOGNAME + "Sharing window: Poll title is: " + poll.title);
         	
         	if (isConnected = true ) {
         			poll.checkObject();
           			//LogUtil.debug(LOGNAME + "Going into shared object send NOW");
         			pollingSO.send("openPollingWindow", poll.title, poll.question, poll.isMultiple, poll.answers, poll.votes, poll.time, poll.totalVotes, poll.didNotVote);
         			LogUtil.debug(LOGNAME+"Survived sharing object");
         	}
         }
                  
         public function openPollingWindow(title:String, question:String, isMultiple:Boolean, answers:Array, votes:Array, time:String, totalVotes:int, didNotVote:int):void{
         		var username:String = module.username;
         		var poll:PollObject = new PollObject();
         		poll.title = title;
         		poll.question = question;
         		poll.isMultiple = isMultiple; 
         		poll.answers = answers;
         		poll.votes = votes;
         		poll.time = time;
         		poll.totalVotes = totalVotes;
         		poll.didNotVote = didNotVote;
          		//LogUtil.debug(LOGNAME + "Opening window: Answers are : " + answers);
          		//LogUtil.debug(LOGNAME + "Opening window: Poll title is: " + title);
          		if (!UserManager.getInstance().getConference().amIModerator()){
          		//	LogUtil.debug(LOGNAME + "dispatching Open polling view window for NON moderator users");
          			var e:PollingViewWindowEvent = new PollingViewWindowEvent(PollingViewWindowEvent.OPEN);
	        		e.poll = poll;
          			dispatcher.dispatchEvent(e);
          		}else{
          			//LogUtil.debug(LOGNAME + "Checking the object for moderator polling view");
          			var stats:PollingStatsWindowEvent = new PollingStatsWindowEvent(PollingStatsWindowEvent.OPEN);
          			//LogUtil.debug(LOGNAME + "Survived creating stats event");
          			stats.poll = poll;
          			stats.poll.status = false;
          			//LogUtil.debug(LOGNAME + "Survived populating stats event");
          			dispatcher.dispatchEvent(stats);
          		}
         }

	   public function setPolling(polling:Boolean):void{
	   		isPolling = polling;
	   }
	   
	   
	   public function setStatus(pollKey:String, status:Boolean):void{
	   		if (status){
	   			openPoll(pollKey);
	   		}else{
	   			closePoll(pollKey);
	   		}
	   }
	   
	   
	   public function getPollingStatus():Boolean{
	   		return isPolling;
	   }

		import org.bigbluebutton.core.managers.UserManager;
        //Event Handlers
        /*######################################################*/
        

		
		public function disconnect():void{
			if (module.connection != null) module.connection.close();
		}
		
		public function onBWDone():void{
                //called from asc
                trace("onBandwithDone");
            } 
	   
	   
	   	public function handleResult(e:NetStatusEvent):void {
	   	LogUtil.debug(LOGNAME + "inside handleResult(nc)");	
	   		
			var statusCode : String = e.info.code;

			switch ( statusCode ) 
			{
				case "NetConnection.Connect.Success":
					LogUtil.debug(LOGNAME + ":Connection to Polling Module succeeded.");
					isConnected = true;
					break;
				case "NetConnection.Connect.Failed":					
						LogUtil.debug(LOGNAME + ":Connection to Polling Module failed");
					break
				case "NetConnection.Connect.Rejected":
						LogUtil.debug(LOGNAME + "Connection to Polling Module Rejected");		
					 break 
				default :
				   LogUtil.debug(LOGNAME + ":Connection default case" );
				   break;
			}
		}
		
		private function sharedObjectSyncHandler(e:SyncEvent) : void
		{	
			LogUtil.debug(LOGNAME+"Shared object is connected");	
		}
		
		// Streamlined, experimental SavePoll
		public function savePoll(poll:PollObject):void
		{
			var serverPoll:Array = new Array(poll.title, poll.room, poll.isMultiple, poll.question, poll.answers, poll.votes, poll.time, poll.totalVotes, poll.status, poll.didNotVote);
			LogUtil.debug(LOGNAME + " poll.didNotVote is " + serverPoll[9] + " right before nc.call");
			nc.call("poll.savePoll",
				new Responder(
					function(result:Object):void { 
						LogUtil.debug(LOGNAME+" succesfully connected  sent info to server with [experimental] savePoll"); 
					},	
					function(status:Object):void { 
						LogUtil.error(LOGNAME + "Error occurred sending info to server in [experimental] SAVEPOLL NC.CALL"); 
						for (var x:Object in status) { 
							LogUtil.error(x + " : " + status[x]); 
						} 
					}
				),
				serverPoll
			); 
			//_netConnection.call
			LogUtil.debug(LOGNAME + " After Connection");
		}
		//#################################################//
				
	   	public function  getPoll(pollKey:String, option:String):void{	   	
			LogUtil.debug(LOGNAME + "inside getPoll making netconnection getting our poll back! key: " + pollKey);
			// So, the data stays in poll until nc.call ends, and then disappears.			
			nc.call("poll.getPoll", new Responder(success, failure), pollKey);
			// What happens in nc.call, stays in nc.call; data will have to reach the server to persist
			
			//--------------------------------------//
			
			// Responder functions
			function success(obj:Object):void{
				var itemArray:Array = obj as Array;
				LogUtil.debug(LOGNAME+" Responder success, option is " + option);
				LogUtil.debug(LOGNAME+"Responder object success! " + itemArray);
				extractPoll(itemArray, pollKey, option);
			}
	
			function failure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure in GETPOLL NC.CALL");
			}
			
			//--------------------------------------//
	   } // _getPoll 
	  
	     public function extractPoll(values:Array, pollKey:String, option:String):void {
		    LogUtil.debug(LOGNAME + "Inside extractPoll()");
		    var poll:PollObject = new PollObject();
		    		    
		    poll.title 		= values[0] as String;
		    poll.room 		= values[1] as String;
		    poll.isMultiple = values[2] as Boolean;
		    poll.question 	= values[3] as String;
		    poll.answers 	= values[4] as Array;
		    poll.votes 		= values[5] as Array;	    
		    poll.time 		= values[6] as String;		    
		    poll.totalVotes = values[7] as int;
		    poll.status 	= values[8] as Boolean;
		    poll.didNotVote = values[9] as int;
		    
		    LogUtil.debug(LOGNAME + "Leaving extractPoll()");
		    if (option == "publish"){
		    	LogUtil.debug(LOGNAME + "You hit option publish");
		    	LogUtil.debug(LOGNAME + " poll.didNotVote is " + poll.didNotVote + " in extractPoll for publishing");
		    	sharePollingWindow(poll);
		    }
		    else if (option == "refresh"){
		    	LogUtil.debug(LOGNAME + "You hit option refresh"); 
		    	LogUtil.debug(LOGNAME + " poll.didNotVote is " + poll.didNotVote + " in extractPoll for refreshing");
		    	refreshResults(poll);
		    }
		    else if (option == "menu"){
		    	LogUtil.debug(LOGNAME + "STEP 3 DISPATCH POLLS");
		    	LogUtil.debug(LOGNAME + "You hit option menu");
		    	var pollReturn:PollGetPollEvent = new PollGetPollEvent(PollGetPollEvent.RETURN);
				pollReturn.poll = poll;		
				pollReturn.pollKey = pollKey;
				LogUtil.debug(LOGNAME + "About to dispatch poll with title " + pollReturn.poll.title);
				pollReturn.poll.checkObject();
				dispatcher.dispatchEvent(pollReturn);
		    }
		    else if (option == "initialize"){
		    	LogUtil.debug(LOGNAME+"Initializing the polling menu");
		    	var pollInitialize:PollGetPollEvent = new PollGetPollEvent(PollGetPollEvent.INIT);
		    	pollInitialize.poll = poll;
		    	pollInitialize.pollKey = pollKey;
		    	dispatcher.dispatchEvent(pollInitialize);
		    }
		 }
		 
		
	   	
	   	public function closeAllPollingWindows():void{
        	if (isConnected = true ) {
         			pollingSO.send("closePollingWindow"); 
         	}
        }
        
        public function closePollingWindow():void{
        		LogUtil.debug(LOGNAME + "Inside service.closePollingWindow()");
         	var e:PollingViewWindowEvent = new PollingViewWindowEvent(PollingViewWindowEvent.CLOSE);
         		LogUtil.debug(LOGNAME + "Created close window event");
         	dispatcher.dispatchEvent(e);
         		LogUtil.debug(LOGNAME + "Created close window event");
        }
	   	
	   	
		 
		 public function vote(pollKey:String, answerIDs:Array):void{
		 	// answerIDs will indicate by integer which option(s) the user voted for
		 	// i.e., they voted for 3 and 5 on multiple choice, answerIDs will hold [0] = 3, [1] = 5
		 	// It works the same regardless of if AnswerIDs holds {3,5} or {5,3} 
		 	
		 	 LogUtil.debug("What are we sending to apps ? pollkey: " +pollKey+ " answers: " + answerIDs.toString());
		 	nc.call(
				"poll.vote",
				new Responder(
					function(result:Object):void { 
						LogUtil.debug(LOGNAME+" succesfully sending votes to server"); 
					},	
					function(status:Object):void { 
						LogUtil.error(LOGNAME + "Error occurred sending info to server in VOTE NC.CALL with pollKey " + pollKey + " and answerIDs: " + answerIDs); 
						for (var x:Object in status) { 
							LogUtil.error(x + " : " + status[x]); 
						} 
					}
				),
				pollKey, answerIDs
			);
		 } // _vote
		 
		 public function refreshResults(poll:PollObject):void{
		 	var refreshEvent:PollRefreshEvent = new PollRefreshEvent(PollRefreshEvent.REFRESH);
		 	refreshEvent.poll = poll;
		 	LogUtil.debug(LOGNAME+"In refreshResults, checking for refreshEvent null:");
		 	refreshEvent.poll.checkObject();
		 	dispatcher.dispatchEvent(refreshEvent);
		 } // _refreshResults
		 
		 // Initialize the Polling Menu on the toolbar button
		 public function initializePollingMenu(roomID:String):void{
		 	nc.call("poll.titleList", new Responder(titleSuccess, titleFailure));
		 	LogUtil.debug(LOGNAME+"After nc.call in updateTitles");
		 	//--------------------------------------//
			
			// Responder functions
			function titleSuccess(obj:Object):void{
				var event:PollReturnTitlesEvent = new PollReturnTitlesEvent(PollReturnTitlesEvent.UPDATE);
				event.titleList = obj as Array;
				// Append roomID to each item in titleList, call getPoll on that key, add the result to pollList back in ToolBarButton
				for (var i:int = 0; i < event.titleList.length; i++){
					var pollKey:String = roomID +"-"+ event.titleList[i];
					getPoll(pollKey, "initialize");
				}
				// This dispatch populates the titleList back in the Menu; the pollList is populated one item at a time in the for-loop
				dispatcher.dispatchEvent(event); 
			}
	
			function titleFailure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure in UPDATE_TITLES NC.CALL");
			}
			
			//--------------------------------------//
		 }
		 
		 public function updateTitles():void{
		 	nc.call("poll.titleList", new Responder(success, failure));
		 	LogUtil.debug(LOGNAME+"After nc.call in updateTitles");
		 	//--------------------------------------//
			
			// Responder functions
			function success(obj:Object):void{
				LogUtil.debug(LOGNAME + "STEP 1 DISPATCH TITLES");
				var event:PollReturnTitlesEvent = new PollReturnTitlesEvent(PollReturnTitlesEvent.UPDATE);
				event.titleList = obj as Array;
				LogUtil.debug(LOGNAME+"Responder object success! Object is " + obj);
				dispatcher.dispatchEvent(event);
			}
	
			function failure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure in UPDATE_TITLES NC.CALL");
			}
			
			//--------------------------------------//
		 } // _updateTitles
		 
		 public function updateStatus():void{
		 	nc.call("poll.statusList", new Responder(success, failure));
		 	
		 	//--------------------------------------//
			
			// Responder functions
			function success(obj:Object):void{
				LogUtil.debug(LOGNAME + "STEP 2 DISPATCH STATUS");
				var event:PollReturnStatusEvent = new PollReturnStatusEvent(PollReturnStatusEvent.UPDATE);
				event.statusList = obj as Array;
				LogUtil.debug(LOGNAME+"Responder object success! Object is " + obj);
				dispatcher.dispatchEvent(event);
			}
	
			function failure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure in UPDATE_STATUS NC.CALL");
			}
			
			//--------------------------------------//
		 } // _updateStatus
		 
		 public function checkTitles():void{
		 	nc.call("poll.titleList", new Responder(success, failure));
		 	LogUtil.debug(LOGNAME+"After nc.call in checkTitles");
		 	//--------------------------------------//
			
			// Responder functions
			function success(obj:Object):void{
				var event:PollGetTitlesEvent = new PollGetTitlesEvent(PollGetTitlesEvent.RETURN);
				event.titleList = obj as Array;
				LogUtil.debug(LOGNAME+"Responder object success! Sending titles " + event.titleList);
				dispatcher.dispatchEvent(event);
			}
	
			function failure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure in CHECK_TITLES NC.CALL");
			}
			
			//--------------------------------------//
		 } // _checkTitles
		 
		 public function openPoll(pollKey:String):void{
		 	nc.call("poll.setStatus", new Responder(success, failure), pollKey, true);
		 	
		 	//--------------------------------------//

			// Responder functions
			function success(obj:Object):void{
				LogUtil.debug(LOGNAME+"Responder object success! in SET POLL TO OPEN");
			}
	
			function failure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure in OPENPOLL NC.CALL");
			}
			
			//--------------------------------------//
		 }
		 
		 public function closePoll(pollKey:String):void{
		 	nc.call("poll.setStatus", new Responder(success, failure), pollKey, false);
		 	
		 	//--------------------------------------//
			
			// Responder functions
			function success(obj:Object):void{
				LogUtil.debug(LOGNAME+"Responder object success! SET POLL TO CLOSED");
			}
	
			function failure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure in CLOSEPOLL NC.CALL");
			}
			
			//--------------------------------------//
		 }
   }
}
