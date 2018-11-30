require_relative 'serializer'
require 'json'
require 'bundler'
require 'mongoid'
Bundler.require
require_relative 'model'
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
  unless (item.sku.nil? or item.description.nil? or item.stock.nil? or item.price.nil?)then
    if item.save
      status 201
      body ItemSerializer.new(item).to_json
    else
      status 422
    end
  else
   status 422
  end
end
#verificado
put '/items/:id.json' do |id|
  item = Item.where(id: id).first
    halt(404, { message:'No existe el item a actualizar'}.to_json) unless item
    j=json_params 
    if((j.include?("sku")and not j["sku"].blank?)or( j.include?("description")and not j["description"].blank?) or (j.include?("stock")and not j["stock"].blank?) or (j.include?("price")and not j["prcie"].blank?))then
   	 if item.update_attributes(j)
   	    ItemSerializer.new(item).to_json
   	  else
   	    status 422
   	  end
     else
        status 422
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
  	   body "Carritocreado:"+CarritoSerializer.new(carrito).to_json
           
  	 else
  	   status 422
  	 end
  end
end

put '/cart/:username.json' do |username|
   carri=Carrito.where(username: username).first
   j=json_params
   if(j.include?("id")and not j["id"].blank?) and (j.include?("cantidad")and not j["cantidad"].blank?)then
  	 item = ItemReduce.new(j)
         if( Item.where(id:item.id).first.nil?)then
             halt 404, { message:'No existe el item a agregar'}.to_json 
  	 else
            if Item.where(id: item.id).first.stock.to_i >= item.cantidad.to_i then
        	 if carri then
  		    carri.update(items:carri.items << ItemReduceSerialize.new(item).to_json)
  		 else
  		       carrito=Carrito.create(username: username,total: "0", fecha_creacion: Date.today.to_s ,items:Array.new)
  		       if carrito.save
  		         status 201
        		   carrito.update(items:carrito.items << ItemReduceSerialize.new(item).to_json )
        		 else
        		   status 422
        		 end
 		 end
             else
               halt 404, { message:'no hay tanto stock en el producto selecionado'}.to_json
             end
           end
   else
       halt 404, { message:'se debe recivir id y cantidad'}.to_json
   end
end

delete '/cart/:username/:item_id.json'do |username, item_id| 
   carri=Carrito.where(username: username).first
   if carri then
        carri.update(items:carri.items.reject{|i| i["id"]==item_id})
        status 200
   else
         carrito=Carrito.create(username: username,total: "0", fecha_creacion: Date.today.to_s ,items:Array.new)
         if carrito.save
           body CarritoSerializer.new(carrito).to_json
           halt 201, { message:'se te creeo un carrito nuevo'}.to_json
         else
           status 422
         end
  end
end
