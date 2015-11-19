class Interaction < ActiveRecord::Base
  belongs_to :customer

  enum mode: [:discovery, :communication, :meeting, :close, :termination]
end
