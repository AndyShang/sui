package sui.plugins.starling
{
	import mx.utils.StringUtil;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.AssetManager;
	import sui.ErrorCodes;
	import sui.IPlugin;
	import sui.SComponent;
	import sui.SUI;
	import sui.SUIContext;
	import sui.events.ComponentEvent;
	import sui.reflect.Metadata;
	import sui.reflect.Property;
	import sui.reflect.Type;

	public class SkinningPlugin implements IPlugin
	{
		private var context:SUIContext;

		private var assetManager:AssetManager;

		private var config:*;

		public function initialize(context:SUIContext):void
		{
			this.context = context;
			assetManager = context.assetManager;
			config = context.config;
			//listen the onCreate event to initialize component
			context.addEventListener(ComponentEvent.CREATE, onCreate);
		}

		public function onCreate(event:ComponentEvent):void
		{
			var skin:*;
			var variable:Property;
			var component:SComponent = event.component;
			var type:Type = Type.get(component)
			skin = buildSkin(component);

			for each (variable in type.variables)
			{
				processSkinMetadata(variable);
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
							component.setVariableSkin(name, skin[name], skinMetadata);
						}
						else
						{
							x = skin[name].x;
							y = skin[name].y;
							component.setVariableSkin(name, new clazz(skin[name]), skinMetadata);
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

		private function buildSkin(comp:SComponent):DisplayObject
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
			var conf:Object = config[skin];
			var res:Sprite = new Sprite;

			for (var name:String in conf)
			{
				createOn(res, conf[name]);
			}
			return res;
		}

		private function createOn(parent:*, conf:Object):DisplayObject
		{
			var res:*;

			if (conf.type == "bitmap")
			{
				res = new Image(assetManager.getTexture(conf.ref));
			}
			else if (conf.type == "sprite")
			{
				res = new Sprite;

				for (var name:String in config[conf.ref])
				{
					createOn(res, config[conf.ref][name]);
				}
			}
			else if (conf.type == "button")
			{
				res = new Sprite;
					//				var button:Button = new Button();
					//				res = button;
					//				button.upState = conf.ref;
					//				button.downState;
			}
			parent.addChild(res);
			res.x = conf.x || 0;
			res.y = conf.y || 0;
			res.scaleX = conf.scaleX || 1;
			res.scaleY = conf.scaleY || 1;
			res.skewX = conf.skewX || res.skewX;
			res.skewY = conf.skewY || res.skewY;
			return res;
		}
	}
}
