class ClientsController < ApplicationController
    def index
      @clients = Client.all
      render json: @clients
    end
  
    def show
      @client = Client.find(params[:id])
      render json: @client
    end
  
    def create
      @client = Client.new(client_params)
      if @client.save
        render json: @client, status: :created
      else
        render json: @client.errors, status: :unprocessable_entity
      end
    end
  
    private
  
    def client_params
      params.require(:client).permit(:name)
    end
  end