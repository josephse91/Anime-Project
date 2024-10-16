class Forum < ApplicationRecord
    validates :topic, presence: true, length: {minimum: 3}
    validates :creator, presence: true

    has_one :rooms, :foreign_key => 'room_id'
    has_one :user, :foreign_key => 'creator'
    has_many :forum_comments, dependent: :delete_all
end
