class CartsController < ApplicationController
  # GET /cart
  def show
    response = CartService.new(cart_params).get_current_cart

    render json: response.as_json, status: :ok
  end

  # POST /cart
  def create
    response = CartService.new(cart_params).create

    render json: response.as_json, status: response.success? ? :created : :unprocessable_entity
  end

  # PUT PATCH /cart 
  def add_item
    response = CartService.new(cart_params).update

    render json: response.as_json, status: response.success? ? :ok : :unprocessable_entity
  end

  # DELETE /cart/:product_id
  def destroy_item
    response = CartService.new(cart_params).destroy_item

    render json: response.as_json, status: response.success? ? :ok : :unprocessable_entity
  end

  private 

  def cart_params
    params.except(:cart).permit(:product_id, :quantity)
  end
end
