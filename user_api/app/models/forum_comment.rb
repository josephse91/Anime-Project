class ForumComment < ApplicationRecord
    validates :comment, presence: true

    has_one :forums, :foreign_key => 'forum_post'
    has_one :rooms, through: :forums
end
