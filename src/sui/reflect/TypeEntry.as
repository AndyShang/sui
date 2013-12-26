package sui.reflect
{
	import flash.utils.getDefinitionByName;

	public class TypeEntry
	{
		public var metadatas:Object = {};

		public var name:String;

		public var type:Class;

		public var typeName:String;

		public function TypeEntry(name:String, typeName:String)
		{
			this.name = name;
			this.typeName = typeName;

			if (typeName != "void" && typeName != "*")
			{
				type = getDefinitionByName(typeName) as Class;
			}
		}

		public function parseMetadata(list:XMLList):void
		{
			for each (var node:XML in list)
			{
				var m:Metadata = new Metadata(node.@name);
				m.parseArgs(node..arg);
				metadatas[m.name] = m;
			}
		}
	}
}
