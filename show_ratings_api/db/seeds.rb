# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Jarret                     | My Hero                     |     76
#  Jarret                     | Attack on Titan             |     99
#  Jarret                     | Jobless Reincarnation       |     89
#  Aldane                     | Bleach                      |     90
#  Aldane                     | Attack on Titan             |     99
#  Serge                      | Naruto                      |     90
#  David                      | Jujutsu Kaisen              |     92
#  Jarret                     | Tokyo Revengers             |     86
#  Serge                      | Tokyo Revengers             |     78
#  David                      | Bleach                      |     80

reviews = [
    {
        show_title: "My Hero",
        room_id: "Planet Vegeta",
        reviewers: {"Jarret" => 76},
        total_points: 76,
        number_of_reviews: 1
    },
    {
        show_title: "Attack on Titan",
        room_id: "Planet Vegeta",
        reviewers: {"Jarret" => 99, "Aldane" => 99},
        total_points: 198,
        number_of_reviews: 2
    },
    {
        show_title: "Jobless Reincarnation",
        room_id: "Planet Vegeta",
        reviewers: {"Jarret" => 89},
        total_points: 89,
        number_of_reviews: 1
    },
    {
        show_title: "Bleach",
        room_id: "Planet Vegeta",
        reviewers: {"Aldane" => 90, "David" => 80},
        total_points: 170,
        number_of_reviews: 2
    },
    {
        show_title: "Naruto",
        room_id: "Planet Vegeta",
        reviewers: {"Serge" => 90},
        total_points: 90,
        number_of_reviews: 1
    },
    {
        show_title: "Jujutsu Kaisen",
        room_id: "Planet Vegeta",
        reviewers: {"David" => 92},
        total_points: 92,
        number_of_reviews: 1
    },
    {
        show_title: "Tokyo Revengers",
        room_id: "Planet Vegeta",
        reviewers: {"Jarret" => 86, "Serge" => 78},
        total_points: 92,
        number_of_reviews: 2
    }
]

ShowRating.create(reviews)