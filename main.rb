require 'net/http'
require 'json'
require 'uri'
require 'colorize'

class SelfBot
  def initialize(token)
    @token = token
    @headers = {
      'Authorization' => token,
      'Content-Type' => 'application/json',
      'User-Agent' => 'Mozilla/5.0'
    }
  end

  def start
    system('clear') || system('cls')
    red = "\033[0;31m"
    green = "\033[0;32m"
    yellow = "\033[0;33m"
    blue = "\033[0;34m"
    reset = "\033[0m"
    puts "#{green}//////////////////////////////////////////////////////////////////////////#{green}"
    puts "#{green}//#{red}██████╗ ██╗   ██╗██████╗ ██╗   ██╗    #{blue}███████╗███████╗██╗     ███████╗#{green}//"
    puts "#{green}//#{red}██╔══██╗██║   ██║██╔══██╗╚██╗ ██╔╝    #{blue}██╔════╝██╔════╝██║     ██╔════╝#{green}//"
    puts "#{green}//#{red}██████╔╝██║   ██║██████╔╝ ╚████╔╝     #{blue}███████╗█████╗  ██║     █████╗  #{green}//"
    puts "#{green}//#{red}██╔══██╗██║   ██║██╔══██╗  ╚██╔╝      #{blue}╚════██║██╔══╝  ██║     ██╔══╝  #{green}//"
    puts "#{green}//#{red}██║  ██║╚██████╔╝██████╔╝   ██║       #{blue}███████║███████╗███████╗██║     #{green}//"
    puts "#{green}//#{red}╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ╚═╝       #{blue}╚══════╝╚══════╝╚══════╝╚═╝     #{green}//"
    puts "#{green}//////////////////////////////////////////////////////////////////////////#{green}"
    puts "#{green}//                                                                      #{green}//"
    puts "#{green}//    #{yellow}Developer: 171ntw                                                 #{green}//"
    puts "#{green}//    #{blue}Type: #{green}Free                                                        //"
    puts "#{green}//                                                                      #{green}//"
    puts "#{green}//////////////////////////////////////////////////////////////////////////#{green}"
    
    loop do
      show_menu
    end
  end

  private

  def show_menu
    puts "\n[1] Clear DM/Channel".cyan
    puts "[2] Clear ALL".cyan
    puts "[3] Remove All Friends".cyan
    puts ""
    puts "[X] Close Panel".cyan
    print "\nSelect an option: ".yellow
    choice = gets.chomp.upcase

    case choice
    when '1'
      clear_dm_channel
    when '2'
      clear_all
    when '3'
      remove_all_friends
    when 'X'
      exit
    else
      puts "\n[!] Invalid option!".red
    end
  end

  def clear_dm_channel
    puts "\n[#{Time.now.strftime('%H:%M:%S')}] Clearing messages...".yellow
    
    channels = get_channels
    return if channels.empty?

    puts "\nAvailable channels:".cyan
    channels.each_with_index do |channel, index|
      name = channel['name'] || "DM with #{channel['recipients'][0]['username']}"
      puts "[#{index + 1}] #{name}"
    end

    print "\nSelect channel number: ".yellow
    choice = gets.chomp.to_i - 1
    return if choice < 0 || choice >= channels.length

    channel = channels[choice]
    channel_id = channel['id']

    print "\nAre you sure you want to clear all messages? (y/n): ".yellow
    return unless gets.chomp.downcase == 'y'

    begin
      messages = get_messages(channel_id)
      messages.each do |message|
        if message['author']['id'] == get_self_id
          delete_message(channel_id, message['id'])
          print ".".green
          sleep(1.5)
        end
      end
      puts "\n[#{Time.now.strftime('%H:%M:%S')}] Messages cleared successfully!".green
    rescue => e
      if e.message.include?('429')
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Rate limit hit! Waiting 5 seconds...".yellow
        sleep(5)
        retry
      else
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Error clearing messages: #{e.message}".red
      end
    end
  end

  def clear_all
    puts "\n[#{Time.now.strftime('%H:%M:%S')}] Clearing all messages...".yellow
    
    print "\n⚠️ WARNING: This will clear ALL your messages in ALL channels. Continue? (y/n): ".yellow
    return unless gets.chomp.downcase == 'y'

    begin
      channels = get_channels
      channels.each do |channel|
        channel_id = channel['id']
        channel_name = channel['name'] || "DM with #{channel['recipients'][0]['username']}"
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Clearing #{channel_name}...".yellow
        
        messages = get_messages(channel_id)
        messages.each do |message|
          if message['author']['id'] == get_self_id
            delete_message(channel_id, message['id'])
            print ".".green
            sleep(1.5)
          end
        end
      end
      puts "\n[#{Time.now.strftime('%H:%M:%S')}] All messages cleared successfully!".green
    rescue => e
      if e.message.include?('429')
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Rate limit hit! Waiting 5 seconds...".yellow
        sleep(5)
        retry
      else
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Error clearing messages: #{e.message}".red
      end
    end
  end

  def remove_all_friends
    puts "\n[#{Time.now.strftime('%H:%M:%S')}] Removing all friends...".yellow
    
    print "\n⚠️ WARNING: This will remove ALL your friends. Continue? (y/n): ".yellow
    return unless gets.chomp.downcase == 'y'

    begin
      friends = get_friends
      total = friends.length
      
      friends.each_with_index do |friend, index|
        username = friend['user']['username']
        user_id = friend['user']['id']
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Removing #{username} (#{index + 1}/#{total})...".yellow
        remove_friend(user_id)
        print ".".green
        sleep(2)
      end
      
      puts "\n[#{Time.now.strftime('%H:%M:%S')}] All friends removed successfully!".green
    rescue => e
      if e.message.include?('429')
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Rate limit hit! Waiting 5 seconds...".yellow
        sleep(5)
        retry
      else
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Error removing friends: #{e.message}".red
      end
    end
  end

  def get_self_id
    uri = URI('https://discord.com/api/v9/users/@me')
    response = make_request(uri)
    JSON.parse(response.body)['id']
  end

  def get_channels
    uri = URI('https://discord.com/api/v9/users/@me/channels')
    response = make_request(uri)
    JSON.parse(response.body)
  end

  def get_messages(channel_id, limit = 100)
    uri = URI("https://discord.com/api/v9/channels/#{channel_id}/messages?limit=#{limit}")
    response = make_request(uri)
    JSON.parse(response.body)
  end

  def delete_message(channel_id, message_id)
    uri = URI("https://discord.com/api/v9/channels/#{channel_id}/messages/#{message_id}")
    make_request(uri, 'DELETE')
  end

  def get_friends
    uri = URI('https://discord.com/api/v9/users/@me/relationships')
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = @token
    request['User-Agent'] = 'Mozilla/5.0'
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    if response.code != '200'
      raise "Error searching for friends"
    end
  
    data = JSON.parse(response.body)
  end

  def remove_friend(user_id)
    uri = URI("https://discord.com/api/v9/users/@me/relationships/#{user_id}")
    request = Net::HTTP::Delete.new(uri)
    request['Authorization'] = @token
    request['Content-Type'] = 'application/json'
    request['User-Agent'] = 'Mozilla/5.0'
    request.body = { type: 2 }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    response = http.request(request)
    unless response.code.start_with?('2')
      error_body = JSON.parse(response.body) rescue {}
      error_message = error_body['message'] || response.message
      raise "API Error: #{response.code} - #{error_message}"
    end
    response
  end

  def make_request(uri, method = 'GET')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = case method
    when 'GET'
      Net::HTTP::Get.new(uri)
    when 'DELETE'
      Net::HTTP::Delete.new(uri)
    end

    request['Authorization'] = @token
    request['Content-Type'] = 'application/json'
    request['User-Agent'] = 'Mozilla/5.0'
    
    begin
      response = http.request(request)
      
      if response.code == '429'
        retry_after = response['Retry-After'].to_i
        puts "\n[#{Time.now.strftime('%H:%M:%S')}] Rate limit hit! Waiting #{retry_after} seconds...".yellow
        sleep(retry_after)
        return make_request(uri, method)
      end

      unless response.code.start_with?('2')
        error_body = JSON.parse(response.body) rescue {}
        error_message = error_body['message'] || response.message
        raise "API Error: #{response.code} - #{error_message}"
      end

      response
    rescue => e
      if e.message.include?('429')
        sleep(5)
        return make_request(uri, method)
      end
      raise e
    end
  end
end

puts "Starting SelfBot...".cyan
bot = SelfBot.new(ENV['token'])
bot.start