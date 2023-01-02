class Review < ApplicationRecord
    validates :user, presence: true
    validates :show, presence: true, uniqueness: { 
        scope: :user,
        message: "Each user can only create one review per show."
    }
    validates :rating, presence: true, comparison: {greater_than: 0, less_than: 100}
    validates :watch_priority, comparison: {greater_than: -2, less_than: 2}

    has_one :users, :foreign_key => 'user'
    has_many :review_comments, dependent: :destroy
end
