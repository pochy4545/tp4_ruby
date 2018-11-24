require_relative 'serializer'
require 'json'
require 'bundler'
require 'mongoid'
Bundler.require

# configurar db
Mongoid.load! "mongoid.config"
class Carrito
  include Mongoid::Document
  field :username, type: String
  field :total, type: String
  field :fecha_creacion, type: String
  field :items
end

class Item
  include Mongoid::Document

  field :id, type: String
  field :sku, type: String
  field :description, type: String
  field :stock, type: String
  field :price, type: String

  validates :id, presence: true
  validates :sku, presence: true
  validates :description, presence: true

end
#parametros en el body
def json_params
  begin
    JSON.parse(request.body.read)
   rescue
    halt 400, { message:'Invalid JSON' }.to_json
   end
end

#sinatra
before do
    content_type :json
end

get '/items.json' do
  i=Item.all
  i.map { |item| ItemSerializer.new(item) }.to_json
end

get '/items/:id.json'do |id|
  item=Item.where(id: id).first
  halt(404, { message:'Item inexistente'}.to_json) unless item
  ItemSerializer.new(item).to_json
end

post '/items.json' do
  item = Item.new(json_params)
    if item.save
      status 201
    else
      status 422
      body ItemSerializer.new(item).to_json
    end
end

put '/items/:id.json' do |id|
  item = Item.where(id: id).first
    halt(404, { message:'No existe el item a actualizar'}.to_json) unless item
    if item.update_attributes(json_params)
      ItemSerializer.new(item).to_json
    else
      status 422
      item ItemSerializer.new(item).to_json
    end
  end

get '/cart/:username.json'do |username|
   carri=Carrito.where(username: username).first
   if carri then
      CarritoSerializer.new(carri).to_json
   else
         carrito=Carrito.create(username: username,total: "0", fecha_creacion: Date.today.to_s ,items:Array.new)
   	 if carrito.save
  	   status 201
  	   body CarritoSerializer.new(carrito).to_json
           body "carrito creado"
  	 else
  	   status 422
  	 end
  end
end

put '/cart/:username.json' do |username|
   carri=Carrito.where(username: username).first
   if carri then
      CarritoSerializer.new(carri).to_json
   else
         carrito=Carrito.create(username: username,total: "0", fecha_c$
         if carrito.save
           status 201
           body CarritoSerializer.new(carrito).to_json
           body "carrito creado"
         else
           status 422
         end
  end

put '/cart/:username/:item_id.json'do |username|
   carri=Carrito.where(username: username).first
   if carri then
      CarritoSerializer.new(carri).to_json
   else
         carrito=Carrito.create(username: username,total: "0", fecha_c$
         if carrito.save
           status 201
           body CarritoSerializer.new(carrito).to_json
           body "carrito creado"
         else
           status 422
         end
  end
end

