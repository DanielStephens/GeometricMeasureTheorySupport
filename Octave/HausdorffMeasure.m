function HausdorffMeasure()
	clf;
	graphics_toolkit("fltk");

	x = [0 1 1 1 2];
	f = [1 1 nan 0 0];
	xTick = [0 1 2];
	xLabel={'0', '', 'n'};
	yTick = [0 1];
	yLabel={'0', ''};

	h = plot(x, f);
	box('off');
	set(gca, 'Xtick', xTick);
	set(gca, 'Xticklabel', xLabel);
	set(gca, 'Ytick', yTick);
	set(gca, 'Yticklabel', yLabel);
	set (h, "linewidth", 5);

	ylabel('H^{S} (F)');
	text (-0.1, 1, '{\fontsize{40}\infty}');
	text (0.97, -0.02, '{\fontsize{40}dim_{H}F}');
	text (0.99, -0.05, 'S');
endfunction