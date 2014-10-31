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
      $('#sec-about').hide()
      $('#sec-main').fadeIn()
  $('#btn-ship').click ->
    if currentTag != 1
      currentTag = 1
      $('#sec-main').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-about').hide()
      $('#sec-ship').fadeIn()
  $('#btn-factory').click ->
    if currentTag != 2
      currentTag = 2
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-calc').hide()
      $('#sec-about').hide()
      $('#sec-factory').fadeIn()
  $('#btn-calc').click ->
    if currentTag != 3
      currentTag = 3
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-about').hide()
      $('#sec-calc').fadeIn()
  $('#btn-about').click ->
    if currentTag != 4
      currentTag = 4
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-about').fadeIn()

@showDeck = showDeck = (deckId) ->
  $("#deck-#{currentShowDeck}").hide()
  $("#deck-#{deckId}").fadeIn()
  currentShowDeck = deckId
