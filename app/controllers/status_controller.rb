class StatusController < ApplicationController

  def index
    connected = ActiveRecord::Base.connection_handler.connected?(ActiveRecord::Base)
    render json: { db: connected ? 'connected' : 'disconnected',
                   tag: ENV.fetch('TAG', 'undefined') }
  end
end
