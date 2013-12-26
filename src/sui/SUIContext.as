package sui
{
	import flash.events.EventDispatcher;

	[Event(name="component:create", type="sui.events.ComponentEvent")]
	public class SUIContext extends EventDispatcher
	{
		public var config:*;

		public var errorHandler:ErrorHandler = new ErrorHandler;

		public var assetManager:*;

		public function feedJSON(json:*):void
		{
			if (json is String)
			{
				config = JSON.parse(json);
			}
			else
			{
				config = json;
			}
		}
	}
}
