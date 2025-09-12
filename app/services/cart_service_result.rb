class CartServiceResult
    attr_reader :success, :data, :errors, :code

    DEFAULT_MESSAGES = {
        invalid_product: 'Produto inválido para exclusão',
        invalid_product_or_quantity: 'Produto ou quantidade inválida',
        not_found: 'Registro não encontrado',
        internal_error: 'Erro interno do servidor',
        unknown_error: 'Erro desconhecido'
    }

    ERROR_CODES = {
        not_found: 404,
        unprocessable: 422,
        forbidden: 403,
        internal: 500,
        unavailable: 503
    }

    def initialize(success:, data: nil, errors: [], code: nil)
        @success = success
        @data = data
        @errors = errors
        @code = code
    end

    def success?
        @success
    end

    def as_json 
        return { success: false, errors: @errors, code: @code } unless success?

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
