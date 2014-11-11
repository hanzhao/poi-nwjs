exports.formatTime = (time) ->
  hour = Math.floor(time / 3600)
  time -= hour * 3600
  minute = Math.floor(time / 60)
  time -= minute * 60
  hour = '0' + hour if hour < 10
  minute = '0' + minute if minute < 10
  time = '0' + time if time < 10
  return "#{hour}:#{minute}:#{time}"

