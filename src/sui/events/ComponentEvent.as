package sui.events
{
	import flash.events.Event;
	import sui.Component;

	public class ComponentEvent extends Event
	{
		public static const CREATE:String = "component:create";

		public var component:Component;

		public function ComponentEvent(type:String, component:Component)
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
