# User-Api-Documentation

This document details the information available for the users of the Anime Dojo application as well as the parameter requirements

## API Reference

This API will be used to manage any actions done by the user. The tables that will be included are a User table, Reviews table a reviews comment table.

[**Users**](#User-Table)

Will provide details of the user and maintain the inputs specific to the user such as the rooms that they are in, their peers, credentials and any other inputs that the user has personal to themselves

[index](#create-a-user-create) / 
[user_room_index](#retreive-all-user-rooms-user-room-index) / 
[user_review_index](#retreive-all-reviews-the-user-user-Review-Index) / 
[create](#create-a-user-create) / 
[show](#get-specific-user-show) / 
[update](#edit-specific-user-update) / 
[delete](#delete-user-destroy) 

[**Reviews**](#Review-Table)

Within the review table, contains actions that will manage occurances with reviews. Reviews impact a number of other tables such as review comments, rooms, recommendations, watch laters.

Additionally, there will be follow up API actions such as the likes and shows API

[index](#retreive-all-reviews-index) / 
[user index](#retreive-all-reviews-of-user-user_index) / 
[create](#create-a-review-create) / 
[Reviews to Rooms](#add-review-of-user-to-all-rooms-reviews_to_rooms) / 
[show](#retrieve-the-review-user-show) / 
[update](#edit-review-of-a-user-update) / 
[delete](#delete-review-of-a-user-destroy) 

[**Review Comments**](#Review-Comments-Table)

This will have a two level commenting capability. The first level will be the comments, the second level will be the reply to their respective comments.  

[index](#retreive-all-comments-of-a-review-index) / 
[create](#create-a-review-comment-create) / 
[update](#edit-review-comment-of-a-user-update) / 
[delete](#delete-review-comments-user-destroy) 

[**Rooms**](#Rooms-Table) 

Rooms will be where groups of users can assemble to look at the consensus for the congregation of shows that all users have watched.
The rooms controllers have the capabilities to add or remove users. 

This will also interact with a number of the tables (user,review,forum,forum comments) and other API. (notifications)

[index](#retreive-all-rooms-index) / 
[create](#create-a-room-create) / 
[Add user reviews to room](#add-users-reviews-room-add_user_reviews_to_room) / 
[show](#get-a-room-show) / 
[update](#edit-room-update) / 
[delete](#delete-room-destroy) 

[**Forums**](#Forum-Table)

Similar to Reddit, each room will have its own list of topic threads that will allow the users within the room to create and comment on these threads.

Each forum has the ability to be liked or disliked

[index](#retreive-all-forums-index) / 
[Room Forum Index](#retreive-all-forums-in-room-room_forum_index) / 
[create](#create-a-forum-create) / 
[show](#retrieve-the-forum-of-user-show) / 
[update](#edit-forum-of-a-room-update) / 
[delete](#delete-forum-of-user-destroy)

[**Forum Comments**](#Forum-Comments-Table)

Again, similar to reddit, these forum posts have an infitite comment nesting capabilities. Each comment has the ability to be liked or disliked

[index](#retreive-all-the-TOP-forum-comments-of-a-forum-index) / 
[create](#create-a-forum-comment-create) / 
[update](#edit-forum-comment-update) / 
[delete](#delete-forum-comment-of-user-destroy)

[**Recommendations**](#recommendations-table)

Each user has the ability to recommend shows to other users. There are a maximum of 3 live recommendations that a user can suggest to another user at any given time

[index](#retreive-all-recommendations-index) / 
[create](#create-a-recommendation-create) / 
[show](#show-the-recommendations-of-a-user-show) / 
[destroy](#delete-recommendation-of-user-destroy)

[**Watch Later**](#watch-later-table)

There may be shows that a user can't get to until later. This allows user to save any shows of interest for later

[index](#retreive-all-watch-laters-index) / 
[create](#create-a-watch-later-create) / 
[show](#show-the-watch-laters-of-a-user-show) / 
[destroy](#delete-watch-later-of-user-destroy)

[**Go to Appendix**](#Appendix)

---
#### **User Table**

Will provide details of the user and maintain the inputs specific to the user such as the rooms that they are in, their peers, credentials and any other inputs that the user has personal to themselves

[index](#create-a-user-create) / 
[user_room_index](#retreive-all-user-rooms-user-room-index) / 
[user_review_index](#retreive-all-reviews-the-user-user-Review-Index) / 
[create](#create-a-user-create) / 
[show](#get-specific-user-show) / 
[update](#edit-specific-user-update) / 
[delete](#delete-user-destroy) 

[Back to API Reference](#API-Reference)

---
#### Retreive all users: index

```http
  GET /api/users/
```

*Filter select users*

```http
  GET /api/users?search=${username}
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `search` | `string` | Username placed w/out brackets |

[Back to API Reference](#API-Reference) / 
[Top of the User Table](#user-table)

#### Retreive all user rooms: user room index

```http
  GET /api/users/:user_id/rooms
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user_id` | `string` | Username of user |

[Back to API Reference](#API-Reference) / 
[Top of the User Table](#user-table)

#### Retreive all reviews the User: User Review Index

```http
  GET /api/users/:user_id/reviews
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user_id` | `string` | Username of user |

[Back to API Reference](#API-Reference) / 
[Top of the User Table](#user-table)

#### Create a user: create

```http
  POST /api/users/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user_id` | `string` | Must be unique                 |
| `password` | `string` | Must be at least 5 characters  |
| *`genre_preference` | `string` |                       |
| *`go_to_motto` | `string` |                            |
| *`user_grade_protocol` | `text` |                      |

[Back to API Reference](#API-Reference) / 
[Top of the User Table](#user-table)

#### Get specific User: show

```http
  GET /api/users/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id`| `string` | Username of User         |

[Back to API Reference](#API-Reference) / 
[Top of the User Table](#user-table)

#### Edit specific User: update

```http
  PATCH /api/users/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Username of User                 |
| `user_id` | `string` | Will function as Current User                 |
| `password` | `string` | Must be at least 5 characters  |
| `genre_preference` | `string` |                       |
| `go_to_motto` | `string` |                            |
| `user_grade_protocol` | `text` |                      |
| *`peers` | `json` | View [JSON format](#User-peer-Parameter-input) in Appendex |
| *`requests` | `json` | View [JSON format](#User-Requests-Parameter-input) in Appendex |
| `new_username` | `string` | Username to replace previous username                |
| `new_password` | `string` | Password to replace previous password                      |

[Back to API Reference](#API-Reference) / 
[Top of the User Table](#user-table)

#### Delete User: destroy

```http
  DELETE /api/users/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `session_token_input`| `string` | User sign in token     |

[Back to API Reference](#API-Reference) / 
[Top of the User Table](#user-table)

---
#### Review Table

Within the review table, contains actions that will manage occurances with reviews. Reviews impact a number of other tables such as review comments, rooms, recommendations, watch laters.

Additionally, there will be follow up API actions such as the likes and shows API

[index](#retreive-all-reviews-index) / 
[user index](#retreive-all-reviews-of-user-user_index) / 
[create](#create-a-review-create) / 
[Reviews to Rooms](#add-review-of-user-to-all-rooms-reviews_to_rooms) / 
[show](#retrieve-the-review-user-show) / 
[update](#edit-review-of-a-user-update) / 
[delete](#delete-review-of-a-user-destroy) 


[Back to API Reference](#API-Reference)

---
#### Retreive all reviews: index

```http
  GET /api/reviews/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user` | `string` | Insert into query param from the frontend component  |

*Filter select users*

```http
  GET /api/reviews?
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user` | `string` | Insert into query param from the frontend component  |
| `in_network` | `string` | input "true" if you're looking for reviews within network |
| `range` | `JSON` |  View [JSON format](#Review-Table-Range-Parameter) in Appendex |

[Back to API Reference](#API-Reference) / 
[Top of the Review Table](#review-table)

#### Retreive all reviews of user: user_index

```http
  GET /api/users/:userid/reviews/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user_id` | `string` | Insert into query param from the frontend component  |
| `current_user` | `string` | Insert into query param from the frontend component  |

[Back to API Reference](#API-Reference) / 
[Top of the Review Table](#review-table)

#### Create a review: create

```http
  POST /api/reviews/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user_id` | `string` | Username of reviewer  |
| `current_user` | `string` | Username of client user  |
| `show` | `string` | Show title  |
| `rating` | `integer` | Number between 0 and 100.  |
| `amount_watched` | `string` |  |
| `highlighed_points` | `text` |  |
| `overall_review` | `text` |  |
| `referral_id` | `string` | This will be the referrer username |
| `watch_priority` | `integer` | Will be -1, 0 or 1. Insert into form Param |

[Back to API Reference](#API-Reference) / 
[Top of the Review Table](#review-table)

#### Add Review of User to all rooms: reviews_to_rooms

```http
  GET /api/reviews/:review_id/rooms
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `review_action` | `string` | Will have either values: ("delete review" or "add review")  |
| `show_object` | `JSON` | Will be a Review object JSON  |

[Back to API Reference](#API-Reference) / 
[Top of the Review Table](#review-table)

#### Retrieve the review user: show

```http
  GET /api/reviews/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id` | `string` | Name of show being reviewed  |
| `review_id` | `string` | Name of show being reviewed  |
| `user_id` | `string` | Username of User  |
| `current_user` | `string` | Username of Current user  |
| `show` | `string` | Name of show being reviewed  |

* Refer to JSON object in Appendix

[Back to API Reference](#API-Reference) / 
[Top of the Review Table](#review-table)

#### Edit Review of a User: update

```http
  PATCH /api/reviews/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Name of show being reviewed  |
| `review_id` | `string` | Name of show being reviewed  |
| `user_id` | `string` | Username of User  |
| `current_user` | `string` | Username of Current user  |
| `show` | `string` | Name of show being reviewed  |
| `rating` | `integer` | Number between 0 and 100. Insert into form Param |
| `amount_watched` | `string` |  |
| `highlighed_points` | `text` |  |
| `overall_review` | `text` |  |
| `referral_id` | `string` | This will be the referrer username. Insert into form Param |
| `watch_priority` | `integer` | Will be -1, 0 or 1. Insert into form Param |
| `likes` | `JSON` | View [JSON format](#votes-and-likes-parameters) in Appendex |

[Back to API Reference](#API-Reference) / 
[Top of the Review Table](#review-table)

#### Delete Review of a User: destroy

```http
  DELETE /api/reviews/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id` | `string` | Name of show being reviewed  |
| `review_id` | `string` | Name of show being reviewed  |
| `user_id` | `string` | Username of User  |
| `current_user` | `string` | Username of Current user  |

[Back to API Reference](#API-Reference) / 
[Top of the Review Table](#review-table)

---
#### Review Comments Table

This will have a two level commenting capability. The first level will be the comments, the second level will be the reply to their respective comments.  

[index](#retreive-all-comments-of-a-review-index) / 
[create](#create-a-review-comment-create) / 
[update](#edit-review-comment-of-a-user-update) / 
[delete](#delete-review-comments-user-destroy) 

[Back to API Reference](#API-Reference)

---
#### Retreive all comments of a Review: index

```http
  GET /api/review_comments/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `review_id` | `integer` | Parameter inserted into query param from the frontend component  |

[Back to API Reference](#API-Reference) / 
[Top of the Review Comment Table](#review-comments-table)

#### Create a Review Comment: create

```http
  POST /api/review_comments/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `review_id` | `integer` | This will be the review ID number  |
| `comment` | `text` |   |
| `user_id` | `string` | Username of the User |
| `comment_type` | `string` | Should be either "comment" or "reply". Comments will be the top comment. Replies are a level beneath the top level |
| `parent` | `integer` | ID of the parent.  |

*Output will be an javascript object that has a status key and review key. The review key will contain the object being created

[Back to API Reference](#API-Reference) / 
[Top of the Review Comment Table](#review-comments-table)

#### Edit Review Comment of a User: update

```http
  PATCH /api/review_comments/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Review comment ID  |
| `review_id` | `integer` | The Primary ID of the review  |
| `comment` | `text` |   |
| `user_id` | `string` | Username of User |
| `comment_type` | `string` | "comment" or "reply"  |
| `parent` | `integer` |  |
| `likes` | `JSON` | View [JSON format](#votes-and-likes-parameters) in Appendex |

[Back to API Reference](#API-Reference) / 
[Top of the Review Comment Table](#review-comments-table)

#### Delete Review Comments User: destroy

```http
  DELETE /api/review_comments/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Review comment ID   |
| `user_id` | `string` | Username of the User |

[Back to API Reference](#API-Reference) / 
[Top of the Review Comment Table](#review-comments-table)

---
#### Rooms Table

Rooms will be where groups of users can assemble to look at the consensus for the congregation of shows that all users have watched.
The rooms controllers have the capabilities to add or remove users. 

This will also interact with a number of the tables (user,review,forum,forum comments) and other API. (notifications)

[index](#retreive-all-rooms-index) / 
[create](#create-a-room-create) / 
[Add user reviews to room](#add-users-reviews-room-add_user_reviews_to_room) / 
[show](#get-a-room-show) / 
[update](#edit-room-update) / 
[delete](#delete-room-destroy) 

[Back to API Reference](#API-Reference)

---
#### Retreive all rooms: index

```http
  GET /api/rooms/
```

*Filter rooms based upon room name*

```http
  GET /api/rooms?search=${room name}
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `search` | `string` | Any consecutive string within Room_name |

[Back to API Reference](#API-Reference) / 
[Top of the Rooms Table](#rooms-table)

#### Create a Room: create

```http
  POST /api/rooms/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `room_id` | `string` | Name of Room  |
| `private_room` | `boolean` | Form data |

[Back to API Reference](#API-Reference) / 
[Top of the Rooms Table](#rooms-table)

#### Add user's reviews room: add_user_reviews_to_room

```http
  PATCH /api/rooms/:room_id/add_user_reviews/:user_id
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user_id` | `string` | The username interacting with the client  |
| `room_id` | `string` | The show NAME of a review  |
| `room_action` | `string` | Values: ("member added" or "member removed") taken from previous API call  |

[Back to API Reference](#API-Reference) / 
[Top of the Rooms Table](#rooms-table)

#### Get a Room: show

```http
  POST /api/rooms/:id
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Name of the room  |

[Back to API Reference](#API-Reference) / 
[Top of the Rooms Table](#rooms-table)

#### Edit Room: update

```http
  PATCH /api/rooms/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Name of the room  |
| `current_user` | `string` | The username interacting with the client  |
| `user_id` | `string` | Username of the Current User  |
| `request` | `string` | Username looking to access room |
| `submitted_key` | `string` | Key submitted by User looking to enter room|
| `user_remove` | `string` | Username to delete by admin |
| `room_id` | `string` | Name of Room |
| `make_entry_key` | `boolean` | Allowed keys generated for access into room |
| `private_room` | `boolean` | Form data |

[Back to API Reference](#API-Reference) / 
[Top of the Rooms Table](#rooms-table)

#### Delete Room: destroy

```http
  DELETE /api/rooms/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Room name  |
| `current_user` | `string` | Username of the client user  |

[Back to API Reference](#API-Reference) / 
[Top of the Rooms Table](#rooms-table)

---
#### Forum Table

Similar to Reddit, each room will have its own list of topic threads that will allow the users within the room to create and comment on these threads.

Each forum has the ability to be liked or disliked

[index](#retreive-all-forums-index) / 
[Room Forum Index](#retreive-all-forums-in-room-room_forum_index) / 
[create](#create-a-forum-create) / 
[show](#retrieve-the-forum-of-user-show) / 
[update](#edit-forum-of-a-room-update) / 
[delete](#delete-forum-of-user-destroy)

[Back to API Reference](#API-Reference)

---
#### Retreive all forums: index

```http
  GET /api/forums/
```
[Back to API Reference](#API-Reference) / 
[Top of the Forum Table](#forum-table)

#### Retreive all forums in room: room_forum_index

```http
  GET /api/rooms/:room_id/forums/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `room_id` | `string` | This will be the room_name of the room  |
| `forum_search` | `string` |  |
| `anime_search` | `string` |   |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Table](#forum-table)

#### Create a forum: create

```http
  POST /api/forums/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `room_id` | `string` | Room_name of Room  |
| `current_user` | `string` | Username of current user  |
| `topic` | `string` | Forum Subject Title |
| `creator` | `string` | User that creates or edits forum post |
| `content` | `text` | Content in regards to the topic |
| `anime` | `string` | Anime pertaining to subject (Optional) |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Table](#forum-table)

#### Retrieve the Forum of user: show

```http
  GET /api/forums/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id` | `integer` | Primary key of Forum object  |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Table](#forum-table)

#### Edit Forum of a Room: update

```http
  PATCH /api/forums/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Primary key of Forum object  |
| `room_id` | `string` | Room_name of Room  |
| `current_user` | `string` | Username of current user  |
| `topic` | `string` | Forum Subject Title |
| `creator` | `string` | User that creates or edits forum post |
| `content` | `text` | Content in regards to the topic |
| `anime` | `string` | Anime pertaining to subject (Optional) |
| `votes` | `JSON` | View [JSON format](#votes-and-likes-parameters) in Appendex |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Table](#forum-table)

#### Delete Forum of User: destroy

```http
  DELETE /api/forums/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id` | `integer` | Primary key of Forum object  |
| `room_id` | `string` | Room_name of Room  |
| `current_user` | `string` | Username of current user  |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Table](#forum-table)

---
#### Forum Comments Table

Again, similar to reddit, these forum posts have an infitite comment nesting capabilities. Each comment has the ability to be liked or disliked

[index](#retreive-all-the-TOP-forum-comments-of-a-forum-index) / 
[create](#create-a-forum-comment-create) / 
[update](#edit-forum-comment-update) / 
[delete](#delete-forum-comment-of-user-destroy)

[Back to API Reference](#API-Reference)

---
#### Retreive all the TOP forum comments of a Forum: index

```http
  GET /api/forum_comments/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `forum_id` | `integer` | Forum Primary ID |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Comments Table](#forum-comments-table)

#### Create a Forum Comment: create

```http
  POST /api/forum_comments/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `comment` | `text` |  |
| `forum_id` | `integer` | Forum Primary ID  |
| `comment_owner` | `string` | Username of commenter |
| `current_user` | `string` | Username of commenter |
| `parent` | `integer` | Primary ID of parent comment. NULL if there is no parent |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Comments Table](#forum-comments-table)

#### Edit Forum Comment: update

```http
  PATCH /api/forum_comments/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Primary ID of existing Forum comment  |
| `comment` | `text` |  |
| `forum_id` | `integer` | Forum Primary ID  |
| `comment_owner` | `string` | Username of commenter |
| `current_user` | `string` | Username of commenter |
| `parent` | `integer` | Primary ID of parent comment. NULL if there is no parent |
| `top_comment` | `integer` |  |
| `votes` | `JSON` | View [JSON format](#votes-and-likes-parameters) in Appendex |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Comments Table](#forum-comments-table)

#### Delete Forum Comment of User: destroy

```http
  DELETE /api/forum_comments/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Primary ID of existing Forum comment  |
| `forum_id` | `integer` | Forum Primary ID  |
| `comment_owner` | `string` | Username of commenter |
| `current_user` | `string` | Username of commenter |

[Back to API Reference](#API-Reference) / 
[Top of the Forum Comments Table](#forum-comments-table)

---
#### Recommendations Table

Each user has the ability to recommend shows to other users. There are a maximum of 3 live recommendations that a user can suggest to another user at any given time

[index](#retreive-all-recommendations-index) / 
[create](#create-a-recommendation-create) / 
[show](#show-the-recommendations-of-a-user-show) / 
[destroy](#delete-recommendation-of-user-destroy)

[Back to API Reference](#API-Reference)

---
#### Retreive all Recommendations: index

```http
  GET /api/recommendations/
```

[Back to API Reference](#API-Reference) / 
[Top of the Recommendations Table](#recommendations-table)

#### Create a Recommendation: create

```http
  POST /api/recommendations/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user_id` | `string` | User receiving recommendation |
| `show` | `string` |   |
| `referral_id` | `string` | User making Recommendation |

[Back to API Reference](#API-Reference) / 
[Top of the Recommendations Table](#recommendations-table)

#### Show the recommendations of a user: show

```http
  GET /api/recommendations/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | User receiving recommendations |

[Back to API Reference](#API-Reference) / 
[Top of the Recommendations Table](#recommendations-table)

#### Delete Recommendation of User: destroy

```http
  DELETE /api/recommendations/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user_id` | `string` | User receiving recommendation |
| `show` | `string` |   |

[Back to API Reference](#API-Reference) / 
[Top of the Recommendations Table](#recommendations-table)

---
#### Watch Later Table

There may be shows that a user can't get to until later. This allows user to save any shows of interest for later

[index](#retreive-all-watch-laters-index) / 
[create](#create-a-watch-later-create) / 
[show](#show-the-watch-laters-of-a-user-show) / 
[destroy](#delete-watch-later-of-user-destroy)

[Back to API Reference](#API-Reference)

---
#### Retreive all Watch Laters: index

```http
  GET /api/watch_laters/
```

[Back to API Reference](#API-Reference) / 
[Top of the Watch Later Table](#watch-later-table)

#### Create a Watch Later: create

```http
  POST /api/watch_laters/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user_id` | `string` |  |
| `show` | `string` |   |

[Back to API Reference](#API-Reference) / 
[Top of the Watch Later Table](#watch-later-table)

#### Show the Watch Laters of a user: show

```http
  GET /api/watch_laters/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` |  |

[Back to API Reference](#API-Reference) / 
[Top of the Watch Later Table](#watch-later-table)

#### Delete Watch Later of User: destroy

```http
  DELETE /api/watch_laters/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user_id` | `string` |  |
| `show` | `string` |   |

[Back to API Reference](#API-Reference) / 
[Top of the Watch Later Table](#watch-later-table)

# Appendix

Terms and formats utilized in the API

[Back to API Reference](#API-Reference)

### User peer Parameter input

The format of the parameter required will as follows

```
{ action: "add", peerFocus: "Desired Peer" }

```

* action key: ("add" or "remove")
* peerFocus key: This will be the desired peer that will be added or removed

[Back to Appendix Title](#Appendix)

### User Requests Parameter input

The format of the parameter required will as follows

```
{ action: "add", requestFocus: "Desired Peer" }
```

* Action key: ("add" or "remove")
* requestFocus key: This will be the desired peer that will be added or removed

[Back to Appendix Title](#Appendix)

### Review Table Range Parameter

The format of the parameter required will as follows

```
{ 
    "top": "80", 
    "bottom": "20" 
}
```

* top: the upper boundary of the select review range
* bottom: the lower boundary of the select review range

[Back to Appendix Title](#Appendix)

### Votes and Likes Parameters

The format of the parameter required will as follows

```
{ user: user_object, net: 1, target: 0 }
```

user key: This will be a user user_object

net: This represents the net vote status of the current user.
```
-1: User currently has down vote
 0: User currently has no vote. (Neutral)
 1: User currently has up vote
```

target: Represents the new vote status that the current user is selecting
```
-1: Down vote
 0: No vote. (Neutral)
 1: Up vote
```

NOTE: With likes, the neutral means no like

[Back to Appendix Title](#Appendix)

## Authors

- [Serge-Edouard Joseph](https://josephse91.github.io)
