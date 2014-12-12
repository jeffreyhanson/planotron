shinyUI(basicPage(
	# leaflet map
	div(class="map-wrapper",
		leafletMap(
			"map", "100%", "100%",
			options=list(
				center = c(-26.335955, 134.614984),
				zoom = 4,
				maxBounds = list(list(-90, -180), list(90, 180))
			)
		)
	),

	HTML('
    <div id="sidebar" class="sidebar collapsed">
        <!-- Nav tabs -->
        <ul class="sidebar-tabs" role="tablist">
            <li><a href="#feature_toc" role="tab"><i class="fa fa-bars"></i></a></li>
            <li><a href="#marxan_controls" role="tab"><i class="fa fa-gear"></i></a></li>
            <li><a href="#help" role="tab"><i class="fa fa-question"></i></a></li>
            <li><a href="#about" role="tab"><i class="fa fa-info"></i></a></li>
        </ul>

        <!-- Tab panes -->
        <div class="sidebar-content active">
            <div class="sidebar-pane" id="feature_toc"><h1>feature_toc</h1></div>
            <div class="sidebar-pane" id="marxan_controls"><h1>marxan_controls</h1></div>
            <div class="sidebar-pane" id="help"><h1>help</h1></div>
            <div class="sidebar-pane" id="about"><h1>about</h1></div>
        </div>
    </div>
	'),
	
	# map container html tags
	tags$head(
		tags$style("
				
			pre  {
				background-color: #FCFCFC;
			}

			pre code{
				color: #FF1493;
			}
			
			code {
				color: #FF1493;
				background-color: #FCFCFC;
			}
		
			.map-wrapper {
			  position: fixed;
			  top: 0;
			  left: 0;
			  right: 0;
			  bottom: 0;
			  overflow: hidden;
			  padding: 0;
			}
			
			.button-wrapper {
				position: absolute;
				top: 0%;
				padding-left: 50%;
			}			
		"), 
		tags$link(rel="stylesheet", type="text/css", href="//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css"),
		tags$script(HTML('
			Shiny.addCustomMessageHandler("jsCode",
				function(message) {
				  console.log(message)
				  eval(message.code);
				}
			  );
		
			Shiny.addCustomMessageHandler("update_var",
				function(message) {
					eval(message.var + \' = \' + message.val);
				}
			  );
			
			Shiny.addCustomMessageHandler("enable_button", 
				function(message) {
					$("#" + message.btn).removeAttr("disabled");
				}
			);
			
			Shiny.addCustomMessageHandler("disable_button", 
				function(message) {
					$("#" + message.btn).prop(\"disabled\",true);
				}
			);
						
			var enterTextInputBinding = new Shiny.InputBinding();
				$.extend(enterTextInputBinding, {
				find: function(scope) {
					return $(scope).find(\'.enterTextInput\');
				},
				getId: function(el) {
					//return InputBinding.prototype.getId.call(this, el) || el.name;
					return $(el).attr(\'id\')
				},
				getValue: function(el) {
					return el.value;
				},
				setValue: function(el, value) {
					el.value = value;
				},
				subscribe: function(el, callback) {
					$(el).on(\'keyup.textInputBinding input.textInputBinding\', function(event) {
						if(event.keyCode == 13) { //if enter
							callback()
						}
					});	
				},
				unsubscribe: function(el) {
					$(el).off(\'.enterTextInputBinding\');
				},
				receiveMessage: function(el, data) {
					if (data.hasOwnProperty(\'value\'))
						this.setValue(el, data.value);
					if (data.hasOwnProperty(\'label\'))
						$(el).parent().find(\'label[for=\' + el.id + \']\').text(data.label);
					$(el).trigger(\'change\');
				},
				getState: function(el) {
					return {
						label: $(el).parent().find(\'label[for=\' + el.id + \']\').text(),
						value: el.value
					};
				},
				getRatePolicy: function() {
					return {
						policy: \'debounce\',
						delay: 250
					};
				}
			});
			Shiny.inputBindings.register(enterTextInputBinding, \'shiny.enterTextInput\');

			
		'))
	)
))


