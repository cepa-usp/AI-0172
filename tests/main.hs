module Main where

-- Given y(x) = ax^2+bx+c, returns its roots, x0 and x1, and vertex coordinates: (xv,yv).
-- When y(x) has no roots, it returns NaN for x0 and x1.
f1 a b c = (x0,x1,xv,yv)
           where x0 = (-b-d)/(2*a)
                 x1 = (-b+d)/(2*a)
                 xv = -b/(2*a)
                 yv = a*xv*xv+b*xv+c
                 d  = sqrt (b*b-4*a*c)

-- Given y(x) = a(x-xv)^2+yv, returns its roots, x0 and x1.
-- When y(x) has no roots, it returns NaN for x0 and x1.
f2 a xv yv = (x0,x1)
             where x0 = xv - d
                   x1 = xv + d
                   d  = sqrt (-yv/a)


	
