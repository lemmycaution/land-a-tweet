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
