package 
{
  import t_myVector2;

  public class t_myBox
  {
    public var m_pos:t_myVector2;
    public var m_size:t_myVector2;

    /*public function t_myBox()
    {
    }*/
    public function t_myBox(x:int, y:int, w:int, h:int)
    {
      m_pos = new t_myVector2(x, y);
      m_size = new t_myVector2(w, h);
    }
    public static function t_myBoxFromVec2(pos:t_myVector2, size:t_myVector2)
    {
      return new t_myBox(pos.x, pos.y, size.x, size.y);
    }
    public function clone():t_myBox
    {
      return t_myBoxFromVec2(m_pos, m_size);
    }

    public function isEqual(box:t_myBox):Boolean
    {
      return box.m_pos.isEqual(m_pos) && box.m_size.isEqual(m_size);
    }
    public function isBiggerThanArg(box:t_myBox):Boolean
    {
      if (m_pos.isBiggerThanArg(box.m_pos))return true;
      else if (box.m_pos.isBiggerThanArg(m_pos))return false;
      else if (m_size.isBiggerThanArg(box.m_size))return true;
      else return false;
    }
  }
}
