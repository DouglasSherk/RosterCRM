class Customer < ActiveRecord::Base
  belongs_to :user
  has_many :interactions, dependent: :destroy

  validates :name, presence: true, uniqueness: {scope: :user}

  def self.active(customers, city_country)
    customers.find_all { |customer| customer.active?(city_country) }
  end

  def self.inactive(customers, city_country)
    customers.find_all { |customer| !customer.active?(city_country) }
  end

  def active?(user_city_country)
    different_city = !user_city_country.nil? && !user_city_country.empty? &&
                     !city_country.nil? && !city_country.empty? &&
                     user_city_country == city_country
    status != :termination && !different_city
  end

  def status
    status = Interaction.where(customer: self).order('mode DESC').limit(1).first
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
