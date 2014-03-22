
source("scripts/Fetcher.R")

## Query and gather data  ##

ystart <- 2000
yend   <- 2020

rawVolumes <- do.call(cbind,
		lapply(ystart:yend, function(query){
			cat("Query: ", query, "\n")
			yearVolume <- TrendQuery(query)
			yearVolume$V2
			cat("Complete\n")
		})
)

dummyResults <- TrendQuery("velociraptors")  #kinda unnecessary, but keeps the lapply of calls clean
weeks <- dummyResults$V1
weeks <- strsplit(weeks, "[ -]")

startWeek <- sapply(weeks, function(x) x[1])
endWeek   <- sapply(weeks, function(x) x[2])

volumes <- cbind(startWeek, endWeek, rawVolumes)
colnames(volumes) <- c("")

## Write it out ##
write.csv(volumes, 'data/volumes.csv', row.names=F, quote=F)



