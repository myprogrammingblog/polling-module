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
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	import mx.controls.Alert;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.modules.polling.events.PollingViewWindowEvent;

	//TESTING
	import org.bigbluebutton.modules.polling.views.PollingViewWindow;
	import org.bigbluebutton.modules.polling.managers.ViewerWindowManager;
	import org.bigbluebutton.common.events.OpenWindowEvent;
	import org.bigbluebutton.common.IBbbModuleWindow;
				
	public class PollingService
	{	
		public static const LOGNAME:String = "[PollingService] ";


		private var pollingSO:SharedObject;
		private var uri:String;
		private var module:PollingModule;
		private var dispatcher:Dispatcher;
		private var attributes:Object;
		private var room:String;
		private var responder:Responder;
		private var windowManager: ViewerWindowManager;
		private static const SHARED_OBJECT:String = "pollingSO";
		private var isPolling:Boolean = false;
		
		private var viewWindow:PollingViewWindow;
					
	public function PollingService()
		{
			LogUtil.debug(LOGNAME + " Inside constructor");
			dispatcher = new Dispatcher();
					
		}
		
		public function handleStartModuleEvent(module:PollingModule):void {
			
			this.module = module;
			this.uri = module.uri;
			LogUtil.debug(LOGNAME +"inside handleStartModuleEvent :: calling connect("+uri+")");	
			connect(uri);
	
		}
		
		
		 // CONNECTION
		/*###################################################*/
		public function connect(uri:String):void {
			
	 		var nc:NetConnection = new NetConnection();
     		nc.connect(uri);
	
			LogUtil.debug(LOGNAME + "inside connect ()  ");
			pollingSO = SharedObject.getRemote(SHARED_OBJECT, module.uri, false);
			pollingSO.addEventListener(NetStatusEvent.NET_STATUS, connectionHandler);
			pollingSO.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			pollingSO.client = this;
			pollingSO.connect(nc);
			LogUtil.debug(LOGNAME + "shared object pollingSO connected via uri: "+uri);    
		}
		
			public function getConnection():NetConnection{
	   		LogUtil.debug(LOGNAME + "Inside getConnection() returning: " + module.connection);
			return module.connection;
		}
          
          
          
           // Dealing with PollingViewWindow
          /*#######################################################*/
          
         public function sharePollingWindow():void{
         	LogUtil.debug(LOGNAME + "inside sharePollingWindow calling pollingSO.send()");
         	pollingSO.send("openPollingWindow"); 
         	
         }
         
         public function openPollingWindow():void{
         	LogUtil.debug(LOGNAME+ "inside openPollingWindow");
         	var e:PollingViewWindowEvent = new PollingViewWindowEvent(PollingViewWindowEvent.OPEN);
			dispatcher.dispatchEvent(e);
         }

	   public function setPolling(polling:Boolean):void{
	   		isPolling = polling; 
	   }
	   public function getPollingStatus():Boolean{
	   		return isPolling;
	   }

		
        //Event Handlers
        /*######################################################*/
    	private function connectionHandler (e:NetStatusEvent):void
		{
			
			LogUtil.debug(LOGNAME+"Inside  connectionHandler PollingService: ");
			switch (e.info.code) 
			{
				case "NetConnection.Connect.Success":
					LogUtil.debug(LOGNAME + "Connection Success");			
					break;
			
				case "NetConnection.Connect.Failed":	
					LogUtil.error(LOGNAME+ "pollingSO connection failed.");		
					break;
					
				case "NetConnection.Connect.Closed":			
					LogUtil.error(LOGNAME + "Connection to pollingSO was closed.");						
					break;
					
			
					
				case "NetConnection.Connect.Rejected":
					LogUtil.error(LOGNAME +"No permissions to connect to the pollingSO");
					break;
					
				default:
					LogUtil.error(LOGNAME +" default case - " +e.info.code );
			}
		}
		
		private function asyncErrorHandler (event:AsyncErrorEvent):void
		{
			LogUtil.error(LOGNAME+"asynchronous error.");
		}
		
			public function disconnect():void{
			if (module.connection != null) module.connection.close();
		}
		
		public function onBWDone():void{
                //called from asc
                trace("onBandwithDone");
            } 
	   }
	}
