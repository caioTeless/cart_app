class CartService
    def initialize(params)
        @params = params
    end

    def create
        return cart_service_failure(nil, [CartServiceResult::DEFAULT_MESSAGES[:invalid_product_or_quantity]], CartServiceResult::ERROR_CODES[:unprocessable]) unless product.present?

        cart = Cart.new(total_price: total_price)
        cart.cart_items.build({ product: product, quantity: quantity } )

        cart.save!
        cart_service_success(cart)

    rescue StandardError => error
        cart_service_failure(cart, CartServiceResult::DEFAULT_MESSAGES[:internal_error], CartServiceResult::ERROR_CODES[:internal])
    end

    def update
        if cart_item.present?
            cart_item.update!(quantity: quantity)
        else
            current_cart.cart_items.create!({ product: product, quantity: quantity } )
        end

        recalculate_total_price
        cart_service_success(current_cart)
    rescue StandardError => error
        cart_service_failure(nil, [CartServiceResult::DEFAULT_MESSAGES[:invalid_product_or_quantity]], CartServiceResult::ERROR_CODES[:unprocessable])
    end

    def destroy_item
        return cart_service_failure(nil, [CartServiceResult::DEFAULT_MESSAGES[:invalid_product]], CartServiceResult::ERROR_CODES[:unprocessable]) unless cart_item.present?

        cart_item.destroy!
        recalculate_total_price

        cart_service_success(current_cart)
    rescue StandardError => error
        cart_service_failure(current_cart, [CartServiceResult::DEFAULT_MESSAGES[:internal_error]], CartServiceResult::ERROR_CODES[:internal])
    end

    def get_current_cart
        if current_cart.present?
            cart_service_success(current_cart)
        else
            cart_service_failure(current_cart, [CartServiceResult::DEFAULT_MESSAGES[:not_found]], CartServiceResult::ERROR_CODES[:not_found])
        end
    end

    private

    def current_cart
        @current_cart ||= Cart.last
    end

    def product
        @product ||= Product.find_by(id: @params[:product_id])
    end

    def quantity
        @quantity ||= (@params[:quantity] || 1).to_i
    end

    def total_price
        @total_price ||= product.price * quantity
    end

    def cart_item
        @cart_item ||= current_cart.cart_items.where(product_id: @params[:product_id]).last
    end

    def update_total_price
        current_cart.cart_items.sum { |item| item.product.price * item.quantity }
    end

    def recalculate_total_price
        current_cart.update(total_price: update_total_price)
    end

    def cart_service_success(cart)
        CartServiceResult.new(success: true, data: cart, code: 200)
    end

    def cart_service_failure(record = nil, custom_error = "", code = 404)
        CartServiceResult.new(success: false, errors: record&.errors&.full_messages.presence || custom_error || CartServiceResult::DEFAULT_MESSAGES[:unknown_error], code: code)
    end
end
