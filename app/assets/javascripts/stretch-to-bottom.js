var stretchToBottom = function(el) {
  var $el = $(el);
  var newHeight = $(window).height() - $el.offset().top;
  $el.height(newHeight);
}

$(function() {
  stretchToBottom('.js-stretch-to-bottom');
  $(window).on('resize', _.debounce(function() {
    stretchToBottom('.js-stretch-to-bottom');
  }, 200));
});