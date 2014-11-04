gui = require('nw.gui')

currentShowDeck = 0

$ ->
  currentTag = 0
  currentShowDeck = 1
  $('#btn-main').click ->
    if currentTag != 0
      currentTag = 0
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-settings').hide()
      $('#sec-main').fadeIn()
  $('#btn-ship').click ->
    if currentTag != 1
      currentTag = 1
      $('#sec-main').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-settings').hide()
      $('#sec-ship').fadeIn()
  $('#btn-factory').click ->
    if currentTag != 2
      currentTag = 2
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-calc').hide()
      $('#sec-settings').hide()
      $('#sec-factory').fadeIn()
  $('#btn-calc').click ->
    if currentTag != 3
      currentTag = 3
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-settings').hide()
      $('#sec-calc').fadeIn()
  $('#btn-settings').click ->
    if currentTag != 4
      currentTag = 4
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-settings').fadeIn()
  $('#proxy-tabs').find('a').on 'opened:tabs:amui', (e) ->
    console.log "#{$$(this).text()} is open"
  $('#about-weibo').click ->
    gui.Shell.openExternal 'http://weibo.com/234325654'
  $('#about-github').click ->
    gui.Shell.openExternal 'https://github.com/magimagi/poi'
  $('#about-license').click ->
    gui.Shell.openExternal 'https://github.com/magimagi/poi/blob/master/LICENSE'
  $('#about-nw').click ->
    gui.Shell.openExternal 'https://github.com/rogerwang/node-webkit'

@showDeck = (deckId) ->
  $("#deck-#{currentShowDeck}").hide()
  $("#deck-#{deckId}").fadeIn()
  currentShowDeck = deckId
