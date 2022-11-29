class User < ApplicationRecord
    validates :username, presence: true, uniqueness: true, length: {minimum: 5, too_short: "The desire username must be at least 5 characters"}
    # validates :password, allow_nil: true
    validates :password_digest, presence: true

    attr_reader :password

    has_many :reviews
    has_many :review_comments, :through => :reviews

end
