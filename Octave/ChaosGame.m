function ChaosGame(nodeSetup, iterates, f, startVal)
	if strcmp(typeinfo(nodeSetup), 'sq_string') == 1
		[p, nodes, fac] = NodeSetup(nodeSetup);
		str = nodeSetup;
	elseif ismatrix(nodeSetup) || isvector(nodeSetup)
		nodes = nodeSetup;
		p = startVal;
		fac = f;
		str = 'Custom';
	endif

	lastNode = 1;

	positions = zeros(iterates, 2);
	
	preIterates = 100;
	for j=1:preIterates
		p = Remap(p, nodes, fac);
	endfor

	for i=1:iterates
		positions(i, :) = p;
		p = Remap(p, nodes, fac);
	endfor

	plot(positions(:,1), positions(:,2), '.');
	#print([str, num2str(iterates), '.png'], '-dpng', '-r500');
endfunction

function newP = Remap(p, nodes, fac)
	r = RandomInt(length(nodes));
	node = nodes(r,:);
	newP = MoveTowards(p, node, 1-fac);
endfunction

function i = RandomInt(length)
	r = rand();
	i = ceil(r*(length));
endfunction

function v = MoveTowards(vec1, vec2, t)
	v = ((vec2-vec1)*t)+vec1;
endfunction

function [p, nodes, f] = NodeSetup(str)
	if strcmpi(str,'Carpet') == 1
		nodes = [
			-1,-1;
			-1,0;
			-1,1;
			0,-1;
			0,1;
			1,-1;
			1,0;
			1,1
			];

		p = [rand()*2-1, rand()*2-1];

		f = 1/3;
	else
		nodes = [
			-1,-1;
			1,-1;
			0,sqrt(5)
			];

		p = [-1,-1];
		p = MoveTowards(p, [1,1], rand());
		p = MoveTowards(p, [0,sqrt(5)], rand());

		f = 1/2;

		if strcmpi(str,'Gasket') == 0
			disp('Unknown command - using Sierpinski gasket instead');
		endif
	endif
endfunction