class ShowRating < ApplicationRecord
    validates :show_title, uniqueness: {
        scope: :room_id,
        message: "Each room can only have one group rating per show"
    }
end
