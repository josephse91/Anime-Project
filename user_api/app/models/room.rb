class Room < ApplicationRecord
    validates :room_name, uniqueness: true, length: {in: 4..30}, format: { with: /[A-Za-z0-9#$!@%^&* ]+/}

    has_many :forums, dependent: :destroy

    def self.generate_entry_key
        token = SecureRandom.urlsafe_base64(16)
    end

end
