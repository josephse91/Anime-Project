# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


# Testing data
require 'faker'
require 'bcrypt'

NOW = Time.new
TIME_INPUT = "#{NOW.month}-#{NOW.day}-#{NOW.year}"

num_of_users = 5;
num_of_reviews = Random.new.rand(5..10)
watch_priorities = [-1,0,1]

names = Array.new(num_of_users).map do |name|
    Faker::Name.unique.name
end

passwords = Array.new(num_of_users).map do |password|
    Faker::Alphanumeric.alpha(number: 10)
end

(0...num_of_users).each do |idx|
    User.create(username: names[idx],password_digest: BCrypt::Password.create("password"))
end

username_0 = User.find_by(username: names[0])
username_1 = User.find_by(username: names[1])
username_2 = User.find_by(username: names[2])
username_3 = User.find_by(username: names[3])
username_4 = User.find_by(username: names[4])


(0...num_of_reviews).each do |idx|
    Review.create({
        user:names.sample,
        show:Faker::DcComics.title,
        rating:Random.new.rand(60..100),
        watch_priority: watch_priorities.sample
    })
end

reviews = Review.all.shuffle()
reviews.each do |review|
    ReviewComment.create({
        comment:Faker::Marketing.buzzwords,
        review_id: review.id,
        user_id: names.sample,
        parent: review.id,
        comment_type: "comment"
    })
end

review_comments = ReviewComment.all.shuffle().slice(0,num_of_reviews - 2)
review_comments.each do |comment|

    ReviewComment.create({
        comment:Faker::Marketing.buzzwords,
        review_id: comment.parent,
        user_id: names.sample,
        parent: comment.id,
        comment_type: "reply",
        top_comment: comment.id
    })
end



jarret = User.create({
    username: "Jarret",
    password_digest: "password",
    genre_preference: "Shounin",
    go_to_motto: "Somebody gotta go",
    peers: {names[1] => "2022-12-11", 
        names[3] => "2022-12-11",
    }
})

aldane = User.create({
    username: "Aldane",
    password_digest: "password",
    genre_preference: "Shounin",
    go_to_motto: "You can take away my body, but you can't take away my pride",
    peers: {names[1] => "2022-12-12", 
        names[2] => "2022-12-12",
        names[4] => "2022-12-12",
        jarret.username => TIME_INPUT
    }
})

jarret.peers[aldane.username] = TIME_INPUT
jarret.save

jarret_review_1 = Review.create({
    user: "Jarret",
    show: "My Hero",
    rating: 76,
    overall_review: "This is trash",
    watch_priority: -1
})

jarret_review_2 = Review.create({
    user: "Jarret",
    show: "Attack on Titan",
    rating: 99,
    overall_review: "God Tier Level",
    watch_priority: 1
})

jarret_review_3 = Review.create({
    user: jarret.username,
    show: "Jobless Reincarnation",
    rating: 89,
    overall_review: "You have to watch this",
    watch_priority: 1
})

aldane_comment_1 = ReviewComment.create({
    comment:"You're hatin', you gotta give things a chance",
    review_id: jarret_review_1.id,
    user_id: aldane.username,
    parent: jarret_review_1.id,
    comment_type: "comment"
})

aldane_comment_1.top_comment = aldane_comment_1.id

jarret_reply_1 = ReviewComment.create({
    comment:"You have a thick imagination",
    review_id: jarret_review_1.id,
    user_id: jarret.username,
    parent: aldane_comment_1.id,
    comment_type: "reply",
    top_comment: aldane_comment_1.id
})

aldane_reply_1 = ReviewComment.create({
    comment:"Why you want to hate good things so badly?",
    review_id: jarret_review_1.id,
    user_id: aldane.username,
    parent: jarret_review_1.id,
    comment_type: "reply",
    top_comment: aldane_comment_1.id
})

aldane_review_1 = Review.create({
    user: aldane.username,
    show: "Bleach",
    rating: 90,
    overall_review: "This is top 2 and its NOT 2!",
    watch_priority: 1
})

jarret_comment_1 = ReviewComment.create({
    comment:"Bleach really moving crazy now! You right!",
    review_id: aldane_review_1.id,
    user_id: jarret.username,
    parent: aldane_review_1.id,
    comment_type: "comment"
})

jarret_comment_1.top_comment = jarret_comment_1.id

aldane_reply_2 = ReviewComment.create({
    comment:"I put you on! DEAD!!!",
    review_id: aldane_review_1.id,
    user_id: aldane.username,
    parent: jarret_comment_1.id,
    comment_type: "reply",
    top_comment: jarret_comment_1.id
})

aldane_comment_2 = ReviewComment.create({
    comment:"So what you're saying is, its goated",
    review_id: jarret_review_3.id,
    user_id: aldane.username,
    parent: jarret_review_3.id,
    comment_type: "comment",
})

aldane_comment_2.top_comment = aldane_comment_2.id

serge = User.create({
    username: "Serge",
    password_digest: "password",
    genre_preference: "Isekai",
    go_to_motto: "Those who break the rules are scum, those who abandon their friends are worse than scum!",
    peers: {names[0] => "2022-12-11", 
        jarret.username => TIME_INPUT,
        aldane.username => TIME_INPUT
    }
})

jarret.peers[serge.username] = TIME_INPUT
aldane.peers[serge.username] = TIME_INPUT
jarret.save
aldane.save

david = User.create({
    username: "David",
    password_digest: "password",
    genre_preference: "Shounin",
    go_to_motto: "Imma yell in your ear",
    peers: {
        names[0] => "2022-12-11", 
        names[3] => "2022-12-11",
        aldane.username => TIME_INPUT
    }
})

username_0.peers[david.username] = TIME_INPUT
username_3.peers[david.username] = TIME_INPUT
aldane.peers[david.username] = TIME_INPUT
aldane.save
username_0.save
username_3.save

planet_vegeta = Room.new({
    room_name: "Planet Vegeta",
    users: {"Serge": TIME_INPUT}
})

planet_vegeta.admin["group_admin"] = true
planet_vegeta.admin["admin_users"][serge.username] = TIME_INPUT
planet_vegeta.users[jarret.username] = TIME_INPUT
planet_vegeta.users[aldane.username] = TIME_INPUT
planet_vegeta.save

room_name_2 = ""
room_name_2 += Faker::JapaneseMedia::DragonBall.race + " "
room_name_2 += Faker::JapaneseMedia::Naruto.demon

room2 = Room.new({
    room_name: room_name_2,
    users: {username_0.username => TIME_INPUT}
})

room2.admin["admin_users"][username_0.username] = TIME_INPUT
room2.save