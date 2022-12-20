class Forum < ApplicationRecord
    validates :topic, presence: true, length: {minimum: 3}
    validates :creator, presence: true

    has_one :rooms, :foreign_key => 'room'
    # has_many :forum_comments, dependent: :destroy
end
