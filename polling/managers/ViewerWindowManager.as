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

package org.bigbluebutton.modules.polling.managers
{
	import com.asfusion.mate.events.Dispatcher;
	

	import org.bigbluebutton.common.IBbbModuleWindow;
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.common.events.CloseWindowEvent;
	import org.bigbluebutton.common.events.OpenWindowEvent;
	
	import org.bigbluebutton.modules.polling.service.PollingService;
	import org.bigbluebutton.modules.polling.views.PollingViewWindow;
	import org.bigbluebutton.modules.polling.events.PollingViewWindowEvent;
			
	public class ViewerWindowManager {	
			
		private var viewWindow:PollingViewWindow;
		private var service:PollingService;
		private var isViewing:Boolean = false;
		private var globalDispatcher:Dispatcher;
		public static const LOGNAME:String = "[Polling::ViewWindowManager] ";
		
		public function ViewerWindowManager(service:PollingService) {
		  LogUtil.debug(LOGNAME +" inside constructor");	
		  this.service = service;
		  globalDispatcher = new Dispatcher();
		}
		
		
		// PollingViewWindow.mxml HANDLERS
		public function handleOpenPollingViewWindow(e:PollingViewWindowEvent):void{
			LogUtil.debug(LOGNAME + "inside handleOpenPollingViewWindow invoked by EventMap");
			viewWindow = new PollingViewWindow();
			//LogUtil.debug(LOGNAME + " sending Window To startPolling");
			openWindow(viewWindow);
			service.setPolling(true);
		}
		
		public function handleClosePollingViewWindow(e:PollingViewWindowEvent):void{
			LogUtil.debug(LOGNAME + " inside closePollingRequest received room on PollingViewWindowEvent");
			viewWindow = new PollingViewWindow();
			closeWindow(viewWindow);
			service.setPolling(false);
		}
		
		public function handleStartPollingEvent():void{
			if(service.getPollingStatus() == true) return;
			LogUtil.debug(LOGNAME+ "calling service to share PollingWindow");
			service.sharePollingWindow();
		}
		
		
		// COMMON FUNCTIONS
		public function openWindow(window:IBbbModuleWindow):void{
			LogUtil.debug(LOGNAME + " inside openWindow calling OpwnWindowEvent");				
			var windowEvent:OpenWindowEvent = new OpenWindowEvent(OpenWindowEvent.OPEN_WINDOW_EVENT);
			windowEvent.window = window;
			globalDispatcher.dispatchEvent(windowEvent);
		}
		
		private function closeWindow(window:IBbbModuleWindow):void{
			LogUtil.debug(LOGNAME + " inside openWindow calling OpwnWindowEvent");				
			var windowEvent:CloseWindowEvent = new CloseWindowEvent(CloseWindowEvent.CLOSE_WINDOW_EVENT);
			windowEvent.window = window;
			globalDispatcher.dispatchEvent(windowEvent);
		}
		
			
		/*			
		public function sendPollingRequest(room:String):void{
			LogUtil.debug(LOGNAME + " inside sendPollingRequest received room:" +room);
			viewWindow = new PollingViewWindow();
			LogUtil.debug(LOGNAME + " sending Window To startPolling");
			viewWindow.startPolling(service.getConnection(), room);
			
			openWindow(viewWindow);
			isViewing = true;
		}
		 */
		
	}
}