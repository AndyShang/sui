package sui
{
	import flash.events.*;
	
	import starling.display.Sprite;
	
	import sui.events.ComponentEvent;
	import sui.reflect.Metadata;

	public class SComponent extends Sprite
	{
		public var skin:*;

		public function SComponent(skin:*)
		{
			this.skin = skin;
			SUI.context.dispatchEvent(new ComponentEvent(ComponentEvent.CREATE, this));
		}

		public function setVariableSkin(name:String, skin:*, metadata:Metadata):void
		{
			this[name] = skin;

			if (skin is SComponent)
			{
				SComponent(skin).setMetadata(metadata);
			}
		}

		protected function setMetadata(metadata:Metadata):void
		{
		}
	}
}
