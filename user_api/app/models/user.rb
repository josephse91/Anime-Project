require 'bcrypt'

class User < ApplicationRecord
    attr_reader :password
    
    validates :username, presence: true, uniqueness: true, length: {minimum: 5, too_short: "The desire username must be at least 5 characters"}
    # validates :password, allow_nil: true
    validates :password_digest, presence: true

    has_many :recommendations, dependent: :destroy
    has_many :watch_laters, dependent: :destroy
    has_many :reviews
    has_many :review_comments, :through => :reviews

    def self.find_by_credentials(username,password)
        user = User.find_by(username: username)

        user && user.is_password?(password) ? user : nil
    end

    def password(new_password)
        @password = new_password
        self.password_digest = BCrypt::Password.create(new_password)
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

    def reset_session_token!
        self.session_token = generate_unique_session_token
        self.save!
    
        self.session_token
    end

    def generate_unique_session_token
        token = SecureRandom.urlsafe_base64(16)
    
        # Just in case there is a session_token conflict, make sure
        # not to throw a validation error at the user!

        while self.class.exists?(session_token: token)
          token = SecureRandom.urlsafe_base64(16)
        end
    
        token
      end

end
