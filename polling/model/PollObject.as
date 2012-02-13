package org.bigbluebutton.modules.polling.model
{
	import mx.collections.ArrayCollection;
	import org.bigbluebutton.common.LogUtil;
	
	/*
	 *  This class has been setted his attributes to public, for serialize with the model of the bigbluebutton-apps, in order
	 *  to enable the communication. This class is used for send public and private.
	 **/
	[Bindable]
	[RemoteClass(alias="org.bigbluebutton.conference.service.poll.Poll")]
	public class PollObject
	{
		public static const LOGNAME:String = "[PollingObject] ";
		
		public var title:String;
		public var room:String;
		public var isMultiple:Boolean;
		public var question:String;
		public var answers:Array;
		public var votes:Array;
		public var time:String;
		public var totalVotes:int;
		public var status:Boolean;
		public var didNotVote:int;
		
		// This just loops through the PollObject and does a bunch of LogUtil messages to verify the contents.
		public function checkObject():void{
			if (this != null){
				LogUtil.debug(LOGNAME + "Running CheckObject on the poll with title " + title);
				LogUtil.debug(LOGNAME + "Room is: " + room);
				LogUtil.debug(LOGNAME + "isMultiple is: " + isMultiple.toString());
				LogUtil.debug(LOGNAME + "Question is: " + question);
				LogUtil.debug(LOGNAME + "Answers are: " + answers);
				LogUtil.debug(LOGNAME + "Votes are: " + votes);
				LogUtil.debug(LOGNAME + "Time is: " + time);
				LogUtil.debug(LOGNAME + "TotalVotes is: " + totalVotes);
				LogUtil.debug(LOGNAME + "Status is: " + status.toString());
				LogUtil.debug(LOGNAME + "DidNotVote is: " + didNotVote);
				LogUtil.debug(LOGNAME + "--------------");
			}else{
				LogUtil.debug(LOGNAME + "This PollObject is NULL.");
			}
		}
		
		/*
		public function compare(poll:PollObject):void{
			LogUtil.debug(LOGNAME + "Comparing poll " + this.title + " to poll " + poll.title + ":");
			
			if (this.room == poll.room){
				LogUtil.debug(LOGNAME + "Rooms are equal.");
			}else{
				LogUtil.debug(LOGNAME + "Rooms are not equal.");
			}
			
			if (this.isMultiple == poll.isMultiple){
				LogUtil.debug(LOGNAME + "Rooms are equal.");
			}else{
				LogUtil.debug(LOGNAME + "Rooms are not equal.");
			}
			
			LogUtil.debug(LOGNAME + "--------------");
		}
		*/
	}
}