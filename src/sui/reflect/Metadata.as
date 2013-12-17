package sui.reflect
{

	public class Metadata
	{
		public var name:String;

		private var args:Object = {};

		public function Metadata(name:String)
		{
			this.name = name;
		}

		public function get(name:String):*
		{
			return args[name];
		}

		public function has(name:String):Boolean
		{
			return args[name] != null;
		}

		public function parseArgs(list:XMLList):void
		{
			for each (var node:XML in list)
			{
				var key:String = node.@key;
				var value:String = String(node.@value);
				if (value == "true")
				{
					args[key] = true;
				}
				else if (value == "false")
				{
					args[key] = false;
				}
				else
				{
					args[key] = value;
				}
			}
		}
	}
}
