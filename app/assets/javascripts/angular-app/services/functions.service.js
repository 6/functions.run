(function() {
  'use strict';

  angular
    .module('functions-app')
    .service('functions-app.functions-service', Service);

  Service.$inject = [
    '$resource',
    '$q'
  ];

  function Service($resource, $q) {
    var service = {};
    service.getFunction = getFunction;

    function functionsResource() {
      return $resource('/api/functions/:id', null, {
        'get': { method: 'GET', isArray: false }
      });
    }

    function getFunction(id, useWindowData) {
      if (useWindowData) {
        var deferred = $q.defer();
        deferred.resolve(window.data.function);
        return {$promise: deferred.promise};
      } else {
        return functionsResource().get({id: id});
      }
    }

    return service;
  }
})();
