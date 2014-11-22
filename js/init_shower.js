(function($) {
    $(window).on('message', function (event) {
        var pages = event.originalEvent.source.$('.content > div:not(.page-list-container)').clone();
        pages.find('.add-column-panel').remove();
        pages.addClass('slide');
        pages.insertBefore($('.progress'));
        shower.init().run();
    });
})(jQuery);


