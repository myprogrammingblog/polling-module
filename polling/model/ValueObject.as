package org.bigbluebutton.modules.polling.model
{
	[Bindable]
	public class ValueObject
	{
		public var id:String;
		public var label:String;
		public var icon:String;
		public var pollKey:String;
		
		public function ValueObject(id:String, label:String, icon:String=null)
		{
			this.id = id;
			this.label = label;
			this.icon = icon;
		}

	}
}