package org.bigbluebutton.modules.polling.model
{
	import org.bigbluebutton.modules.polling.model.PollObject;
	[Bindable] public class ValueObject{
		public var id:String;
		public var label:String;
		public var poll:PollObject;
		
		public function ValueObject(id:String, label:String, poll:PollObject = null){
			if (poll == null){
				this.id = id;
				this.label = label;
				this.poll = poll;
			}else{
				this.id = poll.room+"-"+poll.title;
				this.label = poll.title;
				this.poll = poll;
			}
		}
	}
}