require 'sinatra'
require 'open-uri'

LG_URL = 'http://www.littlegolem.net/jsp/game/png.jsp'

get '/' do
  $pgn = ''
  erb :index
end

get '/lg/:id' do
  id = params[:id]
  $game_id = id
  url = "#{LG_URL}?gid=#{id}"

  open(url) do |f|
    $pgn = ""
    f.each_line { |line| $pgn += line }
  end

  $pgn.gsub!(/\r|\n/, "")

  erb :index
end
