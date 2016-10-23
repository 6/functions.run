(function() {
  'use strict';

  angular
    .module('functions-app')
    .controller('functions-app.function-view-switcher-controller', Controller);

  Controller.$inject = [
    '$scope',
  ];

  function Controller($scope) {
    $scope.activeView = 'run';
  }

})();
