package sui.reflect
{

    public class Property extends TypeEntry
    {
        public function Property(xml:XML)
        {
            super(String(xml.@name), String(xml.@type));
            parseMetadata(xml.metadata);
        }
    }
}
