package sui.events
{
	import flash.events.Event;
	import sui.FComponent;

	public class ComponentEvent extends Event
	{
		public static const CREATE:String = "component:create";

		public var component:*;

		public function ComponentEvent(type:String, component:*)
		{
			super(type);
			this.component = component;
		}

		override public function clone():Event
		{
			return new ComponentEvent(type, component);
		}
	}
}
