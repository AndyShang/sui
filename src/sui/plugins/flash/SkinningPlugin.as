package sui.plugins.flash
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getDefinitionByName;
	import mx.utils.StringUtil;
	import sui.FComponent;
	import sui.ErrorCodes;
	import sui.IPlugin;
	import sui.SUI;
	import sui.SUIContext;
	import sui.events.ComponentEvent;
	import sui.reflect.Metadata;
	import sui.reflect.Property;
	import sui.reflect.Type;

	public class SkinningPlugin implements IPlugin
	{
		private var context:SUIContext;

		private var config:*;

		public function initialize(context:SUIContext):void
		{
			this.context = context;
			config = context.config;
			//listen the onCreate event to initialize component
			context.addEventListener(ComponentEvent.CREATE, onCreate);
		}

		public function onCreate(event:ComponentEvent):void
		{
			var component:FComponent = event.component;
			buildSkin(component);
			var skin:* = component.skin;

			for each (var prop:Property in Type.get(component).variables)
			{
				if (component[prop.name] == null)
				{
					processSkinMetadata(prop);
				}
			}
			//
			function processSkinMetadata(prop:Property):void
			{
				var name:String;
				var clazz:Class;
				var x:int;
				var y:int;
				var skinMetadata:Metadata = prop.metadatas["Skin"];

				if (skinMetadata != null)
				{
					name = prop.name;
					clazz = prop.type;

					if (skin.hasOwnProperty(name))
					{
						if ((skin[name] is clazz))
						{
							component[name] = skin[name];
						}
						else
						{
							x = skin[name].x;
							y = skin[name].y;
							component[name] = new clazz(skin[name]);
							component.addChild(component[name]);
							component[name].x = x;
							component[name].y = y;
						}
					}
					else
					{
						if (!skinMetadata.has("optional") || !skinMetadata.get("optional"))
						{
							SUI.throwError(new ReferenceError( //
										   { field: prop,
											   component: component,
											   toString: function():String
											   {
												   return StringUtil.substitute( //
													   "{0} is required in {1} but not found in skin {2}", //
													   [ name, (component["constructor"] + ""),
														 skin.name ]);
											   }}, //
										   ErrorCodes.REQUIRED_SKIN_NOT_FOUND));
						}
					}
				}
			}
		}

		private function buildSkin(comp:FComponent):DisplayObject
		{
			var skin:* = comp.skin;

			if (skin != null)
			{
				if (skin is Class)
				{
					skin = new (skin);
				}
				else if (skin is String)
				{
					skin = get(skin);
				}
			}

			if (skin is DisplayObject)
			{
				comp.x = skin.x;
				comp.y = skin.y;

				if ((skin is DisplayObjectContainer))
				{
					while (skin.numChildren > 0)
					{
						comp.addChildAt(skin.getChildAt((skin.numChildren - 1)), 0);
					}
				}
				else
				{
					comp.addChild(skin);
					skin.x = 0;
					skin.y = 0;
				}
			}
			comp.skin = skin;
			return skin;
		}

		public function get(skin:String):DisplayObject
		{
			try
			{
				return new (getDefinitionByName(skin))();
			}
			catch (error:Error)
			{
			}
			return null;
		}
	}
}
