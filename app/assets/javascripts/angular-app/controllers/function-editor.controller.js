(function() {
  'use strict';

  angular
    .module('functions-app')
    .controller('functions-app.function-editor-controller', Controller);

  Controller.$inject = [
    '$scope',
    '$timeout',
    'functions-app.functions-service',
    'functions-app.users-service',
  ];

  function Controller($scope, $timeout, functionsService, usersService) {
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
      editor.setOption('readOnly', true);
      editor.focus();

      setLanguageSpecificEditorConfig();
    }

    function setLanguageSpecificEditorConfig() {
      if (!editor || !$scope.function) {
        return;
      }

      editor.setOption('mode', {name: $scope.function.runtime_language, version: $scope.function.runtime_version});
      editor.getDoc().markClean();

      if (!usersService.canCurrentUserEditFunction($scope.function)) {
        editor.setOption('readOnly', 'nocursor');
        return;
      }

      $timeout(function() {
        var doc = editor.getDoc();
        editor.setOption('readOnly', false);
        if ($scope.function.disable_first_line_editing) {
          doc.markText(
            {line: 0, ch: 0},
            {line: 1, ch: 0},
            {className: "code-uneditable", readOnly: true}
          );
          editor.setCursor({line: 1, ch: 0});

          editor.on('keydown', function(cm, e) {
            if (e.key.match(/^Arrow/) || e.metaKey) {
              return;
            }
            var doc = cm.getDoc();
            var cursor = doc.getCursor();
            if (cursor.line === 0 && cursor.ch === 0) {
              e.preventDefault();
            }
          });
        }
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
