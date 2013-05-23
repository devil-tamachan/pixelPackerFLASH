package 
{
  import MyMultiMap;
  import t_myVector2;
  import t_myBox;
  import flash.utils.ByteArray;
  import fl.controls.*;
  
  public class algoShelfSimple
  {
    public function algoShelfSimple()
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
    
    public static function myComp(prev:t_myVector2,next:t_myVector2):Number{
      return next.y - prev.y;
    }

    public static function pack(temp:Vector.<t_myVector2>, size:t_myVector2):MyMultiMap
    {
      var rects:Vector.<t_myVector2> = myClone(temp);
      var boxes:MyMultiMap = new MyMultiMap();
      var levels:Vector.<t_myVector2> = new Vector.<t_myVector2>();
      var sizes:Vector.<int> = new Vector.<int>();
      
      rects.sort(myComp);
      
      var starty:int = 0;

      done: for (var i:uint = 0; i<rects.length; i++)
      {
        for (var b:uint=0; b<levels.length; b++)
        {
          if (size.x - levels[b].x >= rects[i].x && sizes[b] >= rects[i].y)
          {
            boxes.insert(rects[i].toString(), levels[b].clone());
            levels[b].x += rects[i].x;
            continue done;
          }
        }
        
        levels.push(new t_myVector2(rects[i].x, starty));
        sizes.push(rects[i].y);
        boxes.insert(rects[i].toString(), new t_myVector2(0,starty));
        starty += rects[i].y;
      }

      return boxes
    }
  }
}
