$(function() {

  function tabLinkByName(name) {
    // TODO
    // return $('#methods_list a[href=#tab_' + name.replace('#', '') + ']');
    return $('a[href=#tab_' + name.replace('#', '') + ']');
  }

  function selectTabByName(name) {
    // de-select previous
    $('#methods_list .active').removeClass('active');
    // select new
    var tabLink = tabLinkByName(name);
    console.log('tabLink')
    console.log(name)
    tabLink.parent().addClass('active')
    tabLink.tab('show');
    document.location.hash = name;
  }

  function selectTab(clickedLink) {
    selectTabByName(clickedLink.attr("href").replace('#tab_', ''));
  }

  $('a.select-tab').click(function (e) {
    e.preventDefault();
    selectTab($(this));
  })

  $('#current_section a:first').click(function (e) {
    e.preventDefault();
    $('#methods_list .active').removeClass('active');
    $(this).tab('show');
    document.location.hash = '';
  })

  // Shows the tab associated with the current fragment or the description of
  // the sections on page load.
  //
  $(function () {
    var tabLink = tabLinkByName(document.location.hash);
    if (tabLink.size() == 1) {
      selectTab(tabLink);
    } else {
      // TODO
      // $('#current_section a:first').tab('show');
      $('h1:first a:first').tab('show');
    }
  });
});
