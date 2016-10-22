(function() {
  'use strict';

  angular.module('functions-app', [
    'ngResource',
    'ui.ace',
    'ui.codemirror',
  ]);

  angular.module('functions-app')
    .config(Config);

  function Config() {
  }
})();
