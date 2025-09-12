class CartsController < ApplicationController

  # GET /cart
  def show
    response = CartService.new(params).get_current_cart

    render json: response.as_json, status: :ok
  end

  # POST /cart
  def create
    response = CartService.new(params).create

    render json: response.as_json, status: response.success? ? :created : :unprocessable_entity
  end

  # PUT PATCH /cart 
  def add_item
    response = CartService.new(params).update

    render json: response.as_json, status: response.success? ? :ok : :unprocessable_entity
  end

  # DELETE /cart/:product_id
  def destroy_item
    response = CartService.new(params).destroy_item

    render json: response.as_json, status: response.success? ? :ok : :unprocessable_entity
  end
end
