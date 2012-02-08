package org.bigbluebutton.modules.polling.model
{
	import org.bigbluebutton.modules.polling.model.PollObject;
	[Bindable] public class ValueObject{
		public var id:String;
		public var label:String;
		public var poll:PollObject;
		public var status:Boolean;
		
		public function ValueObject(id:String, label:String, poll:PollObject = null){
			this.id = id;
			this.label = label;
			this.poll = poll;
			this.status = poll.status;
		}
	}
}