require 'open-uri'
class Music

	def playlist
		return @playlist
	end
	def current_song
		return @current_song
	end
	def current_artist
		return @current_artist
	end
	def playing?
		return @playing
	end
	def success?
		return @success
	end

	def initialize(playlist)
		@playlist = playlist
		@playing = false
		@current_song = nil
		@current_artist = nil
		@song_finished = false
		@success = false
	end

	def song_setup(song, artist = "")
		@current_song = song
		@current_artist = artist
	end

	def start()
		song = @playlist.tracks.first
		song_name = song.name
		song_artist = song.artists.first.name
		song_setup(song_name, song_artist)
		@playing = true
		if @playing
			play(song_name, song_artist)
		end
	end

	def play(song, artist = "")
		# Parse song names
		parsed_search_string = song.gsub(' ', '+') + "+" + artist.gsub(' ', '+')
		# Youtube search
		youtube_address = 'https://www.youtube.com/results?sp=EgIQAQ%253D%253D&q=' + parsed_search_string
		puts "Address searched is: " + youtube_address
		search_doc = Nokogiri::HTML(open(youtube_address))
		result = search_doc.at_css('//a.yt-uix-tile-link/@href')
		link = 'https://www.youtube.com' + result

		puts link
		# Download video
		options = {
		  format: 'worstaudio',
	  	extract_audio: "true",
	  	audio_format: "mp3",
	  	output: 'song.%(ext)s'
		}
		puts "Downloading " + song + " by " + artist
		begin
			YoutubeDL.download link, options
		rescue
			@playing = false
			@success = false
			puts "Download Failed" 
		else 
			@success = true
			puts "Download Successful"
		end
		# Set current song and artist
		@current_song = song
		@current_artist = artist

		if @song_finished == true
			next_song
		end
	end

	def stop
		@playing = false
	end

	def next_song
		# Get next song in playlist then play
		song = nil
		artist = nil
		play(song, artist)
	end

	def prev_song
		song = nil
		artist = nil
		play(song, artist)
	end

end