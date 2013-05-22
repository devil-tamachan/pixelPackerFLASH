package
{
  import t_myVector2;
  import flash.utils.*;

  class MyMultiMap
  {
    public var m_key:Dictionary = new Dictionary();
    public var length:uint = 0;

    public function MyMultiMap()
    {
	length = 0;
    }

    public function insert(key:String, val:t_myVector2):void
    {
      if(m_key[key]===undefined)
      {
        m_key[key] = new Vector.<t_myVector2>();
      }
      m_key[key].push(val.clone());
      length = length +1;
    }

    public function getAndDelete(key:String):t_myVector2
    {
      if(m_key[key]===undefined || m_key[key].length==0)
      {
        return null;
      }
      return m_key[key].shift();
      length = length -1;
    }
  }
}