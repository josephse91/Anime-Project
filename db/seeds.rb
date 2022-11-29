# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


# Testing data
ActiveRecord::Base.connection.reset_pk_sequence!('users')
require 'faker'

num_of_users = 5;
num_of_reviews = Random.new.rand(5..10)

names = Array.new(num_of_users).map do |name|
    Faker::Name.unique.name
end

passwords = Array.new(num_of_users).map do |password|
    Faker::Alphanumeric.alpha(number: 10)
end

(0...num_of_users).each do |idx|
    User.create(username: names[idx],password_digest: passwords[idx])
end


(0...num_of_reviews).each do |idx|
    Review.create(user:names.sample,show:Faker::DcComics.title,rating:Random.new.rand(60..100))
end

