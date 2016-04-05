function Solenoid(it, ot, r, w, subX, subY)
	clf;
	#close all;
	graphics_toolkit("fltk");
	if it < 1
		it = 1
	endif

	[c1, colSet] = InitialCurve(r,subX);
	cols = jet(ot);

	for i=1:it
		#clf;
		#scatter3(c1(:,1),c1(:,2),c1(:,3), 8, colSet);
		#xlabel('x');
		#ylabel('y');
		#zlabel('z');
		#hold on;
		#view(0,90);
		view(45,65);
		axis([-3, 3, -3, 3, -1, 1]);
		#hold on;
		[verts,faces,colour] = ExtrudeCurve(i, c1,Power(w,i-1),subY, [1,0,0]);
		DrawPrint(verts,faces,colour, i);
		if(i!=it)
			[c1, colSet] = NewCurve(i,c1,w,r);
		endif
	endfor
endfunction

function DrawPrint(verts, faces, colour, i)
	clf;
	patch("Faces", faces, "Vertices", verts, 'EdgeColor', 'none', 'FaceVertexCData', colour, 'FaceColor', 'interp');
	axis('off');
	xlabel('x');
	ylabel('y');
	zlabel('z');
	view(45,65);
	#print(['solenoid', num2str(i), '.png'], '-dpng', '-r500');
endfunction

function retval = Power(a,p)
	prod = 1;
	for i=1:p
		prod = prod*a;
	endfor
	retval = prod;
endfunction

function [vs, tris, colour] = ExtrudeCurve(power, c, size, subsections, defaultCol)
	
	dAng = 2*pi/subsections;
	verts = zeros(subsections*length(c),3);
	faces = zeros(subsections*length(c)*2,3);
	col = zeros(subsections*length(c),3);

	for i=0:length(c)-1

		p = c(i+1,:);
		ang = (atan2(-p(2),-p(1))+pi);

		baseIndex = i*subsections;

		for j=1:subsections
			x = cos(dAng*j);
			y = sin(dAng*j);
			vertPos = p + [x*cos(ang)*size,x*sin(ang)*size,y*size];
			verts(baseIndex + j, :) = vertPos;
			col(baseIndex + j, :) = defaultCol*(vertPos(3)*0.45+0.55);

			f1 = baseIndex+j;
			f2 = baseIndex+1 + mod((j),subsections);
			f3 = 1+mod((baseIndex+j+subsections-1),(length(c)*subsections));
			f4 = f3+1;
			if f2 != f1+1
				f4 = f4-subsections;
			endif
			faces(baseIndex*2+j*2, :) = [f1,f2,f3];
			faces(baseIndex*2+j*2-1, :) = [f2,f3,f4];
		endfor


	endfor

	vs = verts;
	tris = faces;
	colour = col;

endfunction

function [retval, colours] = InitialCurve(r,sub)
	dAng = 2*pi/sub;
	c = zeros(sub,3);
	cols = zeros(sub,1);
	for i=0:sub-1
		c(i+1,:)=[r*cos(dAng*i),r*sin(dAng*i),0];
		cols(i+1)=(i+1);
	endfor
	retval = c;
	colours = cols;
endfunction

function [retval, colours] = NewCurve(power,c, scale, r)
	c2 = zeros(length(c),3);
	cols = zeros(length(c2),1);
	dAng = pi/length(c); #Power(2, i)
	
	for i=1:length(c)
		p = c(i, :);
		a = (atan2(-p(2),-p(1))+pi);
		centre = [r*cos(a),r*sin(a),0];

		v1 = AlterVector(p, centre, a, scale, dAng*i, r);

		c2(i,:) = v1;
		cols(i)=i;
	endfor

	retval = c2;
	colours = cols;
endfunction

function v1 = AlterVector(p, c, a, s, dA, r)
	v = Unwind(p,c,a,s);

	v = s*v + 0.5*[cos(a), 0, sin(a)]+[r, 0, 0];
	v = v*rotv([0, 0, 1], 2*a);
	v1 = v;
	
endfunction

function v = Unwind(p,c,a, s)
	somev = (p-c)*rotv([0,0,1], -a);
	v = (somev);
endfunction

function v = Wind(v1,c,a)
	v1 = v1*rotv([0,0,1], a);
	v1 = v1+c;
	v = v1;
endfunction


function retval = MakeTorus(curve,r,s,subdivisions)
	x = linspace(-(r+1),(r+1),subdivisions);
	y = linspace(-(r+1),(r+1),subdivisions);
	z = zeros(subdivisions,subdivisions,2);

	for i=1:subdivisions
		for j=1:subdivisions
			off = getOffset(x(i),y(j),r,s);
			z(i,j,1)=-off;
			z(i,j,2)=off;

		endfor
	endfor

endfunction

function retval = getOffset(x,y,r,s)
	l = abs(sqrt(x*x+y*y)-r);
	retval = sqrt(s*s-l*l);
endfunction

function retval = RotatePoint(p, v, a)
	retval = p*rotv(cross(v,[0,0,1]),a);
endfunction

function r = rotv(v ,ang)
	if nargin > 1
		v = v.*((ang(:)./sqrt(sum(v'.^2))')*ones(1,3));
	end
	## For checking only
	## v00 = v ;
	## static toto = floor(rand(1)*100) ;
	## toto
	a = sqrt(sum(v'.^2))' ; 
	oka = find(a!=0);
	if all(size(oka)),
	  v(oka,:) = v(oka,:)./(a(oka)*ones(1,3)) ; 
	end
	## ca = cos(a);
	## sa = sin(a);

	N = size(v,1) ; N3 = 3*N ;
	r = (reshape( v', N3,1 )*ones(1,3)).*kron(v,ones(3,1)) ;
	r += kron(cos(a),ones(3,3)) .* (kron(ones(N,1),eye(3))-r) ;

	## kron(cos(a),ones(3,3)) .* (kron(ones(N,1),eye(3))-r0) 
	## cos(a)

	tmp = zeros(N3,3) ;
	tmp( 2:3:N3,1 ) =  v(:,3) ;
	tmp( 1:3:N3,2 ) = -v(:,3) ;
	tmp( 3:3:N3,1 ) = -v(:,2) ;
	tmp( 1:3:N3,3 ) =  v(:,2) ;
	tmp( 2:3:N3,3 ) = -v(:,1) ;
	tmp( 3:3:N3,2 ) =  v(:,1) ;
	## keyboard
	r -= kron(sin(a),ones(3)) .* tmp ;
endfunction