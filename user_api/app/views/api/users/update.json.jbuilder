json.status "complete"
json.user do |attribute|
    attribute.username @user.username
    attribute.genre_preference @user.genre_preference
    attribute.go_to_motto @user.go_to_motto
    attribute.user_grade_protocol @user.user_grade_protocol
    attribute.rooms @user.rooms
    attribute.peers @user.peers
    attribute.requests @user.requests
end