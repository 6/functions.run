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
    $scope.invocationRequest = {
      payload: "",
    };

    functionsService.getFunction(null, true).$promise.then(function(fn) {
      $scope.function = fn;
    });

    $scope.invokeFunction = function() {
      var payload = $.trim($scope.invocationRequest.payload);
      if (!payload || payload === "") {
        payload = "{}";
      }
      if (!isValidJson(payload)) {
        return window.alert("Input must be valid JSON.");
      }
      $scope.state.invoking = true;
      functionsService.invokeFunction($scope.function.id, $scope.invocationRequest.payload).$promise.then(function(invocation) {
        try {
          invocation.log = $.trim(atob(invocation.log_result));
        } catch (e) {
          invocation.log = null;
        }
        $scope.invocation = invocation;
        $scope.state.invoking = false;
      }, function() {
        window.alert("Something went wrong!");
        $scope.state.invoking = false;
      });
    }

    function isValidJson(str) {
      try {
        JSON.parse(str);
      } catch (e) {
        return false;
      }
      return true;
    }
  }

})();
