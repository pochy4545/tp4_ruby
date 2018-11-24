class ItemSerializer
  def initialize(item)
    @item = item
  end

  def as_json(*)
    data = {
      id:@item.id.to_s,
      sku:@item.sku,
      description:@item.description,
      stock:@item.stock,
      price:@item.price
    }
    data[:errors] = @item.errors if@item.errors.any?
    data
  end
end

class CarritoSerializer
  def initialize(carrito)
    @carrito =carrito
  end

 def as_json(*)
   data= {
     id:@carrito.id.to_s,
     fecha_creacion:@carrito.fecha_creacion,
     total:@carrito.total,
     username:@carrito.username,
     items:@carrito.items
    }
    data[:errors] = @carrito.errors if@carrito.errors.any?
    data
  end

end
