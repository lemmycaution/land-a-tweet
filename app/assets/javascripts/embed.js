//= require jquery
//= require jquery_ujs
//= require turbolinks

window.PostMessageAPI = (function () {

  function PostMessageAPI (domains, embedData) {
    if (PostMessageAPI.instance instanceof PostMessageAPI) {
      return PostMessageAPI.instance
    } else {
      PostMessageAPI.instance = this
    }
    this.source = null
    this.domains = domains
    this.embedData = embedData
    window.addEventListener("message", this.onMessage.bind(this), false)
    setTimeout(this.getLoggedIn.bind(this),0)
  }

  PostMessageAPI.authCheckInterval = 1000

  PostMessageAPI.init = function (domains, embedData) {
    if (PostMessageAPI.instance instanceof PostMessageAPI) {
      return PostMessageAPI.instance
    }
    PostMessageAPI.instance = new PostMessageAPI(domains, embedData)
    return PostMessageAPI.instance
  }
  
  PostMessageAPI.pageChangeHandler = function () {
    $('[data-lat-action=login]').click(function (e) {
      e.preventDefault()
      PostMessageAPI.instance.login()
    })
    $('[data-lat-action=logout]').click(function (e) {
      e.preventDefault()
      PostMessageAPI.instance.logout()
    })
    PostMessageAPI.instance.postMessageToParents({method: 'event', data: 'ready'})
  }

  PostMessageAPI.prototype.onMessage = function (event) {
    var checkOrg = false
    for (var i in this.domains) {
      if (event.origin === this.domains[i]) {
        checkOrg = true
        // console.log(event.source.location)
        this.domain = event.origin
        this.source = event.source
        break
      }
    }
    if (!checkOrg) return

    this[event.data.method](event.data.data)
  }

  PostMessageAPI.prototype.postMessageToParents = function (action) {
    if(this.source) {
      this.source.postMessage(action, this.domain)
    } else {
      for (var i in this.domains) {
        window.parent.postMessage(action, this.domains[i])
      }
    }
  }

  PostMessageAPI.prototype.getLoggedIn = function () {
    this.postMessageToParents({
      method:'getLoggedIn', 
      data: this.embedData ? this.embedData.currentUser : null
    })
  }

  PostMessageAPI.prototype.getHeight = function () {
    this.postMessageToParents({
      method: 'getHeight', 
      data: document.getElementsByTagName("html")[0].scrollHeight
    })
  }

  PostMessageAPI.prototype.getDonation = function () {
    this.postMessageToParents({
      method: 'getDonation', 
      data: this.embedData ? this.embedData.currentUser.donations : null
    })
  }

  PostMessageAPI.prototype.updateDonation = function (data) {
    if (!this.embedData) return false
    var self = this
    $.ajax({
      url: this.embedData.donationUpdateUrl,
      method: 'put',
      data: {
        'donor[donations]': data.donations,
        'donor[action]': data.action,
      },
      complete: function (xhr, status) { 
        self.postMessageToParents({
          method: 'updateDonation', 
          data: {
            status: xhr.status, 
            responseJSON: xhr.responseJSON, 
            responseText: xhr.responseText
          }
        })
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
    }, PostMessageAPI.authCheckInterval)
    window.open('/auth/twitter', '_blank')
  }

  PostMessageAPI.prototype.logout = function () {
    var logout = $('<a class="btn logout" href="/auth/twitter" data-method="delete"></a>')
    $('body').append(logout)
    logout.click()
  }

  return PostMessageAPI
})()

$(document).on('page:change', PostMessageAPI.pageChangeHandler)
