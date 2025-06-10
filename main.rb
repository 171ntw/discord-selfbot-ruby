require 'discordrb'
require 'dotenv'
require './functions/clear'

Dotenv.load

bot = Discordrb::Bot.new type: :user, token: ENV['token']
bot.should_parse_self = true

bot.message do |event|
    if event.message.author.id == bot.profile.id && event.message.content.include?('!clear')
        Clear.dm(event)
    end
end

bot.ready do |event|
    puts "Self-Bot online and ready! Logged in as #{bot.profile.username} (ID: #{bot.profile.id})".green
end

bot.run