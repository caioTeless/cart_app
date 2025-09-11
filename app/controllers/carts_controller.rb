class CartsController < ApplicationController

  def show
    @cart = Cart.last

    render json: {id: @cart.id, products: @cart.cart_items.as_json(include: :product), total_price: @cart.total_price}
  end

  def create
    ActiveRecord::Base.transaction do
      product = Product.where(id: params[:product_id]).first
      total_price = product.price * (params[:quantity] || 1)
      cart = Cart.new(total_price: total_price)
      cart.cart_items.build({ product: product, quantity: params[:quantity] || 1 } )
      cart.save!

      render json: {id: cart.id, products: cart.cart_items.as_json(include: :product), total_price: cart.total_price}, status: :created
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def add_item
    ActiveRecord::Base.transaction do
      cart = Cart.last
      product = Product.where(id: params[:product_id]).first
      cart_item = cart.cart_items.where(product_id: product.id).first

      if cart_item
        cart_item.update(quantity: params[:quantity])
      else
        cart.cart_items.create!({ product: product, quantity: params[:quantity] || 1 } )
        cart.save!
      end

      cart.update!(total_price: cart.cart_items.sum { |item| item.product.price * item.quantity })

      render json: {id: cart.id, products: cart.cart_items.as_json(include: :product), total_price: cart.total_price}, status: :ok
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # DELETE /cart/:product_id
  def destroy_item
    cart_item = CartItem.where(product_id: params[:product_id]).last
    cart = cart_item.cart
    cart_item.destroy!

    cart.update!(total_price: cart.cart_items.sum { |item| item.product.price * item.quantity })

    render json: {id: cart.id, products: cart.cart_items.as_json(include: :product), total_price: cart.total_price}, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end
end
