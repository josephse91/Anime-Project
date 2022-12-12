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
    peers: {names[1] => "2022-12-11", names[3] => "2022-12-11"}
})

jarret_review_1 = Review.create({
    user: "Jarret",
    show: "My Hero",
    rating: 76,
    watch_priority: -1
})

jarret_review_2 = Review.create({
    user: "Jarret",
    show: "Attack on Titan",
    rating: 99,
    watch_priority: 1
})

jarret_review_3 = Review.create({
    user: "Jarret",
    show: "Jobless Reincarnation",
    rating: 89,
    watch_priority: 1
})