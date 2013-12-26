package sui
{

	public class ErrorHandler
	{
		private var handlers:Vector.<Function> = new Vector.<Function>;

		public function handle(err:Error):Boolean
		{
			for each (var func:Function in handlers)
			{
				if (func.call(null, err))
				{
					return true;
				}
			}
			return false;
		}

		public function addHandler(func:Function):void
		{
			var index:int = handlers.indexOf(func);

			if (index == -1)
			{
				handlers.push(func);
			}
		}

		public function removeHandler(func:Function):void
		{
			var index:int = handlers.indexOf(func);

			if (index != -1)
			{
				handlers.splice(index, 1);
			}
		}
	}
}
