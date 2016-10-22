exports.handler = function(event, context, callback) {
  return userCode(event, callback);
};

var userCode = function(event, callback) {
  <%= code %>
};
