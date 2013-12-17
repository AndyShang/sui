package sui.logging
{

	public interface ILoggingTarget
	{
		function write(clazz:Class, level:int, str:String):void;
	}
}
