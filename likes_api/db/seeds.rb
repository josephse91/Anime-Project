# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

naruto_like_jamal = Like.create({
    user: "Jamal",
    item_type: "Review",
    item_id: 12,
    upvote: true
})

naruto_like_jarret = Like.create({
    user: "Jarret",
    item_type: "Review",
    item_id: 12,
    upvote: true
})

naruto_like_david = Like.create({
    user: "David",
    item_type: "Review",
    item_id: 12,
    upvote: true
})

form_1_like_aldane = Like.create({
    user: "Aldane",
    item_type: "Forum",
    item_id: 1,
    upvote: true
})

form_1_dislike_aviel = Like.create({
    user: "Aviel",
    item_type: "Forum",
    item_id: 1,
    downvote: true
})