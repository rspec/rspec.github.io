$(function() {
  $('.version-dropdown').hover(function() {
    var $dropdown = $(this);
    $dropdown.find('ul').show();
    $dropdown.find('> a').hide();
  }, function() {
    var $dropdown = $(this);
    $dropdown.find('ul').hide();
    $dropdown.find('> a').show();
  });
});
