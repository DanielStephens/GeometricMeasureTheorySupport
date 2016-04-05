function FractalRepellor(XorY, axisOn)
	clf;
	colormap ('default');

	graphics_toolkit("gnuplot");

	img1=imread('fractal.png');
	

	l = length(img1);
	c = columns(img1);

	xx = linspace(0, 0, 8);
	zz = linspace(0, 0, 8);

	if XorY
		xx = SetupX(xx, l);
		zz = SetupZ(zz, l);
	else
		xx = SetupZ(xx, l);
		zz = SetupX(zz, l);
	endif
	f = nan(8);
	cols = zeros(8, 8, 3);

	for z=[1,2,4,5,7,8]
		for x=1:5
			#disp([num2str(xx(x)), ",", num2str(zz(z)), " : ", num2str(g(xx(x),zz(z)))]);
			#f(z,x) = g(xx(x),zz(z));
			#f(x,z) = g(zz(x), xx(z));
			if XorY
				f(z,x) = g(xx(x),zz(z),l);
			else
				f(x,z) = g(zz(x), xx(z),l);
			endif
		endfor
	endfor


	vertsB = zeros(4, 3);
	facesB = zeros(2, 3);

	first = true;

	for i=1:l/3
		for j=1:c

			if img1(i, j) <= 100
				if first == true
					if XorY
						vertsB =  [0, j,i*3; 0, (j-1),i*3; 0,j,(i-1)*3; 0,(j-1),(i-1)*3];
					else
						vertsB =  [j, c,i*3; (j-1),c,i*3; j,c,(i-1)*3; (j-1),c,(i-1)*3];
					endif
					facesB(1, :) = [1, 2, 4];
					facesB(2, :) = [1, 4, 3];
					first = false;
				else
					size = length(vertsB);
					if XorY
						vB = [0, j,i*3; 0, (j-1),i*3; 0,j,(i-1)*3; 0,(j-1),(i-1)*3];
					else
						vB =  [j, c,i*3; (j-1),c,i*3; j,c,(i-1)*3; (j-1),c,(i-1)*3];
					endif
					fB = [size+1, size+2, size+4; size+1, size+4, size+3];
					vertsB = vertcat(vertsB, vB);
					facesB = vertcat(facesB, fB);
				endif
			endif

		endfor
	endfor

	for i=1:8
		for j=1:8
			cols(i,j,:) = [f(i,j),f(i,j),f(i,j)]*0.5/l;
		endfor
	endfor

	h2 = axes('view', [45 60], 'Units','normalized', 'NextPlot','add');
	axis([0, l, 0, l, 0, l*2], 'manual', 'off');
	hold on;
	patch(h2, 'Vertices', vertsB, 'Faces', facesB, 'FaceVertexCData', [0, 0, 0],'FaceColor', 'flat');
	view(45, 60);

	
	surf(xx,zz,f,cols); #cols
	if axisOn
		axis([0, l, 0, l, 0, 2*l], "manual", "on");
	else
		axis([0, l, 0, l, 0, 2*l], "manual", "off");
	endif
	view(45, 60);

	hold on;
	xlabel('x');
	ylabel('y');
	zlabel('z');


	surf(zeros(length(img1),columns(img1)), double(img1),'EdgeColor','none');

	xtick=[0 l/6 l/3 l/2 2*l/3 5*l/6 l];
	ytick=[0 l/6 l/3 l/2 2*l/3 5*l/6 l];
	ztick=[0 l/2 l 3*l/2, 2*l];
	set(gca,'xtick',xtick);
	set(gca,'ytick',ytick);
	set(gca,'ztick',ztick);
	xticklabel=["0";"1/6";"1/3";"1/2";"2/3";"5/6";"1"];
	yticklabel=["0";"1/6";"1/3";"1/2";"2/3";"5/6";"1"];
	zticklabel=["0";"0.5";"1";"1.5";"2"];
	set(gca,'xticklabel',xticklabel);
	set(gca,'yticklabel',yticklabel);
	set(gca,'zticklabel',zticklabel);





	shading interp;
	hold off;


	#set (gca (), "zdir", "reverse");



	#Z = sombrero ();
	#[Fx,Fy] = gradient (Z);
	#surf (Z, Fx+Fy);

endfunction

function retval = g(x,y,l)
	if y > 0.33333*l && y < 0.66666*l
		retval = b(x,l);
	else
		retval = a(x,l);
	endif
endfunction

function retval = a(x,l)
	if x <= 0.33333*l
		retval = 3*x;
	elseif x <= 0.66666*l
		retval = 2*l - 3*x;
	else
		retval = 3*x-2*l;
	endif
endfunction

function retval = b(x,l)
	if x <= 0.5*l
		retval = 3*x;
	else
		retval = 3*l - 3*x;
	endif
endfunction

function retval = SetupX(xx, l)
	xx(1) = 0*l;
	xx(2) = 0.33333*l;
	xx(3) = 0.5*l;
	xx(4) = 0.66666*l;
	xx(5) = 1*l;

	retval = xx;
endfunction

function retval = SetupZ(zz, l)
	zz(1) = 0*l;
	zz(2) = 0.33333*l;
	zz(3) = 0.33334*l;
	zz(4) = 0.33334*l;
	zz(5) = 0.66665*l;
	zz(6) = 0.66665*l;
	zz(7) = 0.66666*l;
	zz(8) = 1*l;

	retval = zz;
endfunction