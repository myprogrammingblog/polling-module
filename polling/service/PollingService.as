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
         			pollingSO.send("openPollingWindow", poll.title, poll.question, poll.isMultiple, poll.answers, poll.votes, poll.time, poll.totalVotes); 
         	}
         }
         
         
         
         public function openPollingWindow(title:String, question:String, isMultiple:Boolean, answers:Array, votes:Array, time:String, totalVotes:int):void{
         	var username:String = module.username;
         	
         	LogUtil.debug(LOGNAME + "Opening window: Answers are : " + answers);
         	LogUtil.debug(LOGNAME + "Opening window: Poll title is: " + title);
         	         	
         	//var role:String = module.role;
         	if (!UserManager.getInstance().getConference().amIModerator()){
         		LogUtil.debug(LOGNAME + "dispatching Open polling view window for NON moderator users");	
         		var e:PollingViewWindowEvent = new PollingViewWindowEvent(PollingViewWindowEvent.OPEN);
         		e.title = title;
         		e.question = question;
         		e.answers = answers;
         		e.votes = votes;
         		e.isMultiple = isMultiple;
         		e.time = time;
         		
				dispatcher.dispatchEvent(e);
         	}else{
         		var stats:PollingStatsWindowEvent = new PollingStatsWindowEvent(PollingStatsWindowEvent.OPEN);
         		stats.title = title;
         		stats.question = question;
         		stats.answers = answers;
         		stats.votes = votes;
         		stats.isMultiple = isMultiple;
         		stats.time = time;
         		stats.totalVotes = totalVotes;
         		stats.status = false;
         		
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
		
		public function savePoll(answers:Array, question:String, title:String, isMultiple:Boolean, room:String, votes:Array, time:String):void
		{
			nc.call("poll.savePoll",
				new Responder(
					function(result:Object):void { 
						LogUtil.debug(LOGNAME+" succesfully connected  sent info to server "); 
					},	
					function(status:Object):void { 
						LogUtil.error(LOGNAME + "Error occurred sending info to server in SAVEPOLL NC.CALL"); 
						for (var x:Object in status) { 
							LogUtil.error(x + " : " + status[x]); 
						} 
					}
				),
				answers,
				question,
				title,
				isMultiple,
				room,
				votes,
				time,
				0,
				true
			); 
			//_netConnection.call
			LogUtil.debug(LOGNAME + " After Connection");
		}	   
	
		//#################################################//
		// Get poll from database, send to users for them to vote on.
		
	   	public function  getPoll(pollKey:String, refreshFlag:Boolean = false):void{	   	
			LogUtil.debug(LOGNAME + "inside getPoll making netconnection getting our poll back! key: " + pollKey);
			// So, the data stays in poll until nc.call ends, and then disappears.			
			nc.call("poll.getPoll", new Responder(success, failure), pollKey);
			// What happens in nc.call, stays in nc.call; data will have to reach the server to persist
			
			//--------------------------------------//
			
			// Responder functions
			function success(obj:Object):void{
				var itemArray:Array = obj as Array;
				LogUtil.debug(LOGNAME+" Responder success, refreshFlag is " + refreshFlag);
				LogUtil.debug(LOGNAME+"Responder object success! " + itemArray);
				extractPoll(itemArray, refreshFlag);
			}
	
			function failure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure in GETPOLL NC.CALL");
			}
			
			//--------------------------------------//
	   } // _getPoll 
	  
	     public function extractPoll(values:Array, refreshFlag:Boolean):void {
		    LogUtil.debug(LOGNAME + "Inside extractPoll()");
		    var poll:PollObject = new PollObject();
		    		    
		    poll.title = values[0] as String;
		    poll.room = values[1] as String;
		    poll.isMultiple = values[2] as Boolean;
		    poll.question = values[3] as String;
		    poll.answers = values[4] as Array;
		    poll.votes = values[5] as Array;	    
		    poll.time = values[6] as String;		    
		    poll.totalVotes = values[7] as int;
		    poll.status = values[8] as Boolean;
		    
		    LogUtil.debug(LOGNAME + "Leaving extractPoll()");
		    if (!refreshFlag){
		    	sharePollingWindow(poll);
		    }else{  
		    	refreshResults(poll.votes, poll.totalVotes);
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
		 	// (could be out of order, shouldn't matter) 
		 	
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
		 
		 public function refreshResults(votes:Array, totalVotes:int):void{
		 	var refreshEvent:PollRefreshEvent = new PollRefreshEvent(PollRefreshEvent.REFRESH);
		 	refreshEvent.votes = votes;
		 	refreshEvent.totalVotes = totalVotes;
		 	dispatcher.dispatchEvent(refreshEvent);
		 } // _refreshResults
		 
		 public function updateTitles():void{
		 	nc.call("poll.titleList", new Responder(success, failure));
		 	
		 	//--------------------------------------//
			
			// Responder functions
			function success(obj:Object):void{
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
