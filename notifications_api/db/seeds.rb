# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


Notification.create({
    event_action: "Sent a Request",
    target: "User",
    target_id: 6,
    action_user: "Aldane",
    recipient: "Jarret",
    seen: true
})

Notification.create({
    event_action: "Accepted Request",
    target: "User",
    target_id: 6,
    action_user: "Jarret",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Review",
    target_id: 6,
    action_user: "Aldane",
    recipient: "Jarret",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Review Comment",
    target_id: 16,
    action_user: "Jarret",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Review Comment",
    target_id: 16,
    action_user: "Aldane",
    recipient: "Jarret",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Review",
    target_id: 7,
    action_user: "Jarret",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Review Comment",
    target_id: 17,
    action_user: "Aldane",
    recipient: "Jarret",
    seen: true
})

Notification.create({
    event_action: "Accepted Request",
    target: "User",
    target_id: 6,
    action_user: "Serge",
    recipient: "Jarret",
    seen: true
})

Notification.create({
    event_action: "Accepted Request",
    target: "User",
    target_id: 6,
    action_user: "Serge",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Sent a Request",
    target: "User",
    target_id: 6,
    action_user: "Aldane",
    recipient: "Serge",
    seen: true
})

Notification.create({
    event_action: "Sent a Request",
    target: "User",
    target_id: 6,
    action_user: "Jarret",
    recipient: "Serge",
    seen: true
})


Notification.create({
    event_action: "Sent a Request",
    target: "User",
    target_id: 6,
    action_user: "David",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Accepted Request",
    target: "User",
    target_id: 6,
    action_user: "Aldane",
    recipient: "David",
    seen: true
})

Notification.create({
    event_action: "Created a forum post",
    target: "Room",
    target_id: 1,
    action_user: "Serge",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Created a forum post",
    target: "Room",
    target_id: 1,
    action_user: "Serge",
    recipient: "Jarret",
    seen: true
})

Notification.create({
    event_action: "Created a forum post",
    target: "Room",
    target_id: 2,
    action_user: "Jarret",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Created a forum post",
    target: "Room",
    target_id: 2,
    action_user: "Jarret",
    recipient: "Serge",
    seen: true
})

Notification.create({
    event_action: "Created a forum post",
    target: "Room",
    target_id: 3,
    action_user: "Aldane",
    recipient: "Serge",
    seen: true
})

Notification.create({
    event_action: "Created a forum post",
    target: "Room",
    target_id: 3,
    action_user: "Aldane",
    recipient: "Jarret",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Forum",
    target_id: 3,
    action_user: "Jarret",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Forum Comment",
    target_id: 1,
    action_user: "Aldane",
    recipient: "Jarret"
})

Notification.create({
    event_action: "Comment",
    target: "Forum",
    target_id: 3,
    action_user: "Serge",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Forum Comment",
    target_id: 3,
    action_user: "Aldane",
    recipient: "Serge",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Forum Comment",
    target_id: 2,
    action_user: "Jarret",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Forum Comment",
    target_id: 3,
    action_user: "Jarret",
    recipient: "Serge",
    seen: true
})

Notification.create({
    event_action: "Comment",
    target: "Forum Comment",
    target_id: 1,
    action_user: "Serge",
    recipient: "Jarret"
})

Notification.create({
    event_action: "Sent a Request",
    target: "User",
    target_id: 1,
    action_user: "Jamal",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Accepted Request",
    target: "User",
    target_id: 1,
    action_user: "Aldane",
    recipient: "Jamal"
})

Notification.create({
    event_action: "Sent a Request",
    target: "User",
    target_id: 1,
    action_user: "Aviel",
    recipient: "Serge",
    seen: true
})

Notification.create({
    event_action: "Accepted Request",
    target: "User",
    target_id: 1,
    action_user: "Serge",
    recipient: "Aviel",
    seen: true
})

Notification.create({
    event_action: "Sent a Request",
    target: "User",
    target_id: 1,
    action_user: "Allia",
    recipient: "Aldane",
    seen: true
})

Notification.create({
    event_action: "Accepted Request",
    target: "User",
    target_id: 1,
    action_user: "Aldane",
    recipient: "Allia"
})