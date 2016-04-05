function LorenzAttractor(overallPoints)
	graphics_toolkit("fltk");
	
	start = [ 0.01, 0.01, 0.01];
	
	points = 100;
	startPoint = 1;
	loops = ceil(overallPoints/points);
	cols = jet(overallPoints);
	count = 1;
	
	for i=1:loops
		disp(startPoint);
	
		start = Convergent(start, startPoint, points, overallPoints, cols);
		startPoint = startPoint+points
		print([num2str(count),"Lorenz.png"]);
		
		#if yes_or_no ("should we continue? ") == false
		#	break;
		#endif
		count = count+1;
	endfor
	
endfunction

function retval = Convergent(start, startPoint, points, overallPoints, allCols)
	#title('Convergent field');
	
	a=10;
	r=28;
	b=8/3;
	dt=0.01;
	X=start(1);
	Y=start(2);
	Z=start(3);
	n=points-1;
	
	if startPoint+n>overallPoints
		n = overallPoints-startPoint;
	endif
	
	
	XYZ=zeros(n, 3);
	t=0;

	for i=1:n
		X1=X;
		Y1=Y;
		Z1=Z;

		X=X1+(-a*X1+a*Y1)*dt;
		Y=Y1+(-X1*Z1+r*X1-Y1)*dt;
		Z=Z1+(X1*Y1-b*Z1)*dt;
		XYZ(i,:)=[X,Y,Z];
	endfor
	
	retval = [X,Y,Z];

	x=XYZ(:,1);
	y=XYZ(:,2);
	z=XYZ(:,3);
	
	newDefaultColors = allCols(startPoint:(startPoint+n-1), :);
	#disp(size(newDefaultColors));
	#disp(size(x));
	#set(gca, 'ColorOrder', newDefaultColors, 'NextPlot', 'replacechildren');
	#axis([-30, 30, -30, 30, 0, 60], "manual");
	
	hax = scatter3(x, y, z, [], newDefaultColors);
	axis([-30, 30, -30, 30, 0, 60], "manual");
	view(45, 0);
	#set(hax, "position", [-30, 30, 0, 60, -30, 30]);# = 10;
	#colormap(cols);
endfunction