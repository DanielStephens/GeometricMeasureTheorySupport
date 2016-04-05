function Vectorfieldtwo
	title('Sink');

	steps = 20;

	x = linspace(0, 10, steps);
	y = linspace(0, 10, steps);

	[xx,yy] = meshgrid(1:steps);

	for i=1:steps
		for j=1:steps
			xx(i,j) = x(j);
			yy(j,i) = y(j);
		endfor
	endfor
	u = (5-xx);
	v = 2*(5-yy);


	quiver(xx,yy,u,v,1);
endfunction