exports.handler = function(event, context, callback) {
  return runCode(event, callback);
};

var runCode = function(input, callback) {
  <%= code %>
};
