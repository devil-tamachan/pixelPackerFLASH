package 
{
  import MyMultiMap;
  import t_myVector2;
  import t_myBox;
  import flash.utils.ByteArray;
  import fl.controls.*;
  
  public class algoMaxRects
  {
    public function algoMaxRects()
    {
    }

    public static function myClone(src:Vector.<t_myVector2>):Vector.<t_myVector2>
    {
      var retVec:Vector.<t_myVector2> = new Vector.<t_myVector2>();
      for(var i:uint=0; i<src.length; i++)
      {
	retVec[i] = src[i].clone();
      }
      return retVec;
    }

    public static function pack(temp:Vector.<t_myVector2>, size:t_myVector2):MyMultiMap
    {
      var freeBoxes:Vector.<t_myBox> = new Vector.<t_myBox>;
      freeBoxes.push(new t_myBox(0,0,size.x,size.y));

      var rects:Vector.<t_myVector2> = myClone(temp);

      var boxes:MyMultiMap = new MyMultiMap();

      var minRects:t_myVector2;
      var minFreeBoxes:t_myBox;

      while (rects.length > 0)
      {
	var minRectsIndex:int = -1;
	var minFreeBoxesIndex:int = -1;
        var min:int = Math.max(size.x, size.y);
        for (var i:uint = 0; i<rects.length; i++)
        {
          var v:t_myVector2 = rects[i];
          for (var j:uint=0; j<freeBoxes.length; j++)
          {
            var box:t_myBox = freeBoxes[j];
            var distance:int = Math.min(box.m_size.y - v.y, box.m_size.x - v.x);
            if (distance < 0) continue;
            if (distance < min)
            {
              min = distance;
              minRects = v;
              minRectsIndex = i;
              minFreeBoxes = box;
              minFreeBoxesIndex = j;
            }
          }
        }
        if(minRectsIndex==-1 || minFreeBoxesIndex==-1)return null;//new MyMultiMap();
        
        var insertedBox:t_myBox = t_myBox.t_myBoxFromVec2(minFreeBoxes.m_pos.clone(), minRects.clone());
        boxes.insert(minRects.toString(), minFreeBoxes.m_pos.clone());
        
        var tempbox:t_myBox = new t_myBox(minFreeBoxes.m_pos.x + minRects.x, minFreeBoxes.m_pos.y + 0, minFreeBoxes.m_size.x - minRects.x, minFreeBoxes.m_size.y);
        var tempbox2:t_myBox = new t_myBox(minFreeBoxes.m_pos.x + 0, minFreeBoxes.m_pos.y + minRects.y, minFreeBoxes.m_size.x, minFreeBoxes.m_size.y - minRects.y);
        freeBoxes.splice(minFreeBoxesIndex, 1);
        freeBoxes.unshift(tempbox2, tempbox);
	rects.splice(minRectsIndex, 1);
        
        var a1:t_myVector2 = insertedBox.m_pos.clone();
        var a2:t_myVector2 = new t_myVector2(insertedBox.m_pos.x + insertedBox.m_size.x, insertedBox.m_pos.y);
        var a3:t_myVector2 = new t_myVector2(insertedBox.m_pos.x + insertedBox.m_size.x, insertedBox.m_pos.y + insertedBox.m_size.y);
        var a4:t_myVector2 = new t_myVector2(insertedBox.m_pos.x                       , insertedBox.m_pos.y + insertedBox.m_size.y);
        
        for (i=0; i<freeBoxes.length; i++)
        {
		var cFreeBoxes:t_myBox = freeBoxes[i];
		
		var b1:t_myVector2 = cFreeBoxes.m_pos.clone();
		var b2:t_myVector2 = new t_myVector2(cFreeBoxes.m_pos.x + cFreeBoxes.m_size.x,  cFreeBoxes.m_pos.y);
		var b3:t_myVector2 = new t_myVector2(cFreeBoxes.m_pos.x + cFreeBoxes.m_size.x,  cFreeBoxes.m_pos.y + cFreeBoxes.m_size.y);
		var b4:t_myVector2 = new t_myVector2(cFreeBoxes.m_pos.x                      ,  cFreeBoxes.m_pos.y + cFreeBoxes.m_size.y);
		
		if ((a1.x >= b3.x) || (a1.y >= b3.y) || (a3.x <= b1.x) || (a3.y <= b1.y))continue;
		
		if ((a1.x > b1.x) /*  && (a1.x < b3.x) */) // If there is a chance that line a1,a2 is in the shape b
		{
			freeBoxes.unshift(new t_myBox(cFreeBoxes.m_pos.x, cFreeBoxes.m_pos.y, a1.x - b1.x, cFreeBoxes.m_size.y));
			i++;
		}
		
		if ((a3.x < b3.x) /*  && (a1.x < b3.x) */) // If there is a chance that line a1,a2 is in the shape b
		{
			freeBoxes.unshift(new t_myBox(a3.x, cFreeBoxes.m_pos.y, b3.x - a3.x, cFreeBoxes.m_size.y));
			i++;
		}
		
		if ((a1.y > b1.y) /*  && (a1.x < b3.x) */) // If there is a chance that line a1,a2 is in the shape b
		{
			freeBoxes.unshift(new t_myBox(cFreeBoxes.m_pos.x, cFreeBoxes.m_pos.y, cFreeBoxes.m_size.x, a1.y - b1.y));
			i++;
		}
		
		if ((a3.y < b3.y) /*  && (a1.x < b3.x) */) // If there is a chance that line a1,a2 is in the shape b
		{
			freeBoxes.unshift(new t_myBox(cFreeBoxes.m_pos.x, a3.y, cFreeBoxes.m_size.x, b3.y - a3.y));
			i++;
		}
		
		freeBoxes.splice(i, 1);
	}
	
	for (i=0; i < freeBoxes.length; i++)
	{
		cFreeBoxes = freeBoxes[i];
		
		var i2:uint = i;
		i2++;
		while (i2 < freeBoxes.length)
		{
			if(i>=freeBoxes.length || i==i2)throw new Error("i:"+i+", i2:"+i2+", freeBoxes.length:"+freeBoxes.length);
			
			var cFreeBoxes2:t_myBox = freeBoxes[i2];
			
			b1 = cFreeBoxes.m_pos.clone();
			b2 = new t_myVector2(cFreeBoxes.m_pos.x + cFreeBoxes.m_size.x, cFreeBoxes.m_pos.y);
			b3 = new t_myVector2(cFreeBoxes.m_pos.x + cFreeBoxes.m_size.x, cFreeBoxes.m_pos.y + cFreeBoxes.m_size.y);
			b4 = new t_myVector2(cFreeBoxes.m_pos.x                      , cFreeBoxes.m_pos.y + cFreeBoxes.m_size.y);
			
			var c1:t_myVector2 = cFreeBoxes.m_pos.clone();
			var c2:t_myVector2 = new t_myVector2(cFreeBoxes2.m_pos.x + cFreeBoxes2.m_size.x, cFreeBoxes2.m_pos.y);
			var c3:t_myVector2 = new t_myVector2(cFreeBoxes2.m_pos.x + cFreeBoxes2.m_size.x, cFreeBoxes2.m_pos.y + cFreeBoxes2.m_size.y);
			var c4:t_myVector2 = new t_myVector2(cFreeBoxes2.m_pos.x                       , cFreeBoxes2.m_pos.y + cFreeBoxes2.m_size.y);
			
			if (c1.x >= b1.x && c1.y >= b1.y && c3.x <= b3.x && c3.y <= b3.y)
			{
				if(i>i2)i-=1;
				freeBoxes.splice(i2, 1);
			} else {
				i2+=1;
			}
		}
	}
	

      }


      return boxes
    }
  }
}
