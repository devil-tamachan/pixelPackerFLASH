package 
{
	public class t_myVector2
	{
		public var x:int;
		public var y:int;
		
		/*public function t_myVector2()
		{
		}*/
		public function t_myVector2(X:int,Y:int)
		{
			this.x = X;
			this.y = Y;
		}
	/*	public function t_myVector2(v:t_myVector2)
		{
			this.x = v.x;
			this.y = v.y;
		}*/
		public function clone():t_myVector2
		{
			return new t_myVector2(x, y);
		}

		public function isEqual(vec:t_myVector2):Boolean
		{
			return vec.x == this.x && vec.y == this.y;
		}
		public function isBiggerThanArg(vec:t_myVector2):Boolean
		{
			if (this.x > vec.x)
				return true;
			else if (this.x < vec.x)
				return false;
			else if (this.y > vec.y)
				return true;
			else
				return false;
		}
public function toString():String
{
return x+","+y;
}

	}
}