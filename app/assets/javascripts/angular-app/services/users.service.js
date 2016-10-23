(function() {
  'use strict';

  angular
    .module('functions-app')
    .service('functions-app.users-service', Service);

  function Service() {
    var service = {};
    service.getCurrentUser = getCurrentUser;
    service.canCurrentUserEditFunction = canCurrentUserEditFunction;

    function getCurrentUser() {
      return window.data.currentUser;
    }

    function canCurrentUserEditFunction(userFunction) {
      var currentUser = getCurrentUser();
      if (!currentUser) {
        return false;
      }
      return currentUser.id === userFunction.user_id;
    }

    return service;
  }
})();
