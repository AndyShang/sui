package sui.plugins.flash
{
	import avmplus.getQualifiedClassName;
	import avmplus.getQualifiedSuperclassName;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	import sui.FComponent;
	import sui.ErrorCodes;
	import sui.IPlugin;
	import sui.SUIContext;
	import sui.events.ComponentEvent;
	import sui.reflect.Metadata;
	import sui.reflect.Property;
	import sui.reflect.Type;

	public class ListCompHelper implements IPlugin
	{
		public function initialize(context:SUIContext):void
		{
			context.errorHandler.addHandler(errorHandler);
			//listen the onCreate event to initialize component
			context.addEventListener(ComponentEvent.CREATE, onCreate, false, int.MIN_VALUE);
		}

		protected function onCreate(event:ComponentEvent):void
		{
			var component:FComponent = event.component;
			var skin:* = component.skin;
			var type:Type = Type.get(component);

			for each (var prop:Property in type.variables)
			{
				if (component[prop.name] == null)
				{
					processSkinMetadata(prop);
				}
			}
			function processSkinMetadata(prop:Property):void
			{
				var skinMetadata:Metadata = prop.metadatas["Skin"];
				var vectorType:Class = prop.type;
				var instanceTypeName:String;
				var instanceType:Class;
				var qName:String = getQualifiedClassName(vectorType);
				var superQName:String = getQualifiedSuperclassName(vectorType);
				var vector:*;

				if (superQName == "__AS3__.vec::Vector.<*>")
				{
					vector = new vectorType;
					component[prop.name] = vector;
					instanceTypeName = qName.substring(qName.indexOf("<") + 1, qName.lastIndexOf(">"));
					instanceType = getDefinitionByName(instanceTypeName) as Class;
				}
				else if (qName == "Array")
				{
					vector = new vectorType;
					component[prop.name] = vector;
					instanceType = Object;
				}
				//find instances
				findSkinPartInstances()

				if (vector is Array)
				{
					vector.sortOn("name");
				}
				else
				{
					vector.sort(function(c1:DisplayObject, c2:DisplayObject):int
					{
						if (c1.name > c2.name)
						{
							return 1;
						}

						if (c1.name < c2.name)
						{
							return -1;
						}
						else
						{
							return 0;
						}
					})
				}
				//
				function findSkinPartInstances():void
				{
					for (var i:int = 0; i < component.numChildren; i++)
					{
						var child:DisplayObject = component.getChildAt(i);

						if (isMatch(child.name, skinMetadata.get("prefix")))
						{
							if (child is instanceType)
							{
								vector.push(child);
							}
							else
							{
								var x:int = child.x;
								var y:int = child.y;
								child = new instanceType(child);
								vector.push(child);
								component.addChild(child);
								child.x = x;
								child.y = y;
							}
						}
					}
				}
			}
		}

		private function isMatch(name:String, pattern:String):Boolean
		{
			return name.indexOf(pattern) == 0
		}

		private function errorHandler(err:Error):Boolean
		{
			if (err.errorID == ErrorCodes.REQUIRED_SKIN_NOT_FOUND)
			{
				var prop:Property = err.message.field;
				var type:Class = prop.type;
				var superQName:String = getQualifiedSuperclassName(type);

				if (prop.metadatas["Skin"].has("prefix") && //
					(superQName == "__AS3__.vec::Vector.<*>" || prop.typeName == "Array"))
				{
					return true;
				}
			}
			return false;
		}
	}
}
