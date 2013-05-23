package 
{

	import flash.system.*;
	import flash.text.*;
	import fl.controls.*;
	import fl.core.*;
	import flash.events.*;
	import flash.net.*;
	import flash.display.*;
	import flash.utils.*;
	import flash.geom.*;
	import JSON;
	import MyMultiMap;
	import algoGuillotine;
	import algoMaxRects;


	public class PixelPackFlash extends MovieClip
	{
		private var worker:Worker = null;
		private var imageVec:Vector.<BitmapData> = new Vector.<BitmapData>;
		
		private var queueImages:Vector.<FileReference> = new Vector.<FileReference>;
		private var queueByteArray:Vector.<ByteArray> = new Vector.<ByteArray>;
		
		public var btnProcess:Button;
		public var btnAddFiles:Button;
		public var btnRemoveFiles:Button;
		public var listFiles:List;
		public var radioAlgo:RadioButtonGroup;

private var fileRefL:FileReferenceList = new FileReferenceList();

		public function PixelPackFlash()
		{
			//addEventListener(Event.ENTER_FRAME, onEnterFrame);
			fileRefL.addEventListener(Event.SELECT, onSelectFile);
			fileRefL.addEventListener(Event.CANCEL, onSelectFileCancel);
			//btnProcess.enabled = false;
			btnsEnabled(true);
			btnProcess.addEventListener(MouseEvent.CLICK, onProcess);
			btnAddFiles.addEventListener(MouseEvent.CLICK, onAddFiles);
			//btnRemoveFiles.addEventListener(MouseEvent.CLICK, onRemoveFiles);
			
			radioAlgo = RadioButtonGroup.getGroup("radioAlgo");
		}
		
		public function btnsEnabled(b:Boolean)
		{
			if(b && imageVec.length && queueImages.length==0 && queueByteArray.length==0)btnProcess.enabled = true;
			else btnProcess.enabled = false;
			btnAddFiles.enabled = btnRemoveFiles.enabled = b;
		}

		public function onProcess(e:MouseEvent):void
		{
			btnsEnabled(false);
			startPacking();
			btnsEnabled(true);
		}
		
		public function onAddFiles(e:MouseEvent):void
		{
			//var fileRefL:FileReferenceList = new FileReferenceList();
			//fileRefL.addEventListener(Event.SELECT, onSelectFile);
			//fileRefL.addEventListener(Event.CANCEL, onSelectFileCancel);
			fileRefL.browse([new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png")]);
		}

		public function onSelectFileCancel(e:Event):void
		{
			//var fileRefL:FileReferenceList = FileReferenceList(e.target);
			//fileRefL.removeEventListener(Event.SELECT, onSelectFile);
			//fileRefL.removeEventListener(Event.CANCEL, onSelectFileCancel);
		}
		
		public function nextQueueFile():void
		{
			if(queueImages.length)
			{
				btnsEnabled(false);
			//	btnProcess.enabled = false;
				try{
					var fileref:FileReference = queueImages.pop();
					fileref.addEventListener(Event.COMPLETE, onCompleteFile);
					fileref.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
					fileref.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecError);
					fileref.load();
				} catch (error:Error) {
				}
			} else if (queueByteArray.length) {
				btnsEnabled(false);
				//btnProcess.enabled = false;
				var loader:Loader = new Loader();
				loader.loadBytes(queueByteArray.pop());
				loader.contentLoaderInfo.addEventListener(Event.INIT, onInitLoader);
			} else {
				btnsEnabled(true);
				//btnProcess.enabled = true;
			}
		}

		public function onSelectFile(e:Event):void
		{
			//var fileRefL:FileReferenceList = FileReferenceList(e.target);
			//fileRefL.removeEventListener(Event.SELECT, onSelectFile);
			//fileRefL.removeEventListener(Event.CANCEL, onSelectFileCancel);
			var fileLen:uint = fileRefL.fileList.length;
			var fileref:FileReference;
			for(var i:uint = 0; i<fileLen; i++)
			{
			//for each (var fileref:FileReference in fileRefL.fileList)
				fileref = fileRefL.fileList[i];
				queueImages.push(fileref);
			}
			nextQueueFile();
		}
		public function onLoadSecError(e:SecurityErrorEvent):void
		{
			var fileref:FileReference = FileReference(e.target);
			fileref.removeEventListener(Event.COMPLETE, onCompleteFile);
			fileref.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			fileref.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecError);
			nextQueueFile();
		}
		public function onLoadIOError(e:IOErrorEvent):void
		{
			var fileref:FileReference = FileReference(e.target);
			fileref.removeEventListener(Event.COMPLETE, onCompleteFile);
			fileref.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			fileref.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecError);
			nextQueueFile();
		}

		public function onCompleteFile(e:Event):void
		{
			var fileref:FileReference = FileReference(e.target);
			fileref.removeEventListener(Event.COMPLETE, onCompleteFile);
			fileref.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			fileref.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecError);
			queueByteArray.push(fileref.data);
			nextQueueFile();
		}
		public function onInitLoader(e:Event):void
		{
			var loadInfo:LoaderInfo = e.target as LoaderInfo;
			var newBmp:BitmapData = new BitmapData(loadInfo.width, loadInfo.height, true, 0/*Transparent*/);
			newBmp.draw(e.target.content, null, null, null, null, false);
			newBmp = trim(newBmp);
			imageVec.push(newBmp);
			listFiles.addItem({label:"Image ("+newBmp.width+", "+newBmp.height+")"+imageVec.length});
			nextQueueFile();
		}
		
		public function trim(srcBmp:BitmapData):BitmapData
		{
			var r:Rectangle = srcBmp.getColorBoundsRect(0xFF000000, 0, false);
			var newBmp:BitmapData = new BitmapData(r.width, r.height, true, 0/*Transparent*/);
			newBmp.copyPixels(srcBmp, r, new Point(0,0));
			return newBmp;
		}

		public function startPacking():void
		{
			if(queueImages.length || queueByteArray.length)return;
			var areaSum:int = 0;
			var images:Vector.<t_myVector2> = new Vector.<t_myVector2>();
			for (var i:uint=0; i<imageVec.length; i++)
			{
				var w:int = imageVec[i].width+1;
				var h:int = imageVec[i].height+1;
				images.push(new t_myVector2(w, h));
				areaSum += w * h;
			}
			
			var side:int = Math.sqrt(areaSum);
			var nextHigh:int = nexthigher(side);
			var nextNear:int = nearestpower2(side);
			var size:t_myVector2 = new t_myVector2(nextHigh, nextNear);
			var boxes:MyMultiMap;
			
//			var fine:bool = 0;
		/*	listFiles.addItem({label:"images start"});
				for(var k:uint=0; k<images.length; k++)
				{
					listFiles.addItem({label:"  "+images[k].toString()});
				}
			listFiles.addItem({label:"images end"});*/
			
			switch(int(radioAlgo.selectedData.valueOf()))
			{
				case 1:
					boxes = algoMaxRects.pack(images, size);
					if(boxes==null)
					{
						size.y = nextHigh;
						boxes = algoMaxRects.pack(images, size);
					}
					break;
				case 3:
					boxes = algoGuillotine.pack(images, size);
					if(boxes==null)
					{
						size.y = nextHigh;
						boxes = algoGuillotine.pack(images, size);
					}
					break;
			}
			if(!boxes)throw new Error("Algo Error");
			
			/*listFiles.addItem({label:"boxes start"});
			for(var s:String in boxes.m_key)
			{
				listFiles.addItem({label:s});
				var v:Vector.<t_myVector2> = boxes.m_key[s];
				for(var j:uint=0; j<v.length; j++)
				{
					listFiles.addItem({label:"  "+v[j].toString()});
				}
			}
			listFiles.addItem({label:"boxes end"});*/
			
			var bmpSheet:BitmapData = new BitmapData(size.x, size.y, true, 0/*Transparent*/);
			
			var rootNode:Object = {sizex:bmpSheet.width, sizey:bmpSheet.height};
			
			for(i=0; i<imageVec.length; i++)
			{
				w = imageVec[i].width+1;
				h = imageVec[i].height+1;
				var imageSize:t_myVector2 = new t_myVector2(w, h);
				var pos:t_myVector2 = boxes.getAndDelete(imageSize.toString());
				bmpSheet.copyPixels(imageVec[i], new Rectangle(0,0,imageVec[i].width,imageVec[i].height), new Point(pos.x,pos.y));
				var imgNode:Object = {x:pos.x, y:pos.y, sizex:imageVec[i].width, sizey:imageVec[i].height};
				rootNode["image"+i] = imgNode;
			}
			bmpSheet = trim(bmpSheet);
			
			var pngFile:FileReference = new FileReference();
			pngFile.addEventListener(Event.COMPLETE, onCompletePNGSave);
			pngFile.addEventListener(Event.CANCEL, onCancelPNGSave);
			pngFile.addEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
			pngFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSaveSecError);
			pngFile.save(bmpSheet.encode(new Rectangle(0,0,bmpSheet.width,bmpSheet.height), new PNGEncoderOptions()), "sheet.png");
			
			jsonRootNode = rootNode;
			
			//var jsonFile:FileReference = new FileReference();
			//jsonFile.save(JSON.stringify(rootNode), "sheet.json");
		}
		
		private var jsonRootNode:Object;
		
		public function onCompletePNGSave(e:Event):void
		{
			var fileref:FileReference = FileReference(e.target);
			fileref.removeEventListener(Event.COMPLETE, onCompletePNGSave);
			fileref.removeEventListener(Event.CANCEL, onCancelPNGSave);
			fileref.removeEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
			fileref.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSaveSecError);
			
			var jsonFile:FileReference = new FileReference();
			jsonFile.save(JSON.stringify(jsonRootNode), "sheet.json");
		}
		public function onCancelPNGSave(e:Event):void
		{
			var fileref:FileReference = FileReference(e.target);
			fileref.removeEventListener(Event.COMPLETE, onCompletePNGSave);
			fileref.removeEventListener(Event.CANCEL, onCancelPNGSave);
			fileref.removeEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
			fileref.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSaveSecError);
		}
		public function onSaveSecError(e:SecurityErrorEvent):void
		{
			var fileref:FileReference = FileReference(e.target);
			fileref.removeEventListener(Event.COMPLETE, onCompletePNGSave);
			fileref.removeEventListener(Event.CANCEL, onCancelPNGSave);
			fileref.removeEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
			fileref.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSaveSecError);
		}
		public function onSaveIOError(e:IOErrorEvent):void
		{
			var fileref:FileReference = FileReference(e.target);
			fileref.removeEventListener(Event.COMPLETE, onCompletePNGSave);
			fileref.removeEventListener(Event.CANCEL, onCancelPNGSave);
			fileref.removeEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
			fileref.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSaveSecError);
		}

		public function nearestpower2(v:int):int
		{
			var k:int;

			if (v == 0)return 1;

			for (k = 31; ((1 << k) & v) == 0; k--)
			{}

			if (((1 << (k - 1)) & v) == 0)return 1 << k;

			return (1 << (k + 1));
		}

		public function nexthigher(k:int):int
		{
			k = k - 1;
			for (var i:int=1; i<32; i=i<<1)k = k | k >> i;
			return k+1;
		}

	}

}