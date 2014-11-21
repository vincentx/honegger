(function ($) {
  var blank_page = {
    page_template: [{single: [['resource-title', 'resource-text']]}],
    content: {title: 'new page'}
  };
  var editor = $('.content');
  editor.honegger({extraPlugins: [Page, PageList, Column, Theme, ComponentList, PageRepo]})
  editor.honegger('addNewPage', 'blank', blank_page.page_template, blank_page.content)
  editor.honegger('insertPage', 'blank')
})(jQuery);


