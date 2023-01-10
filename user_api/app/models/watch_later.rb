class WatchLater < ApplicationRecord
    validates :user_id, presence: true, uniqueness: { 
        scope: :show,
        message: "This show is already on the watch later list"
    }

    has_one :users, :foreign_key => 'user_id'
end
