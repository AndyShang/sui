package sui.reflect
{
    import flash.utils.Dictionary;
    import flash.utils.describeType;

    public class Type
    {
        private static var descriptionCache:Dictionary = new Dictionary();

        public static function get(object:*):Type
        {
            var factory:Class;
            if (object is Class)
            {
                factory = object;
            }
            else
            {
                factory = object.constructor;
            }

            if (descriptionCache[factory] == null)
            {
                var description:Type = new Type(factory);
                descriptionCache[factory] = description;
            }

            return descriptionCache[factory];
        }

        public var variables:Object = {};

        public var accessors:Object = {};

        public var methods:Object = {};

        public function Type(factory:Class)
        {
            var typeInfo:XML = describeType(factory);
            parsePropertiy(accessors, typeInfo.factory.accessor);
            parsePropertiy(variables, typeInfo.factory.variable);
            parseMethod(typeInfo.factory.method);
        }

        private function parsePropertiy(container:Object, xmlList:XMLList):void
        {
            for each (var node:XML in xmlList)
            {
                var p:Property = new Property(node);
                container[p.name] = p;
            }
        }

        private function parseMethod(list:XMLList):void
        {
            for each (var node:XML in list)
            {
                var m:Method = new Method(node);
                methods[m.name] = m;
            }
        }
    }
}
