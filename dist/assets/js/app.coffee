gui = require('nw.gui')

currentShowDeck = 0

$ ->
  # Show the window after all is ready
  gui.Window.get().show()
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
  $('#exp-ship').change ->
    val = $(this).val().split(',')
    $('#exp-lv').val val[0]
    $('#exp-next').val val[1]
    $('#exp-goal').val val[2]
  $('#open-guide').click ->
    gui.Shell.openExternal 'http://poi.0u0.moe/guide'
  $('#open-advice').click ->
    gui.Shell.openExternal 'http://poi.0u0.moe/advice'
  $('#view-guide').click ->
    gui.Shell.openExternal 'http://poi.0u0.moe/guide'
  $('#exp-submit').click ->
    require('./modules/ui').calcExperience()

@showDeck = (deckId) ->
  $("#deck-#{currentShowDeck}").hide()
  $("#deck-#{deckId}").fadeIn()
  currentShowDeck = deckId
