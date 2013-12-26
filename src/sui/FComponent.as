package sui
{
	import flash.display.Sprite;
	import flash.events.*;
	import sui.events.ComponentEvent;
	import sui.reflect.Metadata;

	public class FComponent extends Sprite
	{
		public var skin:*;

		public function FComponent(skin:*)
		{
			this.skin = skin;
			SUI.context.dispatchEvent(new ComponentEvent(ComponentEvent.CREATE, this));
		}
	}
}
