# Description:
#   A stock module
#
# Dependencies:
#   ya-csv
#
# Configuration:
#   None
#
# Commands:
#   hubot stock me <ticker1> [<ticker2>] ... - show current prices for <tickers>
#   hubot stock-chart me -(5d|2w|2mon|1y) <ticker> - show stock chart for <ticker>
#
# Author:
#   jazzychad
#   Chad Etzel

csv = require('ya-csv')

class YStock

  constructor: (@msg, @tickers) ->

  getInfo: ->
    msg = @msg
    ticks = @tickers.join("+")
    # see http://www.gummy-stuff.org/Yahoo-data.htm for formatting info
    @msg.http("http://download.finance.yahoo.com/d/quotes.csv?s=#{ticks}&f=snl1")
      .get() (err, res, body) ->
        parser = csv.createCsvStreamReader()
        parser.addListener 'data', (data) ->
          tick = data[0]
          name = data[1]
          price = data[2]
          msg.send "#{tick} (#{name}): $#{price}"

        parser.parse body


module.exports = (robot) ->

  robot.respond /stock( me)? (.*)/i, (msg) ->
    tickers = msg.match[2]
    tickers = tickers.split(" ")
    ystock = new YStock msg, tickers
    ystock.getInfo()

  robot.respond /stock-chart( me)?( -(\d+\w+))? (.*)/i, (msg) ->
    ticker = msg.match[4]
    time = msg.match[3] || '1d'
    msg.send "http://chart.finance.yahoo.com/z?s=#{ticker}&t=#{time}&q=l&l=on&z=l&a=v&p=s&lang=en-US&region=US#.png"
