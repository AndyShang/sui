package sui
{
	import flash.events.EventDispatcher;
	import starling.utils.AssetManager;

	[Event(name="component:create", type="sui.events.ComponentEvent")]
	public class SUIContext extends EventDispatcher
	{
		public var assetManager:AssetManager;

		public var config:*;

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
