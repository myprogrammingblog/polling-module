package org.bigbluebutton.modules.polling.model
{

			import mx.collections.ArrayCollection;
	/*
	 *  This class has been setted his attributes to public, for serialize with the model of the bigbluebutton-apps, in order
	 *  to enable the communication. This class is used for send public and private.
	 **/
	[Bindable]
	[RemoteClass(alias="org.bigbluebutton.conference.service.poll.Poll")]
	public class PollObject
	{
		public var title:String;
		public var room:String;
		public var isMultiple:Boolean;
		public var question:String;
		public var answers:Array;
		public var votes:Array;
		public var time:String;
		public var totalVotes:int;
	}
}