package sui.reflect
{
    import flash.system.ApplicationDomain;

    public class TypeEntry
    {
        public var metadatas:Object = {};

        public var name:String;

        public var type:Class;

        public function TypeEntry(name:String, type:String)
        {
            this.name = name;
            if (type != "void" && type != "*")
            {
                this.type = //
                    ApplicationDomain.currentDomain.getDefinition(type) as Class;
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
