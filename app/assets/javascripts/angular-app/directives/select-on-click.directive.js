(function() {
  'use strict';

  angular
    .module('functions-app')
    .directive('selectOnClick', Directive);

  function Directive() {
    return {
      restrict: 'A',
      link: function (scope, element) {
        var focusedElement;
        element.on('click', function () {
          if (focusedElement != this) {
            this.select();
            focusedElement = this;
          }
        });
        element.on('blur', function () {
          focusedElement = null;
        });
      }
    };
  }
})();
