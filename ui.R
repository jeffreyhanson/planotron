shinyUI(basicPage(
	# leaflet map
	div(class="map-wrapper",
		leafletMap(
			"map", "100%", "100%",
			options=list(
				center = c(-26.335955, 134.614984),
				zoom = 4,
				maxBounds = list(list(-90, -180), list(90, 180)),
				zoomControl=FALSE
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
            <div class="sidebar-pane" id="feature_toc">
				<h2>Table of contents</h2>
				<div id="toc" class="list-group"></div>
			</div>
            <div class="sidebar-pane" id="marxan_controls">
				<h2>Prioritisation controls</h2>
				<div class="panel-well row-fluid">
					<h4>Program settings</h4>
						<label for="marxan_blm">Boundary length modifier</label>
						<input id="marxan_blm" type="number" value="1" min="0" step="1"/>

						<label for="marxan_nsol">Number solutions</label>
						<input id="marxan_nsol" type="number" value="100" min="1" step="1"/>
				</div>	
				<h4>Biodiversity feature settings</h4>
				<div class="panel-well row-fluid">
						<label class="control-label" for="marxan_biofeature">Name</label>
						<select id="marxan_biofeature"><option value="All features" selected>All features</option></select>
						<script type="application/json" data-for="marxan_biofeature" data-nonempty="">{}</script>

						<label for="marxan_target">Target</label>
						<input id="marxan_target" type="number" value="0.1" min="0" max="1" step="0.1"/>

						<label for="marxan_spf">Species penalty factor</label>	
						<input id="marxan_spf" type="number" value="10" min="0" step="5"/>
				</div>
				<br/>
				<div class="button-wrapper">
					<button id="marxan_run" type="button" class="btn btn-primary sbs-action-button">Prioritise!</button>
				</div>
			</div>
            <div class="sidebar-pane" id="help">
				<h2>Help</h2>
			</div>
            <div class="sidebar-pane" id="about">
				<h2>About</h2>
			</div>
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
				position: relative;
				top: 0%;
				padding-left: 35%;
			}

			select {
				-moz-border-radius: 3px 3px 3px 3px;
				border: 1px solid #CCCCCC;
				color: #808080;
				display: inline-block;
				font-size: 13px;
				height: 30px;
				line-height: 18px;
				padding: 4px;
				width: 210px;
			}
			
			input[type=\"number\"] {
				-moz-border-radius: 3px 3px 3px 3px;
				border: 1px solid #CCCCCC;
				color: #808080;
				display: inline-block;
				font-size: 13px;
				height: 18px;
				line-height: 18px;
				padding: 4px;
				width:100px;
			}
			
			.toc-element-rfeature {
				background-color: #FCFCFC;
				float:left;
				padding: 2px;
				width: 50%;
				margin-bottom:5px;
				cursor: pointer;
			}

			.toc-element-rwfeature {
				background-color: #FCFCFC;
			}

			.toc-element-label {
				float:left;
				display:inline-block
				padding-left: 10%;
				cursor: pointer;
			}
			
			.toc-element-checkbox {
				display:inline-block
				float:left;
				padding-left: 90%;
				padding-top: 3%;
				cursor: pointer;
			}
			
		"), 
		tags$link(rel="stylesheet", type="text/css", href="//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css"),
		tags$script(HTML('

			function viewFeature(id, status) {
				Shiny.onInputChange("view_feature", {
					"id":id,
					"status":status,
					".nonce":Math.random()
				})
			}
					
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


