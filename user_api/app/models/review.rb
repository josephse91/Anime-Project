class Review < ApplicationRecord
    validates :user, presence: true
    validates :show, presence: true
    validates :rating, presence: true, comparison: {greater_than: 0, less_than: 100}

    belongs_to :users
    has_many :review_comments
end
