require 'sinatra'
require 'open-uri'

LG_PGN_URL = 'http://www.littlegolem.net/jsp/game/png.jsp'
LG_GAME_URL = 'http://www.littlegolem.net/jsp/game/game.jsp'

VARIANT_8x8_RE = /Lines of Action-Size 8x8/
VARIANT_BLACKHOLE_RE = /Lines of Action-Black Hole/
VARIANT_SCRAMBLE_RE = /Lines of Action-Scramble/
VARIANT_QUICK_RE = /Lines of Action-Quick/

def detect_loa_variant(url)
  open(url) do |f|
    f.each_line do |line|
      case line
      when VARIANT_8x8_RE
        return '8x8'
      when VARIANT_BLACKHOLE_RE
        return 'BlackHole'
      when VARIANT_SCRAMBLE_RE
        return 'Scramble'
      when VARIANT_QUICK_RE
        return 'Quick'
      end
    end
    return 'Unknown'
  end
end

def render_game(id)
  $game_id = id

  pgn_url = "#{LG_PGN_URL}?gid=#{id}"
  $pgn = open(pgn_url).read().gsub(/\r|\n/, "")

  game_url = "#{LG_GAME_URL}?gid=#{id}"
  $variant = detect_loa_variant(game_url)

  erb :index
end

get '/' do
  $pgn = ''
  $variant = '8x8'
  erb :index
end

get '/lg/:id' do
  id = params[:id]
  render_game(id)
end

get '/lg-:id' do
  id = params[:id]
  render_game(id)
end

