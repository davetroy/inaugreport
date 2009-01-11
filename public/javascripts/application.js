Date.prototype.toISO8601String = function (format, offset) {
    /* accepted values for the format [1-6]:
     1 Year:
       YYYY (eg 1997)
     2 Year and month:
       YYYY-MM (eg 1997-07)
     3 Complete date:
       YYYY-MM-DD (eg 1997-07-16)
     4 Complete date plus hours and minutes:
       YYYY-MM-DDThh:mmTZD (eg 1997-07-16T19:20+01:00)
     5 Complete date plus hours, minutes and seconds:
       YYYY-MM-DDThh:mm:ssTZD (eg 1997-07-16T19:20:30+01:00)
     6 Complete date plus hours, minutes, seconds and a decimal
       fraction of a second
       YYYY-MM-DDThh:mm:ss.sTZD (eg 1997-07-16T19:20:30.45+01:00)
    */
    if (!format) { var format = 6; }
    if (!offset) {
        var offset = 'Z';
        var date = this;
    } else {
        var d = offset.match(/([-+])([0-9]{2}):([0-9]{2})/);
        var offsetnum = (Number(d[2]) * 60) + Number(d[3]);
        offsetnum *= ((d[1] == '-') ? -1 : 1);
        var date = new Date(Number(Number(this) + (offsetnum * 60000)));
    }

    var zeropad = function (num) { return ((num < 10) ? '0' : '') + num; }

    var str = "";
    str += date.getUTCFullYear();
    if (format > 1) { str += "-" + zeropad(date.getUTCMonth() + 1); }
    if (format > 2) { str += "-" + zeropad(date.getUTCDate()); }
    if (format > 3) {
        str += "T" + zeropad(date.getUTCHours()) +
               ":" + zeropad(date.getUTCMinutes());
    }
    if (format > 5) {
        var secs = Number(date.getUTCSeconds() + "." +
                   ((date.getUTCMilliseconds() < 100) ? '0' : '') +
                   zeropad(date.getUTCMilliseconds()));
        str += ":" + zeropad(secs);
    } else if (format > 4) { str += ":" + zeropad(date.getUTCSeconds()); }

    if (format > 3) { str += offset; }
    return str;
}

/* reload the reviewer page if the reviewer has been looking at the
   reports for > 10 minutes */
function startReviewerClock() {
  if (reviewer_timeout) {
   clearTimeout(reviewer_timeout);
  }
  reviewer_timeout = setTimeout('reviewer_time_limit_reached()', 600000);
}

function reviewer_time_limit_reached() {
  alert("You have been looking at these reports " +
        "for more than 10 minutes. They have been " +
        "released for another reviewer.  Please reload " + 
        "this page if your " +
        "browser doesn't do it automatically.");
  window.location.reload();
}

var Accordion = {
  initialize: function(ev) {
    $$('.expand').invoke('observe','click', Accordion.pick)
    Accordion.panels = $$('.panel')
  },
  pick: function(ev) {
    ev.stop();
    el = ev.element()
    panel = $("panel_" + id_from_class_pair(el, "expand"))
    Accordion.panels.without(panel).each(function(panel){
      Accordion.transition(panel, 'minimize')
    })
    Accordion.transition(panel, 'maximize')
  },
  transition: function(panel,action) {
    var lng  = $$('#'+panel.id +' .long' ).first()    
    var shrt = $$('#'+panel.id +' .short').first()
    if (action=='maximize' && !lng.visible()) {
      Accordion.tween_swap(shrt, lng)
    } 
    if (action=='minimize' && lng.visible()) {
      Accordion.tween_swap(lng, shrt)
    }
  },
  
  tween_swap: function(from,to) {
    to.style.overflow = 'hidden'
    to.style.visibility = 'hidden'  //visibility hack required in order to get an accurate height calculation on a 'display:none' object.
    to.show()
    var heightStart = from.getHeight()
    var heightEnd = to.getHeight()
    to.style.height = heightStart + 'px'
    to.style.visibility = 'visible'
    from.hide() 
    new Effect.Tween(to, heightStart, heightEnd, {duration: 0.5}, function(v){this.style.height = v + 'px'});
  } 
}


// Retrieves the id from a class name pair such as: "open_overlay open_overlay_23"
// So, id_from_class_pair(el,"open") will return "overlay_23"
// or, id_from_class_pair(el,"open_overlay") will return "23"
function id_from_class_pair(el, action) {
  var r = new RegExp(".*"+action+"_([^ ]+).*")
  return el.className.replace(r,'$1')
}