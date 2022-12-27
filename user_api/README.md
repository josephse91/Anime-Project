
# User-Api-Documentation

This document details the information available for the users of the Anime Dojo application as well as the parameter requirements



## Table Summaries

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
  GET /api/users?search=[username]
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `search` | `string` | Username placed w/out brackets |

**Create a user** (create)

```http
  POST /api/users/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `username` | `string` | Must be unique                 |
| `password` | `string` | Must be at least 5 characters  |
| *`genre_preference` | `string` |                       |
| *`go_to_motto` | `string` |                            |
| *`user_grade_protocol` | `text` |                      |

* These inputs will be provided within account information

**Get specific User JSON object** (show)

```http
  GET /api/users/${username}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `username`| `string` | Username of item to fetch         |

* Refer to JSON object in Appendix


**Edit specific User JSON object** (update)

```http
  PATCH /api/users/${username}
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `username` | `string` | Must be unique                 |
| `password` | `string` | Must be at least 5 characters  |
| *`genre_preference` | `string` |                       |
| *`go_to_motto` | `string` |                            |
| *`user_grade_protocol` | `text` |                      |
| **`rooms` | `json` | View [JSON format](#User-room-&-peer-Parameter-input) in Appendex |
| **`peers` | `json` | View [JSON format](#User-room-&-peer-Parameter-input) in Appendex |
| **`requests` | `json` | View [JSON format](#User-Requests-Parameter-input) in Appendex |

*These inputs will be provided within account information
**Refer to JSON object in [Appendix](#Appendix)

**Delete User** (destroy)

```http
  DELETE /api/users/${username}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `username`| `string` | Username of item to fetch         |



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

**Retreive all review of a specific user** (user_index)

```http
  GET /api/users/:userid/reviews/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `user` | `string` | Insert into query param from the frontend component  |
| `in_network` | `string` | input "true" if you're looking for reviews within network |
| `range` | `JSON` |  View [JSON format](#Review-Table-Range-Parameter) in Appendex |


**Create a review** (create)

```http
  POST /api/reviews/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user` | `string` | Insert into query param from the frontend component  |
| `show` | `string` | Insert into form Param  |
| `rating` | `integer` | Number between 0 and 100. Insert into form Param |
| `amount_watched` | `string` | Insert into form Param |
| `highlighed_points` | `text` | Insert into form Param |
| `overall_review` | `text` | Insert into form Param |
| `referral_id` | `string` | This will be the referrer username. Insert into form Param |
| `watch_priority` | `integer` | Will be -1, 0 or 1. Insert into form Param |
| `likes` | `integer` | Insert into form Param |

*Output will be an javascript object that has a status key and review key. The review key will contain the object being created

**Retrieve the review of a user**

```http
  GET /api/reviews/${show}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `user` | `string` | Insert into query param from the frontend component  |
| `show` | `string` | Insert into form Param  |

* Refer to JSON object in Appendix


**Edit Review of a User** (update)

```http
  PATCH /api/reviews/${show}
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `user` | `string` | Insert into query param from the frontend component  |
| `show` | `string` | Insert into form Param  |
| `rating` | `integer` | Number between 0 and 100. Insert into form Param |
| `amount_watched` | `string` | Insert into form Param |
| `highlighed_points` | `text` | Insert into form Param |
| `overall_review` | `text` | Insert into form Param |
| `referral_id` | `string` | This will be the referrer username. Insert into form Param |
| `watch_priority` | `integer` | Will be -1, 0 or 1. Insert into form Param |
| `likes` | `integer` | Insert into form Param |

**Delete Review of a User** (destroy)

```http
  DELETE /api/reviews/${show}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `user` | `string` | Insert into query param from the frontend component  |
| `show` | `string` | Insert into form Param  |


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
  POST /api/reviews/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `review_id` | `integer` | Insert into query param from the frontend component  |
| `comment` | `text` | Insert into form Param  |
| `user_id` | `string` | Insert into form Param |
| `comment_type` | `string` | Insert into form Param |
| `parent` | `integer` | Insert into form Param |
| `top_comment` | `integer` | Insert into form Param |
| `likes` | `integer` | Insert into form Param |

*Output will be an javascript object that has a status key and review key. The review key will contain the object being created


**Edit Review Comment of a User** (update)

```http
  PATCH /api/review_comments/${:id}
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Review comment ID  |
| `review_id` | `integer` | Insert into query param from the frontend component  |
| `comment` | `text` | Insert into form Param  |
| `user_id` | `string` | Insert into form Param |
| `comment_type` | `string` | Insert into form Param |
| `parent` | `integer` | Insert into form Param |
| `top_comment` | `integer` | Insert into form Param |
| `likes` | `integer` | Insert into form Param |

**Delete Review of a User** (destroy)

```http
  DELETE /api/review_comments/${id}
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Insert into query param from the frontend component  |

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
| `room_name` | `string` | Insert from form  |

**Get a Room** (show)

```http
  POST /api/rooms/${:id}
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Name of the room  |


**Edit Room** (update)

```http
  PATCH /api/rooms/${:id}
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `string` | Name of the room  |
| `current_user` | `string` | The username interacting with the client  |
| `request` | `string` | Username looking to access room |
| `submitted_key` | `string` | Key submitted by User looking to enter room|
| `user_remove` | `string` | Username to delete by admin |
| `room_name` | `string` | Name of Room |
| `make_entry_key` | `boolean` | Allowed keys generated for access into room |
| `users` | `JSON` | { key: username, value: date of entry } |
| `private` | `boolean` | Form data |
| `admin` | `JSON` | { group_admin =>true, admin_users => {} } |
| `entry_keys` | `JSON` | { key: generated key, value: expiration } |

**Delete Room** (destroy)

```http
  DELETE /api/rooms/${id}
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


**Create a review** (create)

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


**Retrieve the review of a user**

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
| `votes` | `JSON` | JSON object that has the keys, "up" and "down" |

**Delete Review of a User** (destroy)

```http
  DELETE /api/reviews/:id
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
| `parent` | `integer` | Primary ID of parent comment. NULL if there is no parent |
| `top_comment` | `integer` |  |



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
| `parent` | `integer` | Primary ID of parent comment. NULL if there is no parent |
| `top_comment` | `integer` |  |
| `votes` | `JSON` | JSON object that has the keys, "up" and "down" |

**Delete Forum Comment of a User** (destroy)

```http
  DELETE /api/forum_comments/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | Primary ID of existing Forum comment  |
| `forum_id` | `integer` | Forum Primary ID  |
| `comment_owner` | `string` | Username of commenter |


# Appendix

Find terms and formats utilized in the API below

### User room & peer Parameter input

The format of the parameter required will as follows

```
{ action: "add",focusRoom: "value" }
{ action: "remove",focusPeer: "value" }
```

* action key: ("add" or "remove")
* The second key should be (focusRoom or focusPeer) depending on which parameter you're looking to provide. This will be the name of the room looking to be added or removed

### User Requests Parameter input

The format of the parameter required will as follows

```
{ action: "add",
  requestType: ${type of request},
  focusRequest: ${room or peer requesting connection},
  val: "value" }
```

* Action key: ("add" or "remove")
* RequestType key: ("room","peer" or "roomAuth")
* FocusRequest Key should have the room or peer that is requesting connection
* Val key is the user on the other end of the room request

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



## Authors

- [Serge-Edouard Joseph](https://josephse91.github.io)

