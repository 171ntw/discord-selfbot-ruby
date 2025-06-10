module Clear
  require 'colorize'

  def self.dm(event)
    user = event.author
    channel = event.channel

    puts "Starting to clear messages from #{user.name} in channel ##{channel.name}...".yellow
    deleted_count = 0

    loop do
      messages = channel.history(100).select { |msg| msg.author.id == user.id }
      break if messages.empty?

      messages.each do |msg|
        begin
          msg.delete
          deleted_count += 1
          print "[+] Message deleted!\n".green
        rescue => e
          puts "[-] Error: Failed to delete message: #{e.message}\n".red
        end
      end
    end

    puts "[✓] Successfully cleared #{deleted_count} messages".green
  end
end