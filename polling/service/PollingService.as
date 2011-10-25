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
	import org.bigbluebutton.modules.polling.events.ConnectionEvent;
	
	
	public class PollingService
	{	

		private var nc:NetConnection;
		private var ns:NetStream;
		private var pollingSO:Object;
		private var uri:String;
		private var module:PollingModule;
		private var dispatcher:Dispatcher;
		
	public function PollingService()
		{
			LogUtil.debug("PollingService: Inside constructor");
			this.dispatcher = new Dispatcher();			
		}
		
		public function handleStartModuleEvent(module:PollingModule):void {
			
			this.module = module;
			LogUtil.debug("Polling: PollingService:: inside handleStartModuleEvent :: calling connect(uri)");	
			connect(module.uri);
		}

		public function connect(uri:String):void {
		this.uri = uri;
		LogUtil.debug("PollingService: inside connect() uri:" + uri);	
		  nc = new NetConnection();
		  pollingSO = SharedObject.getRemote("pollingSO", uri, false);
		  nc.addEventListener(NetStatusEvent.NET_STATUS,  netStatusHandler);
          nc.client = this;      
          nc.connect(uri);		
			
		}

    //Event Handlers
    private function netStatusHandler(event:NetStatusEvent):void
		{
			var statusCode:String = event.info.code;
			var connEvent:ConnectionEvent = new ConnectionEvent(ConnectionEvent.CONNECT_EVENT);
			
			switch ( statusCode ) 
			{
				case "NetConnection.Connect.Success":				
					connEvent.success = true;	
					LogUtil.debug("Polling: succesfull connection to "+uri);				
					break;
				default:
					connEvent.success = false;
					LogUtil.debug("PollingService: connection failed to "+uri);
				   break;
			}
			dispatcher.dispatchEvent(connEvent);
		}
		

	}
}