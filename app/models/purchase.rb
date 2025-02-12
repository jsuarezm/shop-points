class Purchase < ApplicationRecord
  belongs_to :client
  after_create :update_client_points

  private

  def update_client_points
    points = (amount / 10).floor
    client.increment!(:total_spent, amount)
    client.increment!(:total_points, points)
  end
end
