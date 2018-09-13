require 'sinatra/base'
require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'net/http'
require 'uri'
require 'gtfs_reader'

##
# WeGo Bus Map
class WeGoBusMap < Sinatra::Base
  VEHICLE_POSITIONS_URL = 'http://transitdata.nashvillemta.org/TMGTFSRealTimeWebService/vehicle/vehiclepositions.pb'.freeze
  TRIP_UPDATES_URL = 'http://transitdata.nashvillemta.org/TMGTFSRealTimeWebService/tripupdate/tripupdates.pb'.freeze
  ALERTS_URL = 'http://transitdata.nashvillemta.org/TMGTFSRealTimeWebService/alert/alerts.pb'.freeze
  DATA_DIRECTORY = File.join(__dir__, 'data', 'gtfs')

  get '/' do
    erb :index
  end

  get '/gtfs/realtime/vehiclepositions.json' do
    positions = []
    data = Net::HTTP.get(URI.parse(VEHICLE_POSITIONS_URL))
    feed = Transit_realtime::FeedMessage.decode(data)

    feed.entity.each do |entity|
      positions << entity
    end
    cache_control :public, max_age: 10
    response.headers['content-type'] = 'application/json'
    positions.to_json
  end

  get '/gtfs/realtime/tripupdates.json' do
    updates = []
    data = Net::HTTP.get(URI.parse(TRIP_UPDATES_URL))
    feed = Transit_realtime::FeedMessage.decode(data)
    feed.entity.each do |entity|
      updates << entity
    end
    cache_control :public, max_age: 10
    response.headers['content-type'] = 'application/json'
    updates.to_json
  end

  get '/gtfs/realtime/alerts.json' do
    alerts = []
    data = Net::HTTP.get(URI.parse(ALERTS_URL))
    feed = Transit_realtime::FeedMessage.decode(data)
    feed.entity.each do |entity|
      alerts << entity
    end
    cache_control :public, max_age: 10
    response.headers['content-type'] = 'application/json'
    alerts.to_json
  end

  get '/gtfs/routes/:route_id.json' do
    cache_control :public, max_age: 300
    response.headers['content-type'] = 'application/json'
    File.read(File.join(DATA_DIRECTORY, 'routes', "#{params['route_id']}.json"))
  end

  get '/gtfs/trips/:trip_id.json' do
    cache_control :public, max_age: 300
    response.headers['content-type'] = 'application/json'
    File.read(File.join(DATA_DIRECTORY, 'trips', "#{params['trip_id']}.json"))
  end

  get '/gtfs/shapes/:shape_id.json' do
    cache_control :public, max_age: 300
    response.headers['content-type'] = 'application/json'
    File.read(File.join(DATA_DIRECTORY, 'shapes', "#{params['shape_id']}.json"))
  end

  # start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME
end
