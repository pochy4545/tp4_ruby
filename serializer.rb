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

