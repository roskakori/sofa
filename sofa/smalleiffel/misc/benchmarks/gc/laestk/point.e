class POINT

creation make

feature

   x, y: REAL;

   make(vx, vy: REAL) is
      do
	 x := vx;
	 y := vy;
      end;

   set_x(vx: REAL) is
      do
	 x := vx
      end

end
