package 
{
  import MyMultiMap;
  import t_myVector2;
  import t_myBox;
  import flash.utils.ByteArray;
  import fl.controls.*;
  
  public class algoGuillotine
  {
    public function algoGuillotine()
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
        if(minFreeBoxesIndex==-1||minRectsIndex==-1)return null;
        
        var tempbox:t_myBox = new t_myBox(minFreeBoxes.m_pos.x + minRects.x, minFreeBoxes.m_pos.y + 0, minFreeBoxes.m_size.x - minRects.x, minFreeBoxes.m_size.y);
        var tempbox2:t_myBox = new t_myBox(minFreeBoxes.m_pos.x + 0, minFreeBoxes.m_pos.y + minRects.y, minRects.x, minFreeBoxes.m_size.y - minRects.y);

        boxes.insert(minRects.toString(), minFreeBoxes.m_pos.clone());
        freeBoxes.splice(minFreeBoxesIndex, 1);
        freeBoxes.push(tempbox, tempbox2);
        rects.splice(minRectsIndex, 1);
      }


      return boxes
    }
  }
}
