(function() {
  'use strict';

  angular.module('functions-app', [
    'ngResource',
    'ui.codemirror',
  ]);

  angular.module('functions-app')
    .config(Config);

  function Config() {
    window.vex.defaultOptions.className = 'vex-theme-plain';
  }
})();
