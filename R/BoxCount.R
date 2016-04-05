Run <- function(startX, startY, startZ, points, startD, stepD, countD){
	source("DimList.R")

	#library("plot3D")
	require("plot3D")

	step = 10
	stepCount = step

	a<-10;
	r<-28;
	b<-8/3;
	dt<-0.001;
	X<-startX;
	Y<-startY;
	Z<-startZ;
	n <- points;
	deltas <- 1:countD
	exponents <- 1:countD

	for(i in 1:200){
		X1 = X;
		Y1 = Y;
		Z1 = Z;

		X = X1+a*(Y1-X1)*dt
		Y = Y1+(r*X1-Y1-X1*Z1)*dt
		Z = Z1+(X1*Y1-b*Z1)*dt
	}

	for(j in 0:(countD-1)){
		exp = -(startD+j*stepD)

		deltas[j+1] <- exp(exp)
		exponents[j+1] <- exp
	}

	dimension <- DimensionList(countD)
	boxes <- matrix(data=NA,nrow=countD,ncol=3)
	XYZ <- matrix(data=NA,nrow=n,ncol=3)
	
	pb <- winProgressBar(title = "progress bar", min = 0,max = n, width = 300)
	for(i in 1:n){
		stepCount = stepCount-1
		if(stepCount == 0){
			stepCount = step
			Sys.sleep(0.1)
			setWinProgressBar(pb, i, title=paste(floor(100*i/n),"% done"))
		}
		X1 = X;
		Y1 = Y;
		Z1 = Z;

		X = X1+a*(Y1-X1)*dt
		Y = Y1+(r*X1-Y1-X1*Z1)*dt
		Z = Z1+(X1*Y1-b*Z1)*dt

		arr = c(X,Y,Z)
		XYZ[i,] = arr

		for(j in 1:countD){
			boxes[j,] = GetBox(deltas[j], arr)
		}
		val = dimension$getDimensionsToAdd(boxes)

		if(identical(val, NA)){
			next
		}

		for(k in val){
			dimension$addDimensionListIndex(k, boxes[k,])
		}
	}

	close(pb)

	#Lorenz Attractor plot
	#scatter3D(XYZ[,1],XYZ[,2],XYZ[,3], colvar = 1:n, phi = 0, theta = 45, col = jet.col(n))

	dims = dimension$getCounts()
	realDim = log(dims)
	exponents = -log(deltas)

	#Dimension of Lorenz Attractor
	plot(deltas, dims, log='x',xlab=expression('delta as 10'^'x'), ylab=expression('dim'['M']*'F'))
}

GetBestFit <- function(x, y){
	logY = log(y)

	ySum = sum(y)
	xSum = sum(x)
	xySum = sum(x*y)
	x2ySum = sum(x*x*y)
	ylogySum = sum(y*logY)
	xyLogySum = sum(x*y*logY)

	a = x2ySum*ylogySum-(xySum*xyLogySum)
	a = a/(ySum*x2ySum - xySum*xySum)

	b = ySum*xyLogySum-xySum*ylogySum
	b = b/(ySum*x2ySum-xySum*xySum)

	return(c(a,b))
}

GetBox <- function(delta, point){
	return(floor(point/delta))
}

Run2 <- function(startX, startY, startZ, offset, count){
	source("DimList.R")
	
	#library("plot3D")
	require("plot3D")

	step = 100
	stepCount = step

	a<-10;
	r<-28;
	b<-8/3;
	dt<-0.01;
	Xa<-startX;
	Ya<-startY;
	Za<-startZ;

	#presteps
	for(i in 1:200){
		X1 = Xa;
		Y1 = Ya;
		Z1 = Za;

		Xa = X1+a*(Y1-X1)*dt
		Ya = Y1+(r*X1-Y1-X1*Z1)*dt
		Za = Z1+(X1*Y1-b*Z1)*dt
	}

	Xb<-Xa+offset;
	Yb<-Ya;
	Zb<-Za;

	XYZboth <- list()
	XYZa <- list()
	XYZb <- list()
	Dist <- list()

	n=1
	cutoff = 1.75
	cutoffIndex = 0
	hasNotReached = TRUE
	
	total = count

	#comment out for non-windows environment
	pb <- winProgressBar(title = "progress bar", min = 0,max = total, width = 300)
	########################################

	while(n <= total){
		#comment out for non-windows environment
		stepCount = stepCount-1
		if(stepCount == 0){
			stepCount = step
			Sys.sleep(0.1)
			setWinProgressBar(pb, n, title=paste(floor(100*n/total),"% done"))
		}
		########################################
		X1 = Xa;
		Y1 = Ya;
		Z1 = Za;
		X2 = Xb;
		Y2 = Yb;
		Z2 = Zb;

		Xa = X1+a*(Y1-X1)*dt
		Ya = Y1+(r*X1-Y1-X1*Z1)*dt
		Za = Z1+(X1*Y1-b*Z1)*dt

		Xb = X2+a*(Y2-X2)*dt
		Yb = Y2+(r*X2-Y2-X2*Z2)*dt
		Zb = Z2+(X2*Y2-b*Z2)*dt

		arr1 = c(Xa,Ya,Za)
		arr2 = c(Xb,Yb,Zb)

		XYZa[[n-cutoffIndex]] = arr1
		XYZb[[n-cutoffIndex]] = arr2

		if(hasNotReached){
			XYZboth[[n]] = 0.5*(arr1+arr2)
		}
		
		dist = sqrt(SqrDist(arr1, arr2))
		Dist[[n]] = dist

		if(dist > cutoff && hasNotReached == TRUE){
			XYZa = list()
			XYZb = list()
			cutoffIndex = n
			hasNotReached = FALSE
			total = cutoffIndex+150
		}

		n = n + 1
	}
	#comment out for non-windows environment
	close(pb)
	########################################

	XYZarr = matrix(unlist(XYZboth), ncol = 3, byrow=TRUE)
	XYZarr1 = matrix(unlist(XYZa), ncol = 3, byrow=TRUE)
	XYZarr2 = matrix(unlist(XYZb), ncol = 3, byrow=TRUE)
	
	colours = rbind(matrix(data=unlist(1:nrow(XYZarr)), ncol=1), nrow(XYZarr), matrix(data=nrow(XYZarr)+1, ncol=1, nrow=nrow(XYZarr1)),nrow(XYZarr)+1, matrix(data=nrow(XYZarr)+2, ncol=1, nrow=nrow(XYZarr2)))
	plots = rbind(XYZarr, matrix(data=NA, ncol=3, nrow=1), XYZarr1, matrix(data=NA, ncol=3, nrow=1), XYZarr2);


	rgbs = jet.col(nrow(XYZarr)+2)
	rgbs[nrow(XYZarr)+1] = rgb(1, 1, 0)
	rgbs[nrow(XYZarr)+2] = rgb(0, 0, 1)

	backtrack = 500

	for(i in 1:nrow(XYZarr)){
		t = (i-nrow(XYZarr)+backtrack)/backtrack
		t = max(0, t)
		val = 1 - ((i/nrow(XYZarr))*0.75+0.25)
		rgbs[i] = rgb(val, val, val, 1)
	}
	
	#plot distance split point
	#scatter3D(plots[,1], plots[,2], plots[,3], colvar=colours, type = 'p',phi = 0, theta = 45, col = rgbs)
	
	#plot distance graph
	plot(1:length(Dist), Dist, xlab='iterations', ylab='Distance')
}

SqrDist <- function(v1, v2){
	v = v1-v2
	return(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
}
