package org.bigbluebutton.modules.polling.model
{

	[Bindable] public class ValueObject{
		public var id:String;
		public var label:String;
		
		public function ValueObject(id:String, label:String){
			this.id = id;
			this.label = label;
		}
	}
}