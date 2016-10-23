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
    $scope.function = null;
    functionsService.getFunction(null, true).$promise.then(function(fn) {
      $scope.function = fn;
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
      if (!editor || !$scope.function) {
        return;
      }

      editor.setOption('mode', {name: $scope.function.runtime_language, version: $scope.function.runtime_version});
      editor.getDoc().markClean();

      $timeout(function() {
        var doc = editor.getDoc();
        doc.markText(
          {line: 0, ch: 0},
          {line: 1, ch: 0},
          {className: "code-uneditable", readOnly: true}
        );
        if ($scope.function.disable_final_line_editing) {
          doc.markText(
            {line: doc.lineCount() - 1, ch: 0},
            {line: doc.lineCount(), ch: 0},
            {className: "code-uneditable", readOnly: true}
          );

          editor.on('keydown', function(cm, e) {
            var doc = cm.getDoc();
            var cursorIsOnFinalLine = (doc.lineCount() - 1) === doc.getCursor().line;
            var cursorIsOnFinalCharacter = doc.getLine(doc.lastLine()).length === doc.getCursor().ch;
            if (e.key === "Enter" && cursorIsOnFinalLine && cursorIsOnFinalCharacter) {
              e.preventDefault();
            }
          });
        }
      }, 100);
    }
  }

})();
