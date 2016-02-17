_ = require('underscore')

module.exports = class ReplyContext

  constructor: (@defaultBot, @messageBot, @sourceMessage) ->

  isSlashCommand: ->
    !!@messageBot.res

  replyPrivate: (message, cb) ->
    @hasRepliedToSlashCommand = true
    if @isSlashCommand()
      @messageBot.replyPrivateDelayed(@sourceMessage, message, cb)
    else
      @replyPublic(message, cb)

  replyPublic: (message, cb) ->
    if @isSlashCommand()
      @messageBot.replyPublicDelayed(@sourceMessage, message, cb)
    else
      @defaultBot.reply(@sourceMessage, message, cb)

  ifCanEditReply: (ifTrue, ifFalse) ->
    console.log("Checking if in channel...", @sourceMessage)
    @defaultBot.api.channels.list {}, (err, response) =>
      if err
        console.error(err)
        ifFalse()
      else
        channelInfo = _.find(response.channels, (c) => c.id == @sourceMessage.channel)
        console.log("found channel", channelInfo)
        if channelInfo?.is_member
          ifTrue()
        else
          @defaultBot.api.groups.list {}, (err, response) =>
            if err
              console.error(err)
              ifFalse()
            else
              groupInfo = _.find(response.groups, (c) => c.id == @sourceMessage.channel)
              console.log("found group", groupInfo)
              if groupInfo?.is_member
                ifTrue()
              else
                ifFalse()

  say: (message, cb) ->
    params = _.extend({}, {channel: @sourceMessage.channel}, message)
    if @isSlashCommand()
      @replyPublic(params, (err, res) =>
        cb(res)
      )
    else
      @defaultBot.say(params, (err, res) =>
        cb(res)
      )
