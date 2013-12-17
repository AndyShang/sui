package sui.logging
{
	import flash.utils.Dictionary;

	public class Logger
	{
		public static var target:ILoggingTarget = new TraceTarget;

		public static const DEBUG:int = 1;

		public static const INFO:int = 2;

		public static const ERROR:int = 3;

		private static var clazzDic:Dictionary = new Dictionary(true);

		public static function get(obj:*):Logger
		{
			if (!(obj is Class))
			{
				obj = obj.constructor;
			}
			if (clazzDic[obj] == null)
			{
				clazzDic[obj] = new Logger(obj);
			}
			return clazzDic[obj];
		}

		private var clazz:Class;

		public function Logger(clazz:Class)
		{
			this.clazz = clazz;
		}

		public function log(str:String, level:int = INFO):void
		{
			target.write(clazz, level, str);
		}

		public function error(str:String):void
		{
			log(str, ERROR)
		}

		public function info(str:String):void
		{
			log(str, INFO)
		}

		public function debug(str:String):void
		{
			log(str, DEBUG)
		}
	}
}
