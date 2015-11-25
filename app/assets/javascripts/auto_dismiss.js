var AutoDismiss = {
  init: function () {
    $('[data-auto-dismiss]').each(function (i, el) {
      var $el = $(el)
      setTimeout(function () { 
        $el.addClass('animated fadeOutUp') 
        $el.one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () { $el.remove() });
      }, parseInt($el.data('auto-dismiss')) * 1000)
    })
  }
}