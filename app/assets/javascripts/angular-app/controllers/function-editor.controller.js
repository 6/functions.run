(function() {
  'use strict';

  angular
    .module('functions-app')
    .controller('functions-app.function-editor-controller', Controller);

  Controller.$inject = [
    '$scope',
    '$timeout',
    'functions-app.functions-service',
  ];

  function Controller($scope, $timeout, functionsService) {
    var editor;
    $scope.function = {};
    $scope.functionLoading = true;
    functionsService.getFunction(null, true).$promise.then(function(fn) {
      $scope.function = fn;
      $scope.functionLoading = false;
      console.log("OKAY", $scope.function);
      setLanguageSpecificEditorConfig();
    });

    $scope.codemirrorLoaded = function(_editor){
      editor = _editor;
      console.log("codemirrorLoaded");

      editor.setOption('theme', 'github');
      editor.setOption('lineWrapping', true);
      editor.setOption('lineNumbers', true);
      editor.focus();

      setLanguageSpecificEditorConfig();
    }

    function setLanguageSpecificEditorConfig() {
      if (!editor || $scope.functionLoading) {
        return;
      }

      editor.setOption('mode', {name: $scope.function.runtime_language, version: $scope.function.runtime_version});
      editor.getDoc().markClean();
    }
  }

})();
