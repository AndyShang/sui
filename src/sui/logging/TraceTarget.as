package sui.logging
{

    public class TraceTarget implements ILoggingTarget
    {
        public function write(clazz:Class, level:int, str:String):void
        {
            trace("[" + getLevelString(level) + "]" + clazz + str)
        }

        public function getLevelString(code:int):String
        {
            switch (code)
            {
                case Logger.DEBUG:
                    return "Debug";
                case Logger.INFO:
                    return "Info";
                case Logger.ERROR:
                    return "Error";
                default:
                    return "Custom"
            }
        }
    }
}
