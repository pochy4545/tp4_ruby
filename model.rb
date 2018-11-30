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

