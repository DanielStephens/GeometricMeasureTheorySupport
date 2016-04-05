function Vectorfield
	title('Saddle point');

	steps = 20;

	x = linspace(-2, 2, steps);
	y = linspace(-2, 2, steps);

	[xx,yy] = meshgrid(1:steps);

	for i=1:steps
		for j=1:steps
			xx(i,j) = x(j);
			yy(j,i) = y(j);
		endfor
	endfor
	u = yy;
	v = xx;

	for i=1:steps
		for j=1:steps
			v(i,j)=transform(v(i,j));
		endfor
	endfor

	quiver(xx,yy,u,v,4);
endfunction

function retval = transform(i)
	retval = i-(i*i*i);
endfunction