class ReviewComment < ApplicationRecord
    validates :comment, presence: true

    has_one :reviews
    has_many :users, through: :reviews
end
