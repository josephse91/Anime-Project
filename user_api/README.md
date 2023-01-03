# User-Api-Documentation

This document details the information available for the users of the Anime Dojo application as well as the parameter requirements## Table Summaries

This API will be used to manage any actions done by the user. The tables that will be included are a User table, Reviews table a reviews comment table.

**User Table**: Will provide details of the user and maintain the inputs specific to the user such as the rooms that they are in, their peers and their pending requests

**Review Table**: Holds user information about each review that they have made

**Review Comments Table**: Holds comments that will be nested under each review

**Rooms Table**: Contains Room data

**Forum Table**: Contains Forum data

**Forum Comments Table**: Contains Forum Comment data
## API Reference
- [User endpoints](#User-Table)
- [Review endpoints](#Review-Table)
- [Review Comment endpoints](#Review-Comments-Table)
- [Room endpoints](#Rooms-Table)
- [Forum endpoints](#Forum-Table)
- [Forum Comment endpoints](#Forum-Comments-Table)

#### User Table
---
**Retreive all users** (index)

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

**Retreive all rooms that User is a member of**

```http
  GET /api/users/:user_id/rooms
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user_id` | `string` | Username of user |

**Retreive all reviews the User has created**

```http
  GET /api/users/:user_id/reviews
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user_id` | `string` | Username of user |


**Create a user** (create)

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


**Get specific User JSON object** (show)

```http
  GET /api/users/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id`| `string` | Username of User         |

* Refer to JSON object in Appendix


**Edit specific User JSON object** (update)

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

*Refer to JSON object in [Appendix](#Appendix)

**Delete User** (destroy)

```http
  DELETE /api/users/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `session_token_input`| `string` | User sign in token         |



---
#### Review Table
---
**Retreive all reviews** (index)

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

**Retreive all reviews of a specific user** (user_index)

```http
  GET /api/users/:userid/reviews/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user_id` | `string` | Insert into query param from the frontend component  |
| `current_user` | `string` | Insert into query param from the frontend component  |



**Create a review** (create)

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

**Add Review of User to all rooms**

```http
  GET /api/reviews/:review_id/rooms
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `review_action` | `string` | Will have either values: ("delete review" or "add review")  |
| `show_object` | `JSON` | Will be a Review object JSON  |

**Retrieve the review of a user**

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


**Edit Review of a User** (update)

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
| `likes` | `JSON` | View [JSON format](#Votes-and-likes-Parameter) in Appendex |

**Delete Review of a User** (destroy)

```http
  DELETE /api/reviews/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id` | `string` | Name of show being reviewed  |
| `review_id` | `string` | Name of show being reviewed  |
| `user_id` | `string` | Username of User  |
| `current_user` | `string` | Username of Current user  |


---
#### Review Comments Table
---
**Retreive all comments of a Review** (index)

```http
  GET /api/review_comments/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `review_id` | `integer` | Parameter inserted into query param from the frontend component  |


**Create a Review Comment** (create)

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


**Edit Review Comment of a User** (update)

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
| `likes` | `JSON` | View [JSON format](#Votes-and-likes-Parameter) in Appendex |

**Delete Review Comments of a User** (destroy)

```http
  DELETE /api/review_comments/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Review comment ID   |
| `user_id` | `string` | Username of the User |

---
#### Rooms Table
---
**Retreive all rooms** (index)

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


**Create a Room** (create)

```http
  POST /api/rooms/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `current_user` | `string` | The username interacting with the client  |
| `room_id` | `string` | Name of Room  |

**Add a user's reviews to the room show object**

```http
  PATCH /api/rooms/:room_id/add_user_reviews/:user_id
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user_id` | `string` | The username interacting with the client  |
| `room_id` | `string` | The show NAME of a review  |
| `room_action` | `string` | Values: ("member added" or "member removed") taken from previous API call  |


**Get a Room** (show)

```http
  POST /api/rooms/:id
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Name of the room  |


**Edit Room** (update)

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

**Delete Room** (destroy)

```http
  DELETE /api/rooms/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Room name  |
| `current_user` | `string` | Username of the client user  |


---
#### Forum Table
---
**Retreive all forums** (index)

```http
  GET /api/forums/
```

**Retreive all forums within specified room** (room_forum_index)

```http
  GET /api/rooms/:room_id/forums/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `room_id` | `string` | This will be the room_name of the room  |
| `forum_search` | `string` |  |
| `anime_search` | `string` |   |


**Create a forum** (create)

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


**Retrieve the Forum of a user**

```http
  GET /api/forums/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id` | `integer` | Primary key of Forum object  |


**Edit Forum of a Room** (update)

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
| `votes` | `JSON` | View [JSON format](#Votes-and-likes-Parameter) in Appendex |

**Delete Forum of a User** (destroy)

```http
  DELETE /api/forums/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id` | `integer` | Primary key of Forum object  |
| `room_id` | `string` | Room_name of Room  |
| `current_user` | `string` | Username of current user  |

---
#### Forum Comments Table
---
**Retreive all the TOP forum comments of a Forum** (index)

```http
  GET /api/forum_comments/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `forum_id` | `integer` | Forum Primary ID |


**Create a Forum Comment** (create)

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



**Edit Forum Comment** (update)

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
| `votes` | `JSON` | View [JSON format](#Votes-and-likes-Parameter) in Appendex |

**Delete Forum Comment of a User** (destroy)

```http
  DELETE /api/forum_comments/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Primary ID of existing Forum comment  |
| `forum_id` | `integer` | Forum Primary ID  |
| `comment_owner` | `string` | Username of commenter |
| `current_user` | `string` | Username of commenter |

## Appendix

Any additional information goes here

# Appendix

Find terms and formats utilized in the API below

### User peer Parameter input

The format of the parameter required will as follows

```
{ action: "add", peerFocus: "Desired Peer" }

```

* action key: ("add" or "remove")
* peerFocus key: This will be the desired peer that will be added or removed

### User Requests Parameter input

The format of the parameter required will as follows

```
{ action: "add", requestFocus: "Desired Peer" }
```

* Action key: ("add" or "remove")
* requestFocus key: This will be the desired peer that will be added or removed

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

### Action JSON to add Reviews to Rooms

The format of the parameter required will as follows

```
{ 
    "top": "80", 
    "bottom": "20" 
}
```

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

## Authors

- [Serge-Edouard Joseph](https://josephse91.github.io)