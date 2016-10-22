(function() {
  'use strict';

  angular
    .module('functions-app')
    .controller('functions-app.function-editor-controller', Controller);

  Controller.$inject = [
    '$scope',
    'functions-app.functions-service',
  ];

  function Controller($scope, functionsService) {
    var editor;
    $scope.functionLoading = true;
    functionsService.getFunction(null, true).$promise.then(function(fn) {
      $scope.function = fn;
      $scope.functionLoading = false;
      // initializeEditor();
      console.log("OKAY", $scope.function);
    });

    // function initializeEditor() {
    //   editor = ace.edit("code-editor");
    //   editor.setTheme("ace/theme/github");
    //   editor.setOptions({
    //     fontFamily: "Consolas, Menlo, Courier, monospace",
    //     fontSize: "13px",
    //   });
    //   editor.setShowPrintMargin(false);
    //   editor.session.setMode("ace/mode/" + $scope.function.runtime_language);
    //   editor.getSession().setUseWrapMode(true);
    // }
  }

})();
