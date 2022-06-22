require "id3tag"
require "fileutils"

playlist_filename = "some.pls"
dest_folder = "exported_playlist_folder"

music_files = []

def parse_line(line)
  return unless line.start_with?("File")

  parsed_data = line.match(/File\d{1,3}=(.*)/)
  return unless parsed_data

  parsed_data[1]
end

File.readlines(playlist_filename).each do |line|
  file_name = parse_line(line)
  next unless file_name

  music_files << { file_name: file_name }
end

music_files.map! do |file_data|
  mp3_file = File.open(file_data[:file_name], "rb")
  tag = ID3Tag.read(mp3_file)

  file_data.merge(
    artist: tag.artist,
    title: tag.title
  )
end

FileUtils.mkdir dest_folder
music_files.each_with_index do |file_data, index|
  dest_file_name = "#{dest_folder}/#{index + 1} - #{file_data[:artist]} - #{file_data[:title]}.mp3"

  FileUtils.cp file_data[:file_name], dest_file_name

  puts "#{file_data[:file_name]} copied to #{dest_file_name}"
end

puts "done"
