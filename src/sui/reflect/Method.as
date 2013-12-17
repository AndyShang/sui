package sui.reflect
{

    public class Method extends TypeEntry
    {
        public var parameters:Array = [];

        public function Method(xml:XML)
        {
            super(String(xml.@name), String(xml.@returnType));
            parseMetadata(xml.metadata);
            parseParameter(xml.parameter);
        }

        protected function parseParameter(xmlList:XMLList):void
        {
            for each (var param:XML in xmlList)
            {
                parameters[int(param.@index) - 1] = String(param.@type);
            }
        }
    }
}
