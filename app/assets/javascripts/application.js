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
  
  // POST MESSAGE API
  var PostMessageAPI = (function () { 
    
    function PostMessageAPI (domains) {
      this.domains = domains
      
      window.addEventListener("message", this.onMessage.bind(this), false)
    }
    
    PostMessageAPI.init = function (domains) {
      if (PostMessageAPI.instance instanceof PostMessageAPI) return PostMessageAPI.instance
      PostMessageAPI.instance = new PostMessageAPI(domains) 
      return PostMessageAPI.instance
    }
    
    PostMessageAPI.prototype.onMessage = function (event) {
      var checkOrg = false
      for (var i in this.domains){
        if (event.origin === this.domains[i]) {
          checkOrg = true
          break
        }
      }
      if (!checkOrg) return

      this[event.data[0]](event)
    }

    PostMessageAPI.prototype.postMessageToParents = function (msg) {
      for (var i in this.domains) 
        window.parent.postMessage(msg, this.domains[i])
    }
    PostMessageAPI.prototype.getLoggedIn = function () {
      return $('.btn-login').length === 0
    }
    PostMessageAPI.prototype.callGetLoggedIn = function () {
      this.postMessageToParents(['getLoggedIn', this.getLoggedIn()])
    }
    PostMessageAPI.prototype.getHeight = function () {
      return document.getElementsByTagName("html")[0].scrollHeight
    }
    PostMessageAPI.prototype.callGetHeight = function () {
      this.postMessageToParents(['getHeight', this.getHeight()])
    }
    PostMessageAPI.prototype.getDonation = function () {
      return $('[name="donor[donations]"]').val()
    }
    PostMessageAPI.prototype.callGetDonation = function () {
      this.postMessageToParents(['getDonation', this.getDonation()])
    }
    PostMessageAPI.prototype.updateDonation = function (event) {
      $('[name="donor[donations]"]').val(event.data[1])
      $('form.donations button[type=submit]').click()
    }
    PostMessageAPI.prototype.logout = function () {
      $('a.logout').click()
    }
    PostMessageAPI.prototype.login = function () {
      $('.btn-login').click()
    }

    return PostMessageAPI
  })()

  PostMessageAPI.init(["http://staging.savethearctic.org", "https://www.savethearctic.org", "http://fiddle.jshell.net"])
  PostMessageAPI.instance.callGetLoggedIn()
})
