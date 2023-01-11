# Likes-Api-Documentation

The Likes API will be used to persist data pertaining to any form of liking an object. The objects that can be liked currently are reviews, review comments, forums and forum comments

[Go to Appendix](#Appendix)

---
#### **Likes Table** 
[index](#retreive-all-likes-index) / 
[create](#create-a-like-create) / 
[show](#show-likes-of-a-user-show) / 
[update](#edit-show-rating-update) / 
[delete](#delete-show-rating-destroy) 

---
#### Retreive all likes: index

```http
  GET /api/likes/
```
[Back to top of Likes](#likes-table)

#### Create a like: create

```http
  POST /api/likes/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `like_action` | `JSON` | [View JSON format in Appendex](#like-action-json)|

[Back to top of Likes](#likes-table)

#### Show likes of a user: show

```http
  GET /api/likes/:id
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | The id will represent the desired item's primary id|
| `item_type` | `string` | This will be the target item type such as review, forum, etc.|

[Back to top of Likes](#likes-table)

#### Edit Show Rating: update

```http
  PATCH /api/likes/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | The id will represent the desired item's primary id|
| `like_action` | `JSON` | [View JSON format in Appendex](#like-action-json)|

[Back to top of Likes](#likes-table)

#### Delete Show Rating: destroy

```http
  DELETE /api/likes/:id
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id` | `integer` | The id will represent the desired item's primary id|
| `like_action` | `JSON` | [View JSON format in Appendex](#like-action-json)|

[Back to top of Likes](#likes-table)


# Appendix

Terms and formats utilized in the API

## Like Action JSON

```
like_action: {
    id: ${content primary id},
    recipient: ${recipient username},
    action: ${like, neutral or unlike},
    action_user: ${username of user making action},
    target_tiem: ${Type of item being acted upon}
}
```