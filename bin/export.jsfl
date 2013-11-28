var hasOwn = Object.prototype.hasOwnProperty;
var escapeable = /["\\\x00-\x1f\x7f-\x9f]/g;
var meta =
{
	'\b': '\\b',
	'\t': '\\t',
	'\n': '\\n',
	'\f': '\\f',
	'\r': '\\r',
	'"' : '\\"',
	'\\': '\\\\'
};
var HIGHEST = 9999;

var dom = fl.getDocumentDOM();
var lib = dom.library;

var currentItem;
var atlas = XML('<TextureAtlas />');
var bitmapsToExport = {};
var phasedItems = {};
var conf = {};
var currentNode = conf;
var tempBitmaps = [];
var exportGraphic;
var count = 0;

exportStarling();

function exportStarling()
{
	var toExport = [];
	for each(var item in lib.items)
	{
		if(item.linkageExportForAS)
		{
			toExport.push(item);
		}
	}
	for each(item in toExport)
	{
		if(item.itemType == 'button' || item.itemType == 'movie clip')
		{
			handleItem(item);
		}

		if(item.itemType == "bitmap")
		{
			addBitmap(item, false);
		}
	}
	exportBitmaps();
	atlas.@imagePath = dom.name + '.png';
	FLfile.write(dom.pathURI + ".json", encode(conf));
	FLfile.write(dom.pathURI + ".xml", atlas);
}

function deleteTempBitmaps()
{
	lib.selectItem(tempBitmaps[0]);
	for(var i = 1;i < tempBitmaps.length; i++)
	{
		lib.selectItem(tempBitmaps[i], false);
	}
	lib.deleteItem();
}

function handleItem(item)
{
	if(!phasedItems[item])
	{
		fl.trace("........" + item.name + "........")
		conf[item.name] = {};
		phasedItems[item.name] = item;
		lib.editItem(item.name);
		currentItem = item;
		selectTimeline();
	}
}

function selectTimeline()
{
	var timeline = dom.getTimeline();
	var layer;
	for(var i=0;i<timeline.layers.length;i++)
	{
		layer = timeline.layers[i];var index = 0;
		var locked = layer.locked;
		var visible = layer.visible;
		if(locked)
		{
			layer.locked = false;
		}
		if(!visible)
		{
			layer.visible = true;
		}
		do
		{
			fl.getDocumentDOM().getTimeline().setSelectedFrames(index, index);
			dom.selectNone();
			if(layer.frames[index].elements.length > 0)
			{
				handleFrame(layer.frames[index]);
			}
			index = nextKeyFrame(layer, index);
		}
		while(index != -1);
		layer.locked = locked;
		layer.visible = visible;
	}
}

function nextKeyFrame(layer, index)
{
	var nextIndex = layer.frames[index].startFrame + layer.frames[index].duration;
	if(nextIndex >= layer.frames.length)
	{
		return -1;
	}
	return nextIndex;
}

function handleFrame(frame)
{
	for each(var element in frame.elements)
	{
		if(element.elementType == 'instance')
		{
			var item = element.libraryItem;
			if(element.instanceType == 'bitmap')
			{
				addBitmap(item, false);
				addBitmapConf(element);
			}
			else if(element.instanceType == 'symbol')
			{
				var node = addSymbolConf(element);
				var c = currentItem;
				handleItem(item);
				lib.selectItem(c.name);
				lib.editItem();
				dom.getTimeline().setSelectedFrames(frame.startFrame, frame.startFrame);
				dom.selectNone();
				currentItem = c;
			}
		}
		else if(element.elementType == 'shape')
		{
			var bitmapInstance = generateBitmap(element);
			item = bitmapInstance.libraryItem;
			addBitmap(item, true);
			addBitmapConf(bitmapInstance);			
			//finally delete the bitmap instance from the stage(the item leaves in library)
			//do not change the original structure of the dom
			fl.getDocumentDOM().deleteSelection();
		}
	}
}


function generateBitmap(element)
{
	dom.selection = [element];
	dom.clipCopy();
	dom.clipPaste(true);
	dom.convertSelectionToBitmap();
	return dom.selection[0]
}

function exportBitmaps()
{
	lib.addNewItem('graphic', '__sui_temp');
	lib.selectItem('__sui_temp');
	lib.editItem();
	for each(var rect in bitmapsToExport)
	{
		lib.selectItem(rect.name);
		lib.addItemToDocument({x:0, y:0});
		var bitmapInstance = dom.selection[0];
		bitmapInstance.x = 0;
		bitmapInstance.y = 0;
		rect.obj = bitmapInstance;
	}
	var bound = packTextures(0,1,bitmapsToExport,false);
	dom.addNewRectangle({left:bound.width-1,top:bound.width-1,right:bound.width,bottom:bound.width},0, false, true);
	dom.setFillColor('#00000000');
	dom.selectAll();
	dom.convertSelectionToBitmap();
	
	var tempBitmap = dom.selection[0].libraryItem;
	tempBitmap.exportToFile(dom.pathURI + ".png");
	lib.selectItem(tempBitmap.name);
	lib.deleteItem();
	lib.selectItem('__sui_temp');
	lib.deleteItem();	
	deleteTempBitmaps();
}

function addSymbolConf(instance)
{
	var node = {};
	if(instance.symbolType == "movie clip")
	{
		node.type = "sprite";
	}
	else if(instance.symbolType == "button")
	{
		node.type = "button";
	}
	else if(instance.symbolType == "graphic")
	{
		node.type = "sprite";
	}
	conf[currentItem.name][getInstanceName(instance)] = node;
	copyInfo(instance, node);
	copyTransform(instance, node);
	return node;
}

function addBitmapConf(instance)
{
	var node = {type:'bitmap'};
	conf[currentItem.name][getInstanceName(instance)] = node;
	node.type = 'bitmap';
	copyInfo(instance, node);
	copyTransform(instance, node);
}

function getInstanceName(instance)
{
	return instance.name || ("instance" + (count++));
}

function copyInfo(instance, node)
{
	node.ref = instance.libraryItem.name;
	node.depth = instance.depth;
}

function copyTransform(instance, node)
{
	if(instance.x != 0)
	{
		node.x = instance.x;
	}
	if(instance.y != 0)
	{
		node.y = instance.y;
	}
	if(instance.scaleX != 1)
	{
		node.scaleX = Number(instance.scaleX.toFixed(2));
	}
	if(instance.scaleY != 1)
	{
		node.scaleY = Number(instance.scaleY.toFixed(2));
	}
	if(instance.skewX != 0)
	{
		node.skewX = Number(instance.skewX.toFixed(2));
	}
	if(instance.skewY != 0)
	{
		node.skewY = Number(instance.skewY.toFixed(2));
	}
	if(instance.transformX != 0)
	{
		node.pivotX = instance.transformX;
	}	
	if(instance.transformY != 0)
	{
		node.pivotY = instance.transformY;
	}	
}

function addBitmap(item, temp)
{
	if(bitmapsToExport[item.name] )
	{
		return;
	}
	bitmapsToExport[item.name] = {name:item.name};
	if(temp)
	{
		tempBitmaps.push(item.name);
	}
}

function packTextures(widthDefault, padding, rectMap, verticalSide)
{
	var rect;	
	var dimensions = 0;
	var rectList = []
	for each(rect in rectMap)
	{
		dimensions += rect.obj.hPixels * rect.obj.vPixels;
		rectList.push(rect);
	}
	//sort texture by size
	rectList.sort(sortRectList);
	
	if(!widthDefault)
	{
		//calculate width for Auto size
		widthDefault = Math.sqrt(dimensions);
	}

	widthDefault = getNearest2N(Math.max(rectList[0].obj.width + padding, widthDefault));
	
	var heightMax = HIGHEST;
	var remainAreaList = [];
	remainAreaList.push({x:0,y:0,width:widthDefault, height:heightMax});
	
	var isFit;
	var width;
	var height;
	
	var area;
	var areaPrev;
	var areaNext;
	var areaID;
	var rectID;
	do 
	{
		//Find highest blank area
		area = getHighestArea(remainAreaList);
		areaID = remainAreaList.indexOf(area);
		isFit = false;
		rectID = 0;
		for each(rect in rectList) 
		{
			//check if the area is fit
			width = rect.obj.hPixels + padding;
			height = rect.obj.vPixels + padding;
			if (area.width >= width && area.height >= height) 
			{
				isFit = true;
				break;
			}
			rectID ++;
		}
		
		if(isFit)
		{
			//place texture if size is fit
			rect.obj.x = area.x;
			rect.obj.y = area.y;
			var subTexture = XML('<SubTexture />');
			subTexture.@name = rect.name;
			subTexture.@x = rect.obj.x;
			subTexture.@y = rect.obj.y;
			subTexture.@width = rect.obj.hPixels;
			subTexture.@height = rect.obj.vPixels;
			atlas.appendChild(subTexture);
			rectList.splice(rectID, 1);
			remainAreaList.splice(
				areaID + 1,
				0, 
				{x:area.x + width, y:area.y, width:area.width - width, height:area.height}
			);
			area.y += height;
			area.width = width;
			area.height -= height;
			
			delete rect.name;
			delete rect.obj;
		}
		else
		{
			//not fit, don't place it, merge blank area to others toghther
			if(areaID == 0)
			{
				areaNext = remainAreaList[areaID + 1];
			}
			else if(areaID == remainAreaList.length - 1)
			{
				areaNext = remainAreaList[areaID - 1];
			}
			else
			{
				areaPrev = remainAreaList[areaID - 1];
				areaNext = remainAreaList[areaID + 1];
				areaNext = areaPrev.height <= areaNext.height?areaNext:areaPrev;
			}
			if(area.x < areaNext.x)
			{
				areaNext.x = area.x;
			}
			areaNext.width = area.width + areaNext.width;
			remainAreaList.splice(areaID, 1);
		}
	}
	while (rectList.length > 0);
	
	heightMax = getNearest2N(heightMax - getLowestArea(remainAreaList).height);
	return {width:widthDefault, height:heightMax};
}











////////////
/**
 * Helper function to correctly quote nested strings
 * @ignore
 */
function quoteString( string )
{
	if ( string.match( escapeable ) )
	{
		return '"' + string.replace( escapeable, function( a ) {
			var c = meta[a];
			if ( typeof c === 'string' ) {
				return c;
			}
			c = a.charCodeAt();
			return '\\u00' + Math.floor(c / 16).toString(16) + (c % 16).toString(16);
		}) + '"';
	}
	return '"' + string + '"';
};

function encode(obj)
{
	if ( obj === null ) {
		return 'null';
	}

	var type = typeof obj;

	if ( type === 'undefined' )
	{
		return undefined;
	}
	if ( type === 'number' || type === 'boolean' )
	{
		return '' + obj;
	}
	if ( type === 'string') {
		return quoteString( obj );
	}
	if ( type === 'object' )
	{
		if ( obj.constructor === Date )
		{
			var	month = obj.getUTCMonth() + 1,
				day = obj.getUTCDate(),
				year = obj.getUTCFullYear(),
				hours = obj.getUTCHours(),
				minutes = obj.getUTCMinutes(),
				seconds = obj.getUTCSeconds(),
				milli = obj.getUTCMilliseconds();

			if ( month < 10 ) {
				month = '0' + month;
			}
			if ( day < 10 ) {
				day = '0' + day;
			}
			if ( hours < 10 ) {
				hours = '0' + hours;
			}
			if ( minutes < 10 ) {
				minutes = '0' + minutes;
			}
			if ( seconds < 10 ) {
				seconds = '0' + seconds;
			}
			if ( milli < 100 ) {
				milli = '0' + milli;
			}
			if ( milli < 10 ) {
				milli = '0' + milli;
			}
			return '"' + year + '-' + month + '-' + day + 'T' +
				hours + ':' + minutes + ':' + seconds +
				'.' + milli + 'Z"';
		}
		if ( obj.constructor === Array ) {
			var ret = [];
			for ( var i = 0; i < obj.length; i++ ) {
				ret.push( encode( obj[i] ) || 'null' );
			}
			return '[' + ret.join(',') + ']';
		}
		var	name,
			val,
			pairs = [];

		for ( var k in obj ) {
			// Only include own properties,
			// Filter out inherited prototypes
			if ( !hasOwn.call( obj, k ) ) {
				continue;
			}

			// Keys must be numerical or string. Skip others
			type = typeof k;
			if ( type === 'number' ) {
				name = '"' + k + '"';
			} else if (type === 'string') {
				name = quoteString(k);
			} else {
				continue;
			}
			type = typeof obj[k];

			// Invalid values like these return undefined
			// from toJSON, however those object members
			// shouldn't be included in the JSON string at all.
			if ( type === 'function' || type === 'undefined' ) {
				continue;
			}
			val = encode( obj[k] );
			pairs.push( name + ':' + val );
		}
		return '{' + pairs.join( ',' ) + '}';
	};
}


function sortRectList(rect1, rect2)
{
	var v1 = rect1.obj.hPixels + rect1.obj.vPixels;
	var v2 = rect2.obj.hPixels + rect2.obj.vPixels;
	if (v1 == v2) 
	{
		return rect1.obj.hPixels > rect2.obj.hPixels?-1:1;
	}
	return v1 > v2?-1:1;
}

function getNearest2N(_n)
{
	_n = parseInt(_n.toFixed(0));
	return _n & _n - 1?1 << _n.toString(2).length:_n;
}

function getHighestArea(areaList)
{
	var height= 0;
	var areaHighest;
	for each(var area in areaList) 
	{
		if (area.height > height) 
		{
			height = area.height;
			areaHighest = area;
		}
	}
	return areaHighest;
}

function getLowestArea(areaList)
{
	var height = HIGHEST;
	var areaLowest;
	for each(var area in areaList) 
	{
		if (area.height < height) 
		{
			height = area.height;
			areaLowest = area;
		}
	}
	return areaLowest;
}