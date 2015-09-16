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
// =require post_message_api

$(document).on('page:change', function() {

  var $loginLink = $('.btn-login')
  
  function toggleForm() {
    $(this).toggleClass('hide')
    $('form.donations').toggleClass('hide')
  }

  $('[data-auto-dismiss]').each(function (i, el) {
    var $el = $(el)
    setTimeout(function () { 
      $el.addClass('animated fadeOutUp') 
      $el.one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () { $el.remove() });
    }, parseInt($el.data('auto-dismiss')) * 1000)
  })
  
  $('form[data-remote=true]')
  .on('ajax:before', function(e, data, status, xhr) {
    $(e.currentTarget).parent().find('.errors').remove()
  })
  .on('ajax:success', function(e, data, status, xhr) {
    $('[data-donations]').text(data)
    toggleForm.call($('.btn-toggle-donations-form')[0])
  })
  .on("ajax:error", function(e, xhr, status, error) {
    var errors = '<ul class="list-reset mb2 p2 bg-red white rounded errors">'
    for(var field in xhr.responseJSON) {
      errors += '<li>' + field + ' ' + xhr.responseJSON[field].join(", ") + '</li>'
    }
    errors += '</ul>'
    $(errors).insertBefore($(e.currentTarget))
  })
  $('.btn-toggle-donations-form').click(toggleForm)


  if ($loginLink.length > 0) {
    $loginLink.click(function (e) {
      e.preventDefault()
      var checkInt = setInterval(function () {
        $.get('/auth/check').then(function () {
          clearInterval(checkInt)
          window.location.reload()
        })
      },1000)
      window.open(e.currentTarget.getAttribute('href'), '_blank')
    })
  }
  
})
