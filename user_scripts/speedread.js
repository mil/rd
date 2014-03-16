rd.speedread = (function(scope) {
  function initialize() {
    console.log("speed read initialized");

  }
  function uninitialize() {
    console.log("speed read uninitialized");
  }

  return {
    initialize   : initialize,
    uninitialize : uninitialize
  };
}(rd.speedread || {}));
