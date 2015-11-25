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
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require ./auto_dismiss

$(document).on('page:change', function() {
  AutoDismiss.init()

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
    updateCounts()
  }
  function addDomain () {
    var clone = $($("#tmp-page-domains-input-group-clone").html())
    clone.find('input').val('')
    clone.find('.remove-domain').click(removeDomain)
    $("#page_domains").append(clone)
  }
  function removeDomain (e) {
    $(e.target).parents('.input-group').remove() 
  }
  $('.add-domain').click(addDomain)
  $('.remove-domain').click(removeDomain)
})
