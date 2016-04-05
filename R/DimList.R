DimensionList <- function(deltaCount){
	thisEnv <- environment()

	dimList <- list()
	count <- deltaCount

	for(i in 1:count){
		dimList[[i]] <- list()
	}

	me <- list(
		thisEnv = thisEnv,

		getEnv = function(){
			return(get("thisEnv",thisEnv))
		},

		getDimension = function(){
			return(get("dimList", thisEnv))
		},

		getDimensionList = function(index){
			if(index<1 || index > get("count", thisEnv)){
				return(NA)
			}
			return(get("dimList", thisEnv)[[index]])
		},

		getDimensionListIndex = function(indexD, index){
			if(indexD<1 || indexD > get("count", thisEnv)){
				return(NA)
			}
			return(get("dimList", thisEnv)[[indexD]][[index]])
		},

		setDimensionListIndex = function(indexD, index, value){
			if(indexD<1 || indexD > get("count", thisEnv)){
				return(NA)
			}
			v = get("dimList", thisEnv)
			v2 = v[[indexD]]
			v2[[index]] = value
			v[[indexD]] = v2
			return(assign("dimList", v, thisEnv))
		},

		getDimensionListIndexLength = function(indexD){
			if(indexD<1 || indexD > get("count", thisEnv)){
				return(NA)
			}
			return(length(get("dimList", thisEnv)[[indexD]]))
		},

		addDimensionListIndex = function(index, value){
			if(index<1 || index > get("count", thisEnv)){
				return(NA)
			}
			i = this$getDimensionListIndexLength(index)
			this$setDimensionListIndex(index, i+1, value)
		},

		getDimensionsToAdd = function(boxes){
			c = get("count", thisEnv)
			c2 = c
			for(i in c:1){
				if(this$getDimensionListContains(i, boxes[i,]) == TRUE){
					if(c == c2){
						return(NA)
					}else{
						return((c2+1):c)
					}
				}
				c2 = c2-1
			}
			return(1:c)
		},

		getCounts = function(){
			c = get("count", thisEnv)
			dim = 1:c
			for(i in dim){
				dim[i] = this$getDimensionListIndexLength(i)
			}
			return(dim)
		},

		getDimensionListContains = function(index, box){
			if(index<1 || index > get("count", thisEnv)){
				return(NA)
			}
			arr = get("dimList", thisEnv)[[index]]
			l = length(arr)
			if(l == 0){
				return(FALSE)
			}

			for (i in l:1){
				if(identical(box, arr[[i]])){
					return(TRUE)
				}
			}
			return(FALSE)
		}
	)

	assign('this',me,envir=thisEnv)
	class(me) <- append(class(me),"DimensionList")
	return(me)
}