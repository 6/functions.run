(function() {
  'use strict';

  angular
    .module('functions-app')
    .controller('functions-app.function-invocation-controller', Controller);

  Controller.$inject = [
    '$scope',
    'functions-app.functions-service',
    'functions-app.users-service',
  ];

  function Controller($scope, functionsService, usersService) {
    $scope.function = null;
    $scope.state = {
      invoking: false,
    };
    $scope.invocationRequest = {
      payload: '{}',
    };

    functionsService.getFunction(null, true).$promise.then(function(fn) {
      $scope.function = fn;
    });

    $scope.codemirrorLoaded = function(editor) {
      editor.setOption('theme', 'github');
      editor.setOption('lineWrapping', true);
      editor.setOption('lineNumbers', false);
      editor.setOption('mode', "application/json");
      // editor.setOption('gutters', ["CodeMirror-lint-markers"]);
      // editor.setOption('lint', true);
      if (!usersService.isLoggedIn()) {
        editor.focus();
      }
    };

    $scope.invokeFunction = function() {
      var payload = $.trim($scope.invocationRequest.payload);
      if (!payload || payload === "") {
        payload = "{}";
      }
      if (!isValidJson(payload)) {
        return showInvalidJsonModal();
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

    $scope.expandLogs = function() {
      var vexInstance = vex.dialog.open({
        message: 'Logs',
        input: [
          '<textarea class="code-input pa2 input-reset hover-bg-white b--black-20 black w-100" rows="15" spellcheck="false">',
              $scope.invocation.log,
          '</textarea>',
        ].join(''),
        buttons: [
          $.extend({}, vex.dialog.buttons.YES, { text: 'Close' }),
        ],
      });
      $(vexInstance.contentEl).css({'width': 'auto', 'max-width': '800px'});

    };

    function showInvalidJsonModal() {
      vex.dialog.open({
        message: 'You must provide valid JSON input.',
        buttons: [
          $.extend({}, vex.dialog.buttons.YES, { text: 'Ok' }),
        ],
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
