(function() {
  'use strict';

  angular
    .module('functions-app')
    .controller('functions-app.function-invocation-controller', Controller);

  Controller.$inject = [
    '$scope',
    'functions-app.functions-service',
  ];

  function Controller($scope, functionsService) {
    $scope.function = null;
    $scope.state = {
      invoking: false,
    };

    functionsService.getFunction(null, true).$promise.then(function(fn) {
      $scope.function = fn;
    });

    $scope.invokeFunction = function() {
      $scope.state.invoking = true;
      functionsService.invokeFunction($scope.function.id).$promise.then(function(result) {
        console.log(result);
        $scope.state.invoking = false;
      });
    }
  }

})();
