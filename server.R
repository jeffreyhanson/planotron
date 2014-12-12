### define functions
bindEvent <- function(eventExpr, callback, env=parent.frame(), quoted=FALSE) {
  eventFunc <- exprToFunction(eventExpr, env, quoted)
  initialized <- FALSE
  invisible(observe({
    eventVal <- eventFunc()
    if (!initialized)
      initialized <<- TRUE
    else
      isolate(callback())
  }))
}

### shiny server function
shinyServer(function(input, output, session) {
	## initialization
	# prepare toc
	map=createLeafletMap(session, 'map')
	toc=TOC$new()
	id=ID$new()
	for (i in seq_along(baselayers)) {
		if (nrow(baselayers[[i]]@data)<30) {
			currCols=rCols[seq_len(nrow(baselayers[[i]]@data))]
		} else {
			currCols=rep(rCols[i],nrow(baselayers[[i]]@data))
		}
		toc$newFeature(paste0('r_',id$new()), baselayers[[i]], 'r', names(baselayers)[i], baselayers[[i]]@data[[1]], currCols)
	}
	# load data
	observe({
		if (is.null(input$map_load_data))
			return()
		isolate({
			# send rfeatures to leaflet
			for (i in seq_along(toc$features)) {
				if (toc$features[[i]]$.mode=="r") {
					map$addFeature(toc$features[[i]]$.id, toc$features[[i]]$to.json(), 'r', toc$features[[i]]$.name)
				}
			}
		})
	})
})




