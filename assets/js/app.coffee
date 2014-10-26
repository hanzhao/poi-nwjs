$(document).ready ->
  current = 0
  $('#btn-main').click ->
    if current != 0
      current = 0
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-about').hide()
      $('#sec-main').fadeIn()
  $('#btn-ship').click ->
    if current != 1
      current = 1
      $('#sec-main').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-about').hide()
      $('#sec-ship').fadeIn()
  $('#btn-factory').click ->
    if current != 2
      current = 2
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-calc').hide()
      $('#sec-about').hide()
      $('#sec-factory').fadeIn()
  $('#btn-calc').click ->
    if current != 3
      current = 3
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-about').hide()
      $('#sec-calc').fadeIn()
  $('#btn-about').click ->
    if current != 4
      current = 4
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-about').fadeIn()
