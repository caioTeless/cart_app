require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let!(:product) { Product.create!(name: "Test Product", price: 10.0) }
  let!(:cart) { Cart.create!(total_price: product.price * 2) }
  let!(:cart_item) { CartItem.create!(cart: cart, product: product, quantity: 2) }
  let(:valid_params) { { product_id: product.id, quantity: 2 } }

  let(:expected_json) do
    {
      id: cart.id,
      products: [
        {
          id: product.id,
          name: product.name,
          quantity: 2,
          unit_price: product.price.to_f,
          total_price: (product.price * 2).to_f
        }
      ],
      total_price: cart.total_price.to_f
    }
  end

  describe "GET /cart" do
    subject(:service_result) { CartService.new({}).get_current_cart }

    it "returns the current cart as JSON" do
      json = service_result.as_json
      expect(json).to eq(expected_json)
    end
  end

  describe "POST /cart" do
    subject(:service_result) { post "/cart", params: valid_params, as: :json }

    it "creates a new cart with the product" do
      expect { service_result }.to change { Cart.count }.by(1)
        .and change { CartItem.count }.by(1)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:products].first[:id]).to eq(product.id)
      expect(json[:products].first[:quantity]).to eq(2)
      expect(json[:total_price].to_f).to eq(product.price * 2)
    end

    context "when product is missing" do
      let(:invalid_params) { { product_id: nil, quantity: 2 } }

      it "returns an unprocessable_entity response with errors" do
        post "/cart", params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body, symbolize_names: true)

        expect(json[:success]).to be_falsey
        expect(json[:errors]).to include("Produto ou quantidade inválida")
        expect(json[:code]).to eq(422)
      end
    end
  end

  describe "PATCH /cart/add_item" do
    let!(:cart) { Cart.create!(total_price: 0.0) }
    let!(:product) { Product.create!(name: "Test Product", price: 10.0) }

    context "with valid parameters" do
      context "when product is already in the cart" do
        let!(:cart_item) { CartItem.create!(cart: cart, product: product, quantity: 2) }
        let(:params) { { product_id: product.id, quantity: 1 } }

        it "updates the requested cart item and total price" do
          patch '/cart/add_item', params: params, as: :json
          cart.reload
          expect(cart.cart_items.find_by(product: product).quantity).to eq(3)
          expect(cart.total_price).to eq(30.0)
        end

        it "renders a JSON response with the updated cart" do
          patch '/cart/add_item', params: params, as: :json
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))
        end
      end

      context "when product is not in the cart" do
        let(:new_product) { Product.create!(name: "New Product", price: 5.0) }
        let(:params) { { product_id: new_product.id, quantity: 2 } }

        it "creates a new cart item and updates total price" do
          expect {
            patch '/cart/add_item', params: params, as: :json
          }.to change { CartItem.count }.by(1)
          cart.reload
          expect(cart.total_price).to eq(30.0)
        end

        it "renders a JSON response with the new cart item" do
          patch '/cart/add_item', params: params, as: :json
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))
        end
      end
    end

    context "with invalid parameters" do
      let(:params) { { product_id: 521, quantity: 1 } }

      it "renders a JSON response with errors" do
        patch '/cart/add_item', params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:errors]).to include("Produto ou quantidade inválida")
        expect(json[:code]).to eq(422)
      end
    end
  end

  describe "DELETE /destroy_item" do
    let!(:cart_item) { CartItem.create!(cart: cart, product: product, quantity: 2) }
    let(:params) { { product_id: product.id } }

    subject(:request) { delete '/cart/destroy_item', params: params, as: :json }

    context "when the product exists in the cart" do
      before do 
        CartService.new(params.merge(cart: cart)).destroy_item
      end

      it "removes the item from the cart" do
        expect { cart_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "updates the total price of the cart" do
        expect(cart.reload.total_price).to eq(0.0)
      end
    end

    context "when the product does not exist in the cart" do
      let(:params) { { product_id: 111 } } 

      it "returns an unprocessable_entity response with errors" do
        request

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:success]).to be_falsey
        expect(json[:errors]).to include("Produto inválido para exclusão")
        expect(json[:code]).to eq(422)
      end
    end
  end
end
