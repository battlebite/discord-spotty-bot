require 'bundler'
Bundler.require(:default, :spotty)
require_relative 'music.rb'

####Setup/Config####
# Discord Developer App Details
discord_bot_token = ''	# App Client ID
discord_client_id = 0	# Integer
# Spotify Developer App Details
spotify_client_id = '' # Ex. '74ff9d8772ee4090ad930086753eg669'
spotify_client_secret = '' # Ex. '6e4fs9b5c01f43a8arr2aeb1710e5ea8'
# Discord Server Details
discord_admin = '' # Discord account name allowed to control Spotty
														 # NOTE: Do NOT add numbers after account name
														 # Ex. 'Bob Saget'
discord_text_channel = '' # Name of text channel to communicate with Spotty
																						 # NOTE: don't forget the '#'
																						 # Ex. '#music_bot_requests'
# Spotify Account/Playlist Details
spotify_user = '' # Spotify account with playlist here
playlist_name = '' # Spotify playlist associated with account

####################

# Discord API Connect
bot = Discordrb::Bot.new token: discord_bot_token, client_id: discord_client_id
bot_voice = nil

# Spotify API Connect
RSpotify.authenticate(spotify_client_id, spotify_client_secret)
spot = RSpotify::User.find(spotify_user)
spot.playlists.each do |list|
	if list.name == playlist_name
		@playlist = list
		puts "Playlist set to " + @playlist.name
	end
end
music = Music.new(@playlist);

# Spotty should list commands and give any info regarding itself
bot.message(content: '!spotty', in: discord_text_channel) do |event|
  event.respond 'Hi, I\'m a bot built by Battlebite'
end

# Spotty will enter the room and play it's playlist from Spotify
bot.message(content: '!spotty play', in: discord_text_channel, from: discord_admin) do |event|
	# Search through voice channels until user is found
	voice_channel = nil
	servers = bot.servers
	servers.each do |id, server|
		channels = server.channels
		channels.each do |channel|
			if channel.type == 2
				users = channel.users
				users.each do |user|
					if user.username == discord_admin
						voice_channel = channel
						break
					end
				end
			end
		end
	end

	# Check if already in voice channel
	if voice_channel != nil
		# Connect to voice channel
		bot_voice = bot.voice_connect(voice_channel)
		# Start playing
		event.respond 'Prepping tunes'
		music.start()
		if (music.success?)
			event.voice.play_file('song.mp3')
			event.respond 'Playing Spotify playlist :D'
		else
			event.respond 'Something went wrong :\\'
		end
	else
		event.respond 'You\'re not in a voice channel dude...'
	end

end

# Spotty will stop playing the playlist and leave the room
bot.message(content: '!spotty stop', in: '#music_bot_requests', from: discord_admin) do |event|
	if bot_voice != nil
		bot_voice.destroy
		bot_voice = nil
		music.stop
		event.respond 'Shutting down the tunes'
	else
		event.respond 'There\'s not much to stop dude -_-'
	end
end

# Spotty will skip the current song and play the next and display song
bot.message(content: '!spotty next', in: '#music_bot_requests', from: discord_admin) do |event|
end

# Spotty will go back one song and display song
bot.message(content: '!spotty prev', in: '#music_bot_requests', from: discord_admin) do |event|
end

# Spotty will toggle shuffle and display status
bot.message(content: '!spotty shuffle', in: '#music_bot_requests', from: discord_admin) do |event|
end

# Spotty will toggle repeat and display status
bot.message(content: '!spotty repeat', in: '#music_bot_requests', from: discord_admin) do |event|
end

# Spotty will add song to playlist and display status
bot.message(content: '!spotty add', in: '#music_bot_requests', from: discord_admin) do |event|
end

# Spotty will remove song from playlist and display status
bot.message(content: '!spotty remove', in: '#music_bot_requests', from: discord_admin) do |event|
end

bot.run
