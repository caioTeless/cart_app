class CartServiceResult
    attr_reader :success, :data, :errors

    def initialize(success:, data: nil, errors: [])
        @success = success
        @data = data
        @errors = errors
    end

    def success?
        @success
    end

    def as_json 
        return { errors: @errors } unless success?

        cart = @data
        {
            id: cart.id,
            products: cart.cart_items.map do |cart_item|
                {
                    id: cart_item.product_id,
                    name: cart_item.product_name,
                    quantity: cart_item.quantity,
                    unit_price: cart_item.product_price,
                    total_price: cart_item.product_price * cart_item.quantity
                }
            end, 
            total_price: cart.total_price
        }
    end
end
