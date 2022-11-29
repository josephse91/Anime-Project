class ReviewComment < ApplicationRecord
    validates :comment, presence: true

    belongs_to :reviews
    belongs_to :users, :through => :reviews
end
