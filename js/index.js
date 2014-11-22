(function ($) {
  var blank_page = {
    page_template: [{single: [['resource-title', 'resource-text']]}],
    content: {title: 'new page'}
  };
  var editor = $('.content');
  editor.honegger({extraPlugins: [Page, PageList, Column, Theme, ComponentList, PageRepo]});
  editor.honegger('addNewPage', 'blank', blank_page.page_template, blank_page.content);
  editor.honegger('insertPage', 'blank');
  editor.on('loadTheme', function(e, theme){
    if(theme != ""){
      var iframe = $('#theme-frame')[0].contentWindow.$('.theme-container');
      var result = $('.composer .content').honegger('getContentTemplate');
      iframe.trigger('initTheme', $.extend({}, result, {title: $('input[name="title"]').val()}));
    }
  });
  $('.showcase-editor').click(function (e) {
    $(this).trigger('document-click', $(e.target));
  });
})(jQuery);


