class Room < ApplicationRecord
    validates :room_name, uniqueness: true, length: {in: 4..30}, format: { with: /[A-Za-z0-9#$!@%^&* ]+/}
    
end
