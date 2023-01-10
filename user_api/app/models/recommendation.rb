class Recommendation < ApplicationRecord
    validates :show, presence: true, uniqueness: { 
        scope: :user_id,
        message: "Each user can only be recommended an anime by one person."
    }

    has_one :users, foreign_key: [:user_id, :referral_id]
end
