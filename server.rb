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
  field :total, type: Float
  field :fecha_creacion, type: String
  field :items
end

class Item
  include Mongoid::Document

  field :id, type: String
  field :sku, type: String
  field :description, type: String
  field :stock, type: Integer
  field :price, type: Float

end
class ItemReduce
   include Mongoid::Document
   field :id, type: String
   field :cantidad, type:Integer
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

#verificado
get '/items.json' do
  i=Item.all
  i.map { |item| ItemSerializer.new(item)}.to_json
end

#verificado
get '/items/:id.json'do |id|
  item=Item.where(id: id).first
  halt(404, { message:'Item inexistente'}.to_json) unless item
  ItemSerializer.new(item).to_json
end

#verificado
post '/items.json' do
  item = Item.new(json_params)
    if item.save
      status 201
    else
      status 422
      body ItemSerializer.new(item).to_json
    end
end
#verificado (como verifico la presencia en json_params)
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

#un array de items?
get '/cart/:username.json'do |username|
   carri=Carrito.where(username: username).first
   if carri then
      CarritoSerializer.new(carri).to_json
   else
         carrito=Carrito.create(username: username,total: "0", fecha_creacion: Date.today.to_s ,items:Array.new)
   	 if carrito.save
  	   status 201
  	   body "Carritocreado:"+CarritoSerializer.new(carrito).to_json
           
  	 else
  	   status 422
  	 end
  end
end

put '/cart/:username.json' do |username|
   carri=Carrito.where(username: username).first
   item = ItemReduce.new(json_params)
   if carri then
      carri.update(items:carri.items << ItemReduceSerialize.new(item).to_json)
   else
         carrito=Carrito.create(username: username,total: "0", fecha_creacion: Date.today.to_s ,items:Array.new)
         if carrito.save
           status 201
           carrito.update(items:carri.items << ItemReduceSerialize.new(item).to_json)
         else
           status 422
         end
  end
end

delete '/cart/:username/:item_id.json'do 
   carri=Carrito.where(username: params[:splat].first).first
   if carri then
      #borro item
   else
         carrito=Carrito.create(username: params[:splat].first)
         if carrito.save
           status 201
           body CarritoSerializer.new(carrito).to_json
           body "carrito creado"
         else
           status 422
         end
  end
end


#middlewares Rack para que?
