class PurchasesController < ApplicationController
    def create
      @purchase = Purchase.new(purchase_params)
      if @purchase.save
        render json: @purchase, status: :created
      else
        render json: @purchase.errors, status: :unprocessable_entity
      end
    end
  
    private
  
    def purchase_params
      params.require(:purchase).permit(:client_id, :amount)
    end
  end
  