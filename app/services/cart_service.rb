class CartService
    def initialize(params)
        @params = params
    end

    def create
        cart = Cart.new(total_price: total_price)
        cart.cart_items.build({ product: product, quantity: quantity } )

        if cart.save
            cart_service_success(cart)
        else
            cart_service_failure(cart)
        end
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
        cart_service_failure(current_cart)
    end

    def destroy_item
        cart_item.destroy
        recalculate_total_price

        cart_service_success(current_cart)
    rescue StandardError => error
        cart_service_failure(current_cart)
    end

    def get_current_cart
        if current_cart.present?
            cart_service_success(current_cart)
        else
            cart_service_failure(Cart.new)
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
        CartServiceResult.new(success: true, data: cart)
    end

    def cart_service_failure(cart)
        CartServiceResult.new(success: false, errors: cart.errors.full_messages)
    end
end
