class TRIANGLE

creation make

feature

   p1, p2, p3: POINT;

   make(vp1, vp2, vp3: POINT) is
      do
	 p1 := vp1;
	 p2 := vp2;
	 p3 := vp3;
      end;

end
