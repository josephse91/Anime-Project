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

# helper functions

def create_review(user,review_attr)
    review = Review.create({
        user: user.username,
        show: review_attr[:show],
        rating: review_attr[:rating],
        overall_review: review_attr[:overall_review],
        watch_priority: review_attr[:watch_priority]
    })

    rooms = user.rooms.map do |room,enter_date|
        current_room = Room.find_by(room_name: room)

        if current_room.shows[review_attr[:show]]
            current_room.shows[review_attr[:show]] += 1
        else
            current_room.shows[review_attr[:show]] = 1
        end
        current_room.save
        current_room
    end

    review
end

def add_user_to_room(user,room)
    reviews = Review.where(user: user.username)
    reviews.each do |review|
        if room.shows[review.show] 
            room.shows[review.show] += 1
        else
            room.shows[review.show] = 1
        end
    end

    room.users[user.username] = TIME_INPUT
    user.rooms[room.room_name] = TIME_INPUT
    room.save
    user.save
end

def set_children(parent,child)
    # current_parent.children.unshift([child.id,NOW.to_fs(:db)])
    parent ? parent.children.unshift(child) : nil
    parent ? parent.save : nil

    current_parent = parent
    current_child = child

    # lineage = {}
    # lineage[current_child.id] = {}

    while current_parent
        already_exists = nil

        current_parent.children.each_with_index do |ex_child,idx|
            if ex_child["id"] == current_child.id
                already_exists = idx
            end
        end

        if already_exists
            current_parent.children[already_exists] = current_child
        else
            current_parent.children.unshift(current_child)
        end

        current_parent.save
        # lineage[current_parent.id] = current_parent.children
        current_child = current_parent
        current_parent = ForumComment.find_by(id: current_child.parent)
    end

    child
end

def create_forum_comment(attributes)
    parent = attributes[:parent] ? ForumComment.find_by(id: attributes[:parent]) : nil
    level = parent ? parent.level + 1 : 1
    attributes[:level] = level

    comment = ForumComment.create(attributes)
    comment.save
    comment.top_comment = parent ? parent.id : comment.id
    comment.save
    set_children(parent, comment)
    comment
end

# Seeded information

num_of_users = 5;
num_of_reviews = 5
watch_priorities = [-1,0,1]

names = Array.new(num_of_users).map do |name|
    Faker::Name.unique.name
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

10.times {
    id_num = rand(1..5)

    ReviewComment.create({
        comment:Faker::Marketing.buzzwords,
        review_id: id_num,
        user_id: names.sample,
        parent: id_num,
        comment_type: "comment"
    })
}

toggle_num = 1
review_comments = ReviewComment.all.shuffle()
review_comments.each do |comment|
    if toggle_num == 1
        ReviewComment.create({
            comment:Faker::Marketing.buzzwords,
            review_id: comment.parent,
            user_id: names.sample,
            parent: comment.id,
            comment_type: "reply",
            top_comment: comment.id
        })
    end
    toggle_num = toggle_num == 1 ? 0 : 1
end

password_digest = BCrypt::Password.create("password")

jarret = User.create({
    username: "Jarret",
    password_digest: password_digest,
    genre_preference: "Shounin",
    go_to_motto: "Somebody gotta go",
    peers: {names[1] => "2022-12-11", 
        names[3] => "2022-12-11",
    }
})

jarret.reset_session_token!

aldane = User.create({
    username: "Aldane",
    password_digest: password_digest,
    genre_preference: "Shounin",
    go_to_motto: "You can take away my body, but you can't take away my pride",
    peers: {names[1] => "2022-12-12", 
        names[2] => "2022-12-12",
        names[4] => "2022-12-12",
        jarret.username => TIME_INPUT
    }
})

aldane.reset_session_token!

jarret.peers[aldane.username] = TIME_INPUT
jarret.save

jarret_review_1 = {
    show: "My Hero",
    rating: 76,
    overall_review: "This is trash",
    watch_priority: -1
}

jarret_review_1 = create_review(jarret,jarret_review_1)

jarret_review_2 = {
    show: "Attack on Titan",
    rating: 99,
    overall_review: "God Tier Level",
    watch_priority: 1
}

jarret_review_2 = create_review(jarret,jarret_review_2)

jarret_review_3 = {
    show: "Jobless Reincarnation",
    rating: 89,
    overall_review: "You have to watch this",
    watch_priority: 1
}

jarret_review_3 = create_review(jarret,jarret_review_3)

aldane_comment_1 = ReviewComment.create({
    comment:"You're hatin', you gotta give things a chance",
    review_id: jarret_review_1.id,
    user_id: aldane.username,
    parent: jarret_review_1.id,
    comment_type: "comment"
})

aldane_comment_1.top_comment = aldane_comment_1.id
aldane_comment_1.save

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
    parent: aldane_comment_1.id,
    comment_type: "reply",
    top_comment: aldane_comment_1.id
})

aldane_review_1 = {
    show: "Bleach",
    rating: 90,
    overall_review: "This is top 2 and its NOT 2!",
    watch_priority: 1
}

aldane_review_1 = create_review(aldane,aldane_review_1)

jarret_comment_1 = ReviewComment.create({
    comment:"Bleach really moving crazy now! You right!",
    review_id: aldane_review_1.id,
    user_id: jarret.username,
    parent: aldane_review_1.id,
    comment_type: "comment"
})

jarret_comment_1.top_comment = jarret_comment_1.id
jarret_comment_1.save

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
aldane_comment_2.save

serge = User.create({
    username: "Serge",
    password_digest: password_digest,
    genre_preference: "Isekai",
    go_to_motto: "Those who break the rules are scum, those who abandon their friends are worse than scum!",
    peers: {names[0] => "2022-12-11", 
        jarret.username => TIME_INPUT,
        aldane.username => TIME_INPUT
    }
})

serge.reset_session_token!

jarret.peers[serge.username] = TIME_INPUT
aldane.peers[serge.username] = TIME_INPUT
jarret.save
aldane.save

david = User.create({
    username: "David",
    password_digest: password_digest,
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

add_user_to_room(serge,planet_vegeta)

planet_vegeta.admin["group_admin"] = true
planet_vegeta.admin["admin_users"][serge.username] = TIME_INPUT
add_user_to_room(jarret,planet_vegeta)
add_user_to_room(aldane,planet_vegeta)


room_name_2 = ""
room_name_2 += Faker::JapaneseMedia::DragonBall.race + " "
room_name_2 += Faker::JapaneseMedia::Naruto.demon

room2 = Room.new({
    room_name: room_name_2,
    users: {username_0.username => TIME_INPUT}
})

room2.admin["admin_users"][username_0.username] = TIME_INPUT
room2.save

add_user_to_room(username_0,room2)

forum_1 = Forum.create({
    topic: "Goku is a bad Father",
    creator: serge.username,
    content: "Between voluntarily dying more than once, letting his enemies live and thrive and simply putting his kid in danger, Goku is as bad a father as it gets. There are good moments like their training in the hyperbolic time chamber but that gets nullified because he threw cell a sensu bean. Goku was an acting threat to Gohan's life at times.",
    anime: "Dragon Ball Z",
    room_id: planet_vegeta.room_name,
    votes: {"up"=>1, "down"=>1}
})

forum_2 = Forum.create({
    topic: "What are the best quotes in Anime",
    creator: jarret.username,
    content: "'I am the bone of my sword, Unknown to death not known to life, Unlimited Blade Works' One of my favorite quotes and anime scenes ever, it gave me chills.",
    room_id: planet_vegeta.room_name
})

forum_3 = Forum.create({
    topic: "Name a notable anime you watched when you were young that still slaps",
    creator: aldane.username,
    content: "The first or second anime i ever saw (as a kid in the late 90s). The main protagonist Kenshin is a special character that has incredible maturity in comparison to other Main characters (it helps that he is 30+ when the show starts). His maturity and approach is evident and you never really get frustrated with him. he is always cool calm and collected. The soundtrack is incredible and for the time the sword animation/fight sequences are great.",
    room_id: planet_vegeta.room_name
})

comment_attr_1 = {
    forum_id: forum_3.id,
    comment_owner: jarret.username,
    comment: "Yu Yu Hakusho transcends time. There isn't a better anime that can test to styles of time",
    parent: nil
}
forum_comment_1 = create_forum_comment(comment_attr_1)

comment_attr_2 = {
    forum_id: forum_3.id,
    comment_owner: aldane.username,
    comment: "You're a Yu Yu lover. I can't say that it transcends time. If you love Yu Yu Hakusho, just say that.",
    parent: forum_comment_1.id
}
forum_comment_2 = create_forum_comment(comment_attr_2)

comment_attr_3 = {
    forum_id: forum_3.id,
    comment_owner: serge.username,
    comment: "If we're honest, Naruto is the best anime of all time at transitioning from childhood to adulthood",
    parent: nil
}
forum_comment_3 = create_forum_comment(comment_attr_3)

comment_attr_4 = {
    forum_id: forum_3.id,
    comment_owner: aldane.username,
    comment: "Now that is a take that makes more sense. Naruto really has lessons that carry. And Naruto is goated",
    parent: forum_comment_3.id
}
forum_comment_4 = create_forum_comment(comment_attr_4)

comment_attr_5 = {
    forum_id: forum_3.id,
    comment_owner: jarret.username,
    comment: "You need to put respect on Yu Yu Hakusho's name",
    parent: forum_comment_2.id
}
forum_comment_5 = create_forum_comment(comment_attr_5)

comment_attr_6 = {
    forum_id: forum_3.id,
    comment_owner: jarret.username,
    comment: "Naruto is a safe answer",
    parent: forum_comment_3.id
}
forum_comment_6 = create_forum_comment(comment_attr_6)

comment_attr_7 = {
    forum_id: forum_3.id,
    comment_owner: jarret.username,
    comment: "lol I should've known you were going to put Yu Yu",
    parent: forum_comment_1.id
}
forum_comment_7 = create_forum_comment(comment_attr_7)

aldane_review_2 = {
    show: "Attack on Titan",
    rating: 99,
    overall_review: "This is beyond the greatest ever",
    watch_priority: 1
}
aldane_review_2 = create_review(aldane,aldane_review_2)

serge_review_1 = {
    show: "Naruto",
    rating: 90,
    overall_review: "Naruto is the gold standard of Shounin anime. Shippuden is still stronger but this is the gold standard",
    watch_priority: 1,
    likes: 3
}
serge_review_1 = create_review(serge,serge_review_1)

david_review_1 = {
    show: "Jujutsu Kaisen",
    rating: 92,
    overall_review: "The animation is ridiculous. The action is out of this world",
    watch_priority: 1
}
david_review_1 = create_review(david,david_review_1)

jarret_review_4 = {
    show: "Tokyo Revengers",
    rating: 86,
    overall_review: "This anime does what it needs to do very well. The characters really put their lives on the line",
    watch_priority: 1
}
jarret_review_4 = create_review(jarret,jarret_review_4)

serge_review_2 = {
    show: "Tokyo Revengers",
    rating: 78,
    overall_review: "This show is solid but there are just a few things I can't get past. The time travel portion of the show is just so convenient that I find it lazy. I also can't get past the fact that these characters are in middle school. The character defining moments are great though",
    watch_priority: 0
}
serge_review_2 = create_review(serge,serge_review_2)

david_review_2 = {
    show: "Naruto",
    rating: 91,
    overall_review: "I can see why this show is the OG. It doesn't do much wrong",
    watch_priority: 1
}
david_review_2 = create_review(david,david_review_2)

jamal = User.create({
    username: "Jamal",
    password_digest: password_digest,
    genre_preference: "Seinen",
    go_to_motto: "Go Go Gadget Hands",
    peers: {aldane.username => TIME_INPUT}
})

aldane.peers[jamal.username] = TIME_INPUT
aldane.save

jamal_review_1 = {
    show: "Hellsing",
    rating: 88,
    overall_review: "I'm really feeling it.",
    watch_priority: 1
}
jamal_review_1 = create_review(jamal,jamal_review_1)

jamal_review_2 = {
    show: "Tokyo Ghoul",
    rating: 72,
    overall_review: "This was really rushed and didn't capture the manga.",
    watch_priority: 1
}
jamal_review_1 = create_review(jamal,jamal_review_2)

aviel = User.create({
    username: "Aviel",
    password_digest: password_digest,
    genre_preference: "Ecchi",
    go_to_motto: "Japanese is easy as 1-2-3",
    peers: {serge.username => TIME_INPUT}
})

serge.peers[aviel.username] = TIME_INPUT
serge.save

aviel_review_1 = {
    show: "Prison School",
    rating: 70,
    overall_review: "This was mid.",
    watch_priority: -1
}
aviel_review_1 = create_review(aviel,aviel_review_1)

aviel_review_2 = {
    show: "Jobless Reincarnation",
    rating: 81,
    overall_review: "This is cool. I like Rudeus",
    watch_priority: -1
}
aviel_review_1 = create_review(aviel,aviel_review_2)

allia = User.create({
    username: "Allia",
    password_digest: password_digest,
    genre_preference: "Shojo",
    go_to_motto: "Japanese Romance is the way to go",
    peers: {aldane.username => TIME_INPUT}
})

aldane.peers[allia.username] = TIME_INPUT
aldane.save

allia_review_1 = {
    show: "Ouran High School Host Club",
    rating: 88,
    overall_review: "This was really sweet. I see why it is so popular",
    watch_priority: -1
}
allia_review_1 = create_review(allia,allia_review_1)

allia_review_2 = {
    show: "Sailor Moon",
    rating: 96,
    overall_review: "I haven't enjoyed an anime more",
    watch_priority: -1
}
allia_review_2 = create_review(allia,allia_review_2)

jarret_aldane_rec = Recommendation.create({
    user_id: aldane.username,
    show: "Jobless Reincarnation",
    referral_id: jarret.username,
    accepted: 1
})

jarret_aldane_rec = Recommendation.create({
    user_id: aldane.username,
    show: "Assassination Classroom",
    referral_id: serge.username,
    accepted: -1
})

jarret_aldane_rec = Recommendation.create({
    user_id: aldane.username,
    show: "Golden Boy",
    referral_id: serge.username
})


serge_jamal_rec = Recommendation.create({
    user_id: jamal.username,
    show: "Naruto",
    referral_id: serge.username
})

jamal_jarret_rec = Recommendation.create({
    user_id: jarret.username,
    show: "Hellsing",
    referral_id: jamal.username
})

serge_aviel_rec = Recommendation.create({
    user_id: aviel.username,
    show: "Naruto",
    referral_id: serge.username
})

aviel_serge_rec = Recommendation.create({
    user_id: serge.username,
    show: "Kaguya Sama",
    referral_id: aviel.username
})

aviel_allia_rec = Recommendation.create({
    user_id: allia.username,
    show: "Prison School",
    referral_id: aviel.username
})

serge_later_1 = WatchLater.create({
    user_id: serge.username,
    show: "Bleach"
})

serge_later_1 = WatchLater.create({
    user_id: serge.username,
    show: "Made in Abyss"
})
