(function($){
  var element = $('.page-content-container');
  var list = element.find('.components-container');
  element.on('scroll', function() {
    var offset;
    offset = list.offset();
    list.css({
      'top': offset.top < 60 ? 60 : offset.top,
      'left': offset.left
    });
    return list.removeClass('components-container-non-fixed');
  });
  return $(window).on('resize', function() {
    return list.attr('style', '').addClass('components-container-non-fixed').css('top', $(element).scrollTop());
  });
})(jQuery);
