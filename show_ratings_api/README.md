# Show-Ratings-Api-Documentation

The Show Ratings API will be used to persist data pertaining to the group reviews within a room.

Refer to Reviews and Rooms frontend testing to see how to implement parameters

[Go to Appendix](#Appendix)
---
#### **Show Rating Table** 
[index](#retreive-all-shows-index) / 
[room_show_index](#retreive-all-room-shows-room-show-index) / 
[create](#create-a-show-rating-create) / 
[update](#edit-show-rating-update) / 
[delete](#delete-show-rating-destroy) 

[Back to API Reference](#API-Reference)

---
#### Retreive all shows: index

```http
  GET /api/show_ratings/
```

#### Retreive all room shows: room show index

```http
  GET /api/rooms/:room_id/show_ratings/
```

| Parameter | Type     | Description                   |
| :-------- | :------- | :-------------------------    |
| `room_id` | `string` | Room_name of Room |

#### Create a Show Rating: create

```http
  POST /api/show_ratings/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `room_id` | `string` | Room_name which will receive Reviews to add or remove|
| `rooms` | `string` | Array of rooms which will add or remove a single review.|
| `review` | `JSON` | Single review which will be added to multiple rooms |
| `reviews` | `JSON` | Array of reviews which will be added to a single room |


#### Edit Show Rating: update

```http
  PATCH /api/show_ratings/fill
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `show_action` | `string` | Shows action taken for review(s). [Appendix for options](#update-show-actions|
| `room_id` | `string` | Room_name which will receive Reviews to add or remove|
| `rooms` | `string` | Array of rooms which will add or remove a single review.|
| `review` | `JSON` | Single review which will be added to multiple rooms |
| `reviews` | `JSON` | Array of reviews which will be added to a single room |

#### Delete Show Rating: destroy

```http
  DELETE /api/show_ratings/fill
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `room_id` | `string` | Room_name which will receive Reviews to add or remove|
| `rooms` | `string` | Array of rooms which will add or remove a single review.|
| `review` | `JSON` | Single review which will be added to multiple rooms |
| `reviews` | `JSON` | Array of reviews which will be added to a single room |

# Appendix

Terms and formats utilized in the API

## Update Show Actions
- add review
- edit review
- delete review
- member added
- member removed