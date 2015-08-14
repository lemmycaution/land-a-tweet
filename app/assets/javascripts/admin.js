// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require ./application

$(document).on('page:change', function() {
  function updateCounts () {
    var $submitBtn = $('form.broadcast input[type=submit]')
    $submitBtn.attr('disabled', true)
    $.getJSON($('form.broadcast').attr('action') + '?' + $('form.broadcast').serialize())
    .then(function (resp) {
      $submitBtn.val('Broadcast! ' + resp['donors_count'])
      $submitBtn.removeAttr('disabled')
    })
    .fail(function () {
      $submitBtn.removeAttr('disabled')
    })
  }
  if ($('form.broadcast').length > 0) {
    $('#broadcast_limit, #broadcast_donor_ids, #broadcast_donations_greater_than').change(updateCounts)
  }
})
