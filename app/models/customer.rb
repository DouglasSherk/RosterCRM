class Customer < ActiveRecord::Base
  belongs_to :user
  has_many :interactions

  def status
    status = interactions.max_by(&:mode)
    ((status && status.mode) || Interaction.modes.first[0]).to_sym
  end

  def next_contact
    return nil if terminated?
    dbval = read_attribute(:next_contact)
    return dbval if dbval && dbval > DateTime.now

    return nil if !next_interaction.nil?
    last_interaction = interactions.order('time ASC').first
    time = last_interaction && last_interaction.time || DateTime.now.utc
    return time + 5.days if dbval && dbval < time
  end

  def next_interaction
    interaction = interactions.where("time > ?", DateTime.now).order('time ASC').first
    interaction && interaction.time
  end

  private
    def terminated?
      interactions.find { |interaction| interaction.mode.to_sym == :termination }
    end
end
