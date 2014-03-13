rd.speedread = (function(scope) {
  function initialize() {
    alert("speed read initialized");

  }
  function uninitialize() {
    alert("speed read uninitialized");
  }

  return {
    initialize   : initialize,
    uninitialize : uninitialize
  };
}(rd.speedread || {}));
