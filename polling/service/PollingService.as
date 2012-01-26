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
          
         public function sharePollingWindow():void{
         		LogUtil.debug(LOGNAME + "inside sharePollingWindow calling pollingSO.send()");
         	
         	if (isConnected = true ) {
         			pollingSO.send("openPollingWindow"); 
         	}
         }
         
         public function openPollingWindow():void{
         	var username:String = module.username;
         	//var role:String = module.role;
         	if (!UserManager.getInstance().getConference().amIModerator()){
         		LogUtil.debug(LOGNAME + "dispatching Open polling view window for NON moderator users");	
         		var e:PollingViewWindowEvent = new PollingViewWindowEvent(PollingViewWindowEvent.OPEN);
				dispatcher.dispatchEvent(e);
         	}	
         }

	   public function setPolling(polling:Boolean):void{
	   		isPolling = polling; 
	   }
	  /* public function getPollingStatus():Boolean{
	   		return isPolling;
	   }*/

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
		
		public function savePoll(answers:Array, question:String, title:String, isMultiple:Boolean, room:String, votes:Array, time:String ):void
		{
		     LogUtil.debug(LOGNAME + "inside savePoll() making NetConnection: " + nc);
		     LogUtil.debug(LOGNAME + "inside savePoll() making netconnection call answers: " + answers);
		     LogUtil.debug(LOGNAME + "inside savePoll() making netconnection call question: " +  question);
		     LogUtil.debug(LOGNAME + "inside savePoll() making netconnection call title: " + title);
		     LogUtil.debug(LOGNAME + "inside savePoll() making netconnection call isMultiple: " + isMultiple);
		     LogUtil.debug(LOGNAME + "inside savePoll() making netconnection call room: " + room);
		     LogUtil.debug(LOGNAME + "inside savePoll() making netconnection call votes: " + votes);
		     LogUtil.debug(LOGNAME + "inside savePoll() making netconnection call time: " + time);
			nc.call(
				"poll.savePoll",
				new Responder(
					function(result:Object):void { 
						LogUtil.debug(LOGNAME+" succesfully connected  sent info to server "); 
					},	
					function(status:Object):void { 
						LogUtil.error(LOGNAME + "Error occurred sending info to server"); 
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
				time
			); 
			//_netConnection.call
			
			LogUtil.debug(LOGNAME + " After Connection");
		}	   
	
	// TESTING THIS SHOULD GET POLL FROM THE DB
	
	   	public function  getPoll(pollKey:String):void{
			LogUtil.debug(LOGNAME + "inside getPoll making netconnection getting our poll back! key: " + pollKey);
			var poll:PollObject = new PollObject();
			// New way
			
			// Responder automatically returns a PollObject, regardless of whether poll.getPoll returns a Poll or an ArrayList of Poll properties
			nc.call("poll.getPoll", new Responder(success, failure), pollKey); 
			
			function success(obj:Object):void{
				var itemArray:Array = obj as Array;
				LogUtil.debug(LOGNAME+"Responder object success! " + itemArray);
				extractPoll(poll);
			}
	
			function failure(obj:Object):void{
				LogUtil.error(LOGNAME+"Responder object failure.");
			}
				
			// "_New way
			
			/* Original attempt, do not alter or delete yet
			try
			{
			nc.call(
				"poll.getPoll",
				new Responder(
					function(result:Object):void { 
						LogUtil.debug(LOGNAME+" succesfully connected  received poll back");
						 if(result != null)
						 {
						 	poll = result as PollObject;
						    extractPoll(poll);
						 }
						 else LogUtil.debug(LOGNAME + "Result is empty, so poll is empty");
					},	
					function(status:Object):void { 
						LogUtil.error(LOGNAME + "Error occurred sending info to server"); 
						for (var x:Object in status) { 
							LogUtil.error(x + " : " + status[x]); 
						} 
					}
				),
				pollKey
			);
			LogUtil.debug(LOGNAME + "nc.call survived");
			} catch (e:Error) { 
			LogUtil.debug(LOGNAME + "nc.call blew up. KABOOM");
	   		}
	   		/*LogUtil.debug(LOGNAME + "Outside of try-catch, poll.title is " + poll.title);
	   		extractPoll(poll);
	   		LogUtil.debug(LOGNAME + "extraction survived" + poll);*/
	   }
	  
	     public function extractPoll(poll:PollObject):void {
		    LogUtil.debug(LOGNAME + "Inside extractPoll()");
		    
		    /*
		    
		   // POPULATING POLL OBJECT WITH INFORMATION
    	   String pTitle = jedis.hget(pollKey, "title");
    	   String pQuestion = jedis.hget(pollKey, "question");
    	   boolean pMultiple = false;
    	   if (jedis.hget(pollKey, "multiple").compareTo("true") == 0) {pMultiple = true;}
    	   String pRoom = jedis.hget(pollKey, "room");
    	   String pTime = jedis.hget(pollKey, "time");
		
    	   // ANSWER EXTRACTION
    	   long pollSize = jedis.hlen(pollKey);
    	   // IMPORTANT! 
    	   // Increase the value of otherFields for each field you add to the hash which is not a new answer
    	   // (locales, langauge, etc)
    	   int otherFields = 5;
    	   long numAnswers = (pollSize-otherFields)/2;
       
    	   // Create an ArrayList of Strings for answers, and one of ints for answer votes
    	   ArrayList <String> pAnswers = new ArrayList <String>();
    	   ArrayList <Integer> pVotes = new ArrayList <Integer>();
    	   for (int j = 1; j <= numAnswers; j++)
    	   {
    		   pAnswers.add(jedis.hget(pollKey, "answer"+j+"text"));
    		   pVotes.add(Integer.parseInt(jedis.hget(pollKey, "answer"+j)));
    	   }
       
    	   Poll poll = new Poll(pTitle, pQuestion, pAnswers, pMultiple, pRoom, pVotes, pTime);
		    
		    */
		 }
   }
}
