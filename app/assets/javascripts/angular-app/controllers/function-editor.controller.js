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

    $scope.aceLoaded = function(_editor){
      editor = _editor;
      console.log("aceLoaded");

      editor.setTheme("ace/theme/github");
      editor.setOptions({
        fontFamily: "Consolas, Menlo, Courier, monospace",
        fontSize: "13px",
      });
      editor.setShowPrintMargin(false);
      editor.getSession().setUseWrapMode(true);

      setLanguageSpecificEditorConfig();
    }

    function setLanguageSpecificEditorConfig() {
      if (!editor || $scope.functionLoading) {
        return;
      }

      editor.session.setMode("ace/mode/" + $scope.function.runtime_language);

      editor.commands.on("exec", function(e) {
        var rowCol = editor.selection.getCursor();

        function preventTyping() {
          e.preventDefault();
          e.stopPropagation();
        }

        if (rowCol.row == 0 && $scope.function.disable_first_line_editing) {
          preventTyping();
        }

        if ((rowCol.row + 1) == editor.session.getLength() && $scope.function.disable_final_line_editing) {
          preventTyping();
        }
      });

      // Ace adds vertical scrolling unless you do this.
      $timeout(function() {
        $(window).trigger('resize');
      }, 100);
    }
  }

})();
