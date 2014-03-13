// http://stackoverflow.com/questions/3387427/javascript-remove-element-by-id?lq=1
Element.prototype.remove = function() {
    this.parentElement.removeChild(this);
}
NodeList.prototype.remove = HTMLCollection.prototype.remove = function() {
    for(var i = 0, len = this.length; i < len; i++) {
        if(this[i] && this[i].parentElement) {
            this[i].parentElement.removeChild(this[i]);
        }
    }
}
// http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
function uuid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
    return v.toString(16);
  });
}

var rd = (function(init_params) {
  var styles = {

  };


  function initialize() {
  }
  function uninitialize() {
  }
  function add_style(styleHandle, stylePayload) {
    styles[styleHandle] = {
      id      : uuid(),
      payload : stylePayload
    };
  }

  function activate_script(scriptHandle) {
    this[scriptHandle].initialize();
  }
  function deactivate_script(scriptHandle) {
    this[scriptHandle].deactivate();
  }

  function activate_style(styleHandle) {
    if (!styles[styleHandle]) { console.log("no style"); return; }

    var el = document.createElement("style");
    console.log(styles[styleHandle]);
    el.setAttribute("id", styles[styleHandle]['id']);
    el.innerHTML =  styles[styleHandle]['payload'];
    document.body.appendChild(el);
  }
  function deactivate_style(styleHandle) {
    if (!styles[styleHandle]) { console.log("no style"); return; }
    document.getElementById(styles[styleHandle]['id']).remove();
  }

  return {
    initialize        : initialize,
    uninitialize      : uninitialize,
    add_style         : add_style,
    activate_script   : activate_script,
    activate_style    : activate_style,
    deactivate_script : deactivate_script,
    deactivate_style  : deactivate_style,
    show_styles : function() {
      return styles;
    }
  };
}(rd || {}));
