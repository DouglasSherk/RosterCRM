class Interaction < ActiveRecord::Base
  belongs_to :customer

  enum mode: [:discovery, :communication, :meeting, :cancelation, :close, :termination]
end
