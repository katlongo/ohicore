# see launch_app(), makes global variables: conf, layers, scores, dir_spatial, dir_scenario
suppressPackageStartupMessages({
  require(shiny)
  require(RJSONIO)
  require(RColorBrewer)
  require(rCharts)
  require(markdown)
})

#cat(ls(), file='~/Downloads/ohicore_global_ls.txt'); system('open ~/Downloads/ohicore_global_ls.txt')

options(stringsAsFactors = F)
# options(error=recover) # options(error=browser)

# Data: select score ----
sel_score_target_choices = c('0 Index'='Index', 
                             setNames(conf$goals$goal, 
                                      sprintf('%g %s (%s)', conf$goals$order_hierarchy, conf$goals$name, conf$goals$goal))); # print(names(varGoals))
sel_score_dimension_choices = as.vector(unique(scores$dimension))

# Data: select layer ----

# get unique layers. organized by target (index, goal), which allows for repeat of layer across multiple targets
layer_targets = data.frame(target=character(0), layer=character(0))
for (i in 1:length(layers$targets)){ # i=1
  targets = layers$targets[[i]]
  layer   = names(layers$targets[i])
  layer_targets = rbind(layer_targets, 
                    data.frame(target = targets,
                               layer = rep(layer, length(targets))))
}
layer_targets = merge(layer_targets,
                  rbind(rename(conf$goals[,c('goal','name','order_hierarchy','parent')],
                               c('goal'='target','name'='target_name','order_hierarchy'='target_order','parent'='target_parent')),
                        data.frame(target        = c('pressures','resilience','spatial'),
                                   target_name   = c('Pressures','Resilience','Spatial'),
                                   target_order  = c(       100 ,        101 ,     102), 
                                   target_parent = c(        NA ,         NA ,      NA), stringsAsFactors=F)),
                  all.x=T)
layer_targets = arrange(merge(layer_targets, layers$meta, by='layer', all.x=T), target_order, name)
layer_targets = within(layer_targets, {
  target_label = sprintf('%s %s', target_order, target_name)
  layer_label  = sprintf('%s (%s)', name, layer)
  }) # [,c('label','value')]

# get unique layer targets
sel_layer_target_choices = with(unique(layer_targets[,c('target','target_label')]), setNames(target, target_label))

# initialize layer variables
lyr_df = subset(layer_targets, target==sel_layer_target_choices[[1]])
sel_layer_choices = with(lyr_df, setNames(layer, layer_label))
lyr_fld_category = lyr_df$fld_category
if (is.na(lyr_fld_category)){
  sel_layer_category_choices = NA
} else {
  sel_layer_category_choices = sort(as.character(unique(layers$data[[lyr_df$layer]][[lyr_fld_category]])))
}
lyr_fld_year = lyr_df$fld_year
if (is.na(lyr_fld_year)){
  sel_layer_year_choices = NA
} else {
  sel_layer_year_choices = sort(unique(layers$data[[lyr_df$layer]][[lyr_fld_year]]), decreasing=T)
}

# Layers: get_var() ----
# reactiveValues ----
dir_scenarios = dirname(dir_scenario)
  
# index or goal
# conf$goals = within(arrange(
#   conf$goals, order_hierarchy), {
#     indented_label = ifelse(!is.na(parent), 
#                             sprintf('. %s', name),
#                             name)})
# varGoals      = c('0. Index'='Index', setNames(conf$goals$goal, conf$goals$indented_label)); # print(names(varGoals))

# 

# add dir for regions
addResourcePath('spatial', path.expand(dir_spatial))

# defaults
smax = 1 # max for goals slider inputs


rgn_names = rbind(rename(SelectLayersData(layers, layers=conf$config$layer_region_labels, narrow=T), c('id_num'='rgn_id', 'val_chr'='rgn_name'))[,c('rgn_id','rgn_name')],
                  data.frame(rgn_id=0, rgn_name='GLOBAL'))

# get goals for aster, all and specific to weights
goals.all = arrange(conf$goals, order_color)[['goal']]

# get colors for aster, based on 10 colors, but extended to all goals. subselect for goals.wts
cols.goals.all = colorRampPalette(RColorBrewer::brewer.pal(10, 'Spectral'), space='Lab')(length(goals.all))
names(cols.goals.all) = goals.all

# helper functions ----
get_wts = function(input){
  #return rescaled goal weights so sums to 1
  wts = c(MAR=input$MAR,
          FIS=input$FIS,    
          AO=input$AO,
          NP=input$NP,
          CS=input$CS,
          CP=input$CP,
          TR=input$TR,
          LIV=input$LIV,
          ECO=input$ECO,
          ICO=input$ICO,
          LSP=input$LSP,
          CW=input$CW,
          HAB=input$HAB,
          SPP=input$SPP)

  # rescale so sums to 1
  wts = wts / sum(wts)
  return(wts)
}

capitalize <- function(s) { # capitalize first letter
  paste(toupper(substr(s, 1, 1)), substr(s, 2, nchar(s)), sep='')
}


# get data
GetMapData = function(v){
  
  
  #browser('GetMapData', expr=v$layer=='mar_harvest_tonnes')
  

  # check for single value
  if (n_distinct(v$data$val_num) == 1){
    
    # check for single zero value
    if (unique(v$data$val_num) == 0){
      rng = c(-1, 1) * 0.001    
    } else {
      # arbitrarily extend color ramp range to get a legit set of breaks
      rng = range(unique(v$data$val_num)*c(0.9999, 1, 1.0001), na.rm=T)
    }
        
  } else {
    rng = range(v$data$val_num, na.rm=T)
  }
  brks = with(v$data, seq(rng[1], rng[2], length.out=8))
  colors = brewer.pal(length(brks)-1, 'Spectral')
  regions = plyr::dlply(v$data, 'rgn_id', function(x) {
    return(list(val_num = x$val_num,
                color   = cut(x$val_num, breaks=brks, labels=colors, include.lowest=TRUE)))
  })                        
  legend = setNames(signif(brks, digits=4), cut(brks, breaks=brks, labels=colors, include.lowest=TRUE)) #; cat(toJSON(legend))
  return(list(regions=regions, legend=legend))
}

# plot map
PlotMap = function(v, width='100%', height='600px', lon=0, lat=0, zoom=2){  # Baltic: c(59, 19), zoom = 5
  
  #browser('PlotMap', expr=v$layer=='mar_harvest_tonnes')
  
  if ( (length(na.omit(v$data$val_num))==0) | (!'rgn_id' %in% names(v$data)) ){
    stop(sprintf('Sorry, the Map view is unavailable for the selected layer (%s) because
      the field %s does not have associated spatial shapes available for mapping. 
      Please choose a different view (Histogram or Table) or a different layer.', v$layer, v$fld_id))
    #return()
  }
      
  d = GetMapData(v)
  
  lmap <- Leaflet$new()
  lmap$mapOpts(worldCopyJump = TRUE)
  lmap$tileLayer(provide='Stamen.TonerLite')
  lmap$set(width=width, height=height)
  lmap$fullScreen(T)
  lmap$setView(c(lat, lon), zoom=zoom) # Baltic: c(59, 19), zoom = 5
  lmap$geoJson(
    "#! regions !#",
    style = sprintf("#! function(feature) {
      regions_data = %s;
      var rgn = feature.properties['rgn_id'].toString();
      if (typeof regions_data[rgn] != 'undefined'){
        var color = regions_data[rgn]['color'];
      } else {
        var color = 'gray';
      };
      return {
        color: color,
        strokeWidth: '1px',
        strokeOpacity: 0.5,
        fillOpacity: 0.2
      }; } !#", gsub('\\\"', "'", toJSON(d$regions, collapse=' '))),
    onEachFeature = sprintf("#! function (feature, layer) {

      // info rollover
      if (document.getElementsByClassName('info leaflet-control').length == 0 ){
        info = L.control({position: 'topright'});  // NOTE: made global b/c not ideal place to put this function
        info.onAdd = function (map) {
          this._div = L.DomUtil.create('div', 'info');
          this.update();
          return this._div;
        };
        info.update = function (props) {
          if (props && typeof props['rgn_id'] != 'undefined' && typeof regions_data[props['rgn_id'].toString()] != 'undefined'){
            var val_num = regions_data[props['rgn_id'].toString()]['val_num'];
          } else {
            var val_num = 'NA';
          };

          this._div.innerHTML = '<h4>%s</h4>' +  (props ?
          	'<b>' + props['rgn_nam'] + '</b> (' + props['rgn_id'] + '): ' + val_num
        		: 'Hover over a region');
        };
        info.addTo(map);
      };
  
      // mouse events
      layer.on({
  
        // mouseover to highlightFeature
    	  mouseover: function (e) {
          var layer = e.target;
          layer.setStyle({
            strokeWidth: '3px',
            strokeOpacity: 0.7,
            fillOpacity: 0.5
          });
        	if (!L.Browser.ie && !L.Browser.opera) {
        		layer.bringToFront();
        	}
  	      info.update(layer.feature.properties);
        },
  
        // mouseout to resetHighlight
  		  mouseout: function (e) {
          geojsonLayer.resetStyle(e.target);
  	      info.update();
        },
  
        // click to zoom
  		  click: function (e) {
          var layer = e.target;        
          if ( feature.geometry.type === 'MultiPolygon' ) {        
          // for multipolygons get true extent
            var bounds = layer.getBounds(); // get the bounds for the first polygon that makes up the multipolygon
            // loop through coordinates array, skip first element as the bounds var represents the bounds for that element
            for ( var i = 1, il = feature.geometry.coordinates[0].length; i < il; i++ ) {
              var ring = feature.geometry.coordinates[0][i];
              var latLngs = ring.map(function(pair) {
                return new L.LatLng(pair[1], pair[0]);
              });
              var nextBounds = new L.LatLngBounds(latLngs);
              bounds.extend(nextBounds);
            }
            map.fitBounds(bounds);
          } else {
          // otherwise use native target bounds
            map.fitBounds(e.target.getBounds());
          }
        }
  	  });
      } !#", HTML(v$name)))
  lmap$legend(position = 'bottomright', 
              colors   =  names(d$legend), 
              labels   =  as.vector(d$legend))
  return(lmap)
}
