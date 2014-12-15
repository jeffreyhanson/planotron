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
	# load rfeatures
	for (i in seq_along(rfeatures)) {
		if (nrow(rfeatures[[i]]@data)<30) {
			currCols=rCols[seq_len(nrow(rfeatures[[i]]@data))]
		} else {
			currCols=rep(rCols[i],nrow(rfeatures[[i]]@data))
		}
		toc$newFeature(paste0('r_',id$new()), rfeatures[[i]], 'r', names(rfeatures)[i], rfeatures[[i]]@data[[1]], currCols)
	}
	# load pufeature
	toc$newPuFeature(paste0('pu_',id$new()), pufeature, 'r', "Planning units", pufeature@data[[1]], rep("green", nrow(pufeature@data)))
	
	# show/hide features
	observe({
		if (is.null(input$view_feature))
			return()
		isolate({
			cat(input$view_feature$id, " = ", input$view_feature$status, "\n")
			toc$features[[input$view_feature$id]]$.status=input$view_feature$status
			map$viewFeature(input$view_feature$id, input$view_feature$status)
		})
	})
	
	# zoom to feature
	observe({
		if (is.null(input$zoom_feature))
			return()
		isolate({
			map$fitBounds(toc$features[[input$zoom_feature$id]]$bbox())
		})
	})

	# zoom to active features
	observe({
		if (is.null(input$zoom_active_features))
			return()
		isolate({
			map$fitBounds(toc$bbox())
		})
	})
	
	# render data
	observe({
		if (is.null(input$map_load_data))
			return()
		isolate({
			# send features to leaflet
			for (i in seq_along(toc$features)) {
				if (toc$features[[i]]$.mode=="r") {
					if (inherits(toc$features[[i]],"PUFEATURE")) {
						map$addPuFeature(toc$features[[i]]$.id, toc$features[[i]]$to.json(), 'r', toc$features[[i]]$.name)
					} else if (inherits(toc$features[[i]],"FEATURE")) {
						map$addFeature(toc$features[[i]]$.id, toc$features[[i]]$to.json(), 'r', toc$features[[i]]$.name)
					}
				}
			}
		})
	})
})




