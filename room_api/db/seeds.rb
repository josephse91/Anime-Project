# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

test_rooms = Random.new.rand(5..10)
test_users = test_rooms * 3

room_names = []
users = []

test_rooms.times do |idx|
    room_names.push(Faker::Books::CultureSeries.book)
end

room_names.each {|room| Room.create(room_name: room)}





