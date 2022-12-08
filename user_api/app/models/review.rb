class Review < ApplicationRecord
    validates :user, presence: true
    validates :show, presence: true
    validates :rating, presence: true, comparison: {greater_than: 0, less_than: 100}

    has_one :users, :foreign_key => 'user'
    has_many :review_comments
end
