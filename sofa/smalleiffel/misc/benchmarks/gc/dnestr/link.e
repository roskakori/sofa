class LINK[E]

creation make

feature

   value: E;

   next: LINK[E];

   make(v: like value; n: like next) is
      do
	 value := v;
	 next := n;
      end;

   set_next(n: like next) is
      do
	 next := n;
      end;

end
