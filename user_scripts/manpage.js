rd.manpage = (function(scope) {
  function initialize() {
    alert("YUEE");
  }
  function uninitialize() {
    console.log("manpage");
  }

  return {
    initialize   : initialize,
    uninitialize : uninitialize
  };
}(rd.manpage || {}));
