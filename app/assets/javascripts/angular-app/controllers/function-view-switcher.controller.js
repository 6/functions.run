(function() {
  'use strict';

  angular
    .module('functions-app')
    .controller('functions-app.function-view-switcher-controller', Controller);

  Controller.$inject = [
    '$scope',
    'functions-app.functions-service',
  ];

  function Controller($scope, functionsService) {
    // $scope.activeView = 'run';
    //
    // $scope.function = null;
    // functionsService.getFunction(null, true).$promise.then(function(fn) {
    //   $scope.function = fn;
    // });
  }

})();
