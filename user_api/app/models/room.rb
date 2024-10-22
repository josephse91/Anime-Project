class Room < ApplicationRecord
    self.primary_key = "room_name"
    
    validates :room_name, 
        uniqueness: { conditions: -> { where(retired: true) } }, 
        length: {in: 4..30}, 
        format: { with: /[A-Za-z0-9#$!@%^&* ]+/}

    has_many :forums
    has_many :forum_comments, through: :forums

    def self.generate_entry_key
        token = SecureRandom.urlsafe_base64(16)
    end

end
