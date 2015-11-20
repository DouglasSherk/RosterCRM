class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable,
  #       :omniauthable, :omniauth_providers => [:google_oauth2]

  devise :database_authenticatable, :rememberable, :omniauthable, :omniauth_providers => [:google_oauth2]

  validates :email, presence: true, uniqueness: true

  has_many :customers, dependent: :destroy
  has_many :interactions, through: :customers

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.find_by(email: data.email)
    user = User.new if user.nil?
    user.email = data.email
    user.provider = access_token.provider
    user.uid = access_token.uid
    user.token = access_token.credentials.token
    user.refresh_token = access_token.credentials.refresh_token
    user.save
    user
  end
end
