//= require jquery
//= require jquery_ujs
//= require turbolinks

// POST MESSAGE API
window.PostMessageAPI = (function () { 

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

    this[event.data.method](event.data.data)
  }

  PostMessageAPI.prototype.postMessageToParents = function (action) {
    for (var i in this.domains)
      window.parent.postMessage(action, this.domains[i])
  }

  PostMessageAPI.prototype.getLoggedIn = function () {
    this.postMessageToParents({method:'getLoggedIn', data: embedData ? embedData.currentUser : null})
  }
  PostMessageAPI.prototype.getHeight = function () {
    this.postMessageToParents({method: 'getHeight', data: document.getElementsByTagName("html")[0].scrollHeight})
  }
  PostMessageAPI.prototype.getDonation = function () {
    this.postMessageToParents({method: 'getDonation', data: embedData ? embedData.currentUser.donations : null})
  }
  PostMessageAPI.prototype.updateDonation = function (data) {
    if (!embedData) return false
    var self = this
    $.ajax({
      url: embedData.donationUpdateUrl,
      method: 'put',
      data: {
        'donor[donations]': data.donations,
        'donor[action]': data.action,
      },
      complete: function (xhr, status) { 
        self.postMessageToParents({method: 'updateDonation', data: {status: xhr.status, responseJSON: xhr.responseJSON, responseText: xhr.responseText}})
      }
    })
  }
  PostMessageAPI.prototype.login = function () {
    var self = this
    this.checkInt = setInterval(function () {
      $.get('/auth/check').then(function () {
        clearInterval(self.checkInt)
        window.location.reload()
      })
    },1000)
    window.open('/auth/twitter', '_blank')
  }
  PostMessageAPI.prototype.logout = function () {
    var logout = $('<a class="btn logout" href="/auth/twitter" data-method="delete"></a>')
    $('body').append(logout)
    logout.click()
  }

  return PostMessageAPI
})()


$(document).on('page:change', function() {
  var $loginLink = $('.login')
  $loginLink.click(function (e) {
    e.preventDefault()
    PostMessageAPI.instance.login()
  })
  PostMessageAPI.instance.postMessageToParents({method: 'event', data: 'ready'})
})
