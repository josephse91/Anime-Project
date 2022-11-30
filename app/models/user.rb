require 'bcrypt'

class User < ApplicationRecord
    validates :username, presence: true, uniqueness: true, length: {minimum: 5, too_short: "The desire username must be at least 5 characters"}
    # validates :password, allow_nil: true
    validates :password_digest, presence: true

    attr_reader :password

    has_many :reviews
    has_many :review_comments, :through => :reviews

    def self.find_by_credentials(username,password)
        user = User.find_by(username)

        user && user.isPassword?(password)
    end

    def password(new_password)
        @password = new_password
        self.password_digest = BCrypt::Password.create(new_password)
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

end
