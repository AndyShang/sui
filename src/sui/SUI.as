package sui
{
	import avmplus.getQualifiedClassName;

	public class SUI
	{
		public static var context:SUIContext;

		private static var instance:SUI;

		public static function init(context:SUIContext):SUI
		{
			return instance = new SUI(context);
		}

		private var plugins:Vector.<IPlugin>;

		public function SUI(context:SUIContext)
		{
			if (instance)
			{
				throw new Error("SUI is singleton")
			}
			SUI.context = context;
			this.plugins = new Vector.<IPlugin>();
		}

		public function initPlugin(plugin:IPlugin):IPlugin
		{
			var qName:String = getQualifiedClassName(plugin).replace(/::/g, ".");

			if (retrievePlugin(plugin["constructor"]) == null)
			{
				plugin.initialize(context);
				plugins.push(plugin);
			}
			return (plugin);
		}

		public function uninstallPlugin(plugin:*):void
		{
			if (plugin is Class)
			{
				uninstallPlugin(retrievePlugin(plugin));
			}

			if (plugin != null)
			{
				var index:int = plugins.indexOf(plugin);

				if (index != -1)
				{
					plugins.splice(index, 1);
				}
			}
		}

		public function retrievePlugin(clazz:Class):IPlugin
		{
			for each (var plugin:IPlugin in plugins)
			{
				if (plugin is clazz)
				{
					return (plugin);
				}
			}
			return null;
		}
	}
}
