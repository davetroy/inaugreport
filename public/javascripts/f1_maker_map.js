var Maker = {
  find_maps: function(maker_tag, maker_user) {
    var q = "tag:" + maker_tag
    if(maker_user != undefined) {q +=  " and user:" + maker_user}
    Maker.search(q, 'Maker.on_search_results')
  },
  search: function(q,callback) {
    jsonp_f1  (Maker.maker_host + "/searches.json", callback, "query="+encodeURIComponent(q))
  },
  on_search_results: function(jsonData) {
    var results = jsonData.sortBy(function(s) {return s.indexed_tags})
    MapList.on_list_maps(results)
    // FlashMap.load_map('maker_map', results[0].pk)
  }
}


var FlashMap = {
  load_map: function(dom_id, map_id) {
    FlashMap.dom_id = dom_id
    var flashvars  = {map_id:map_id, core_host: Maker.core_host + '/', maker_host: Maker.maker_host + '/'}
    var params     = {base: Maker.maker_host}
    swfobject.embedSWF(Maker.maker_host + "/Embed.swf", dom_id, "100%", "710", "9.0.0", Maker.maker_host + "/expressInstall.swf", flashvars, params)
    Event.observe(window, 'resize', FlashMap.resize_map_to_fit)
    FlashMap.resize_when_ready()
  },
  resize_when_ready: function() {
    var t = setTimeout("FlashMap.resize_map_to_fit();", 500);
  },
	resize_map_to_fit: function() {
		var windowHeight = document.viewport.getHeight();
		var margin = 77
		var mapHeight = Math.max(windowHeight - margin, 600)
		//alert("mapHeight: " + mapHeight + " windowHeight: " + windowHeight + ", margin: " + margin)
		swfobject.getObjectById(FlashMap.dom_id).style.height = mapHeight + "px";
	},
	store_map_location: function() {
    centerZoom = FlashMap.map.getCenterZoom();
    location.hash = "lat="+centerZoom[0]+"&lon="+centerZoom[1]+"&zoom="+centerZoom[2];
  },
  load_map_location: function() {
    var zooms;
    if(zooms = location.hash.match(/lat=([-\d\.]+)&lon=([-\d\.]+)&zoom=(\d+)/)) {
        centerZoom = FlashMap.map.setCenterZoom(zooms[1],zooms[2],zooms[3]);
    }
  }
}

var MapList = {
  on_list_maps: function(jsonData) {
        MapList.debug = jsonData
    var list = new Template('<ul>#{items}</ul>')
    var item = new Template('<li id="#{pk}"><a href="javascript:void(0)" class="load_map load_map_#{pk}"><strong>#{title}</strong><br/>#{description}</a></li>');
    var items = ""
    jsonData.each(function(e){
        items += item.evaluate({  title: e.title, 
                                  description: e.description, 
                                  pk: e.pk}) });
    $("explore").replace( list.evaluate({items:items}) )
    MapList.observe_list()
  },
  
  observe_list: function() {
    $$('.load_map').invoke('observe','click', MapList.on_item_click )
    $$('.load_view').invoke('observe','click', MapList.on_view_click )
  },

  // Maybe can join these two functions together
  on_view_click: function(ev) {
    ev.stop();
    var el = ev.element()
    if (el.tagName != 'A') {el = el.parentNode}
    if (el.tagName != 'A') {el = el.parentNode} 
    if (el.tagName != 'A') {el = el.parentNode} //nesting without recursion
    var div = id_from_class_pair(el, "load_view");
    if(div != 'reports_reports') {$('reports_reports').hide()}
    if(div != 'reports_map') {$('reports_map').hide()}
    $(div).show();
  },
  
  on_item_click: function(ev) {
    ev.stop();
    var el = ev.element()
    if (el.tagName != 'A') {el = el.parentNode}
    if (el.tagName != 'A') {el = el.parentNode} 
    if (el.tagName != 'A') {el = el.parentNode} //nesting without recursion
    FlashMap.load_map('maker_map', id_from_class_pair(el, "load_map"))
  }
  
}


function jsonp_f1(url,callback,query)
{                
    if (url.indexOf("?") > -1)
        url += "&callback=" 
    else
        url += "?callback=" 
    url += callback + "&";
    if (query)
        url += query + "&";   
    url += new Date().getTime().toString(); // prevent caching        
    
    var script = document.createElement("script");        
    script.setAttribute("src",url);
    script.setAttribute("type","text/javascript");                
    document.body.appendChild(script);
}
