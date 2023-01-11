# Notifications-Api-Documentation

The Notifications API will be used to persist data pertaining to notifications

[Go to Appendix](#Appendix)

---
#### **Notifications Table** 
[index](#retreive-all-notifications-index) / 
[create](#create-a-like-create) / 
[notification count](#show-unread-notification-count-of-a-user-new_notifications) / 
[show](#show-notifications-of-a-user-show) / 
[update](#edit-all-unseen-notifications-update)

---
#### Retreive all notifications: index

```http
  GET /api/notifications/
```
[Back to top of Notifications](#notifications-table)

#### Create a like: create

```http
  POST /api/notifications/
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `notification` | `JSON` | [View JSON format in Appendex]()|

[Back to top of Notifications](#notifications-table)

#### Show unread notification count of a user: new_notifications

```http
  GET /api/notifications_count/:id
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | The id will be the recipient of the notifications|

*The purpose of this endpoint is to retrieve the number of unseen notifications.*

[Back to top of Notifications](#notifications-table)

#### Show notifications of a user: show

```http
  GET /api/notifications/:id
```
| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | The id will represent the recipient of the notification|

[Back to top of Notifications](#notifications-table)

#### Edit all unseen notifications: update

```http
  PATCH /api/notifications/:id
```

| Parameter  | Type     | Description                    |
| :--------- | :------- | :-------------------------     |
| `id` | `integer` | The id will represent the recipient of the notification|

*The purpose of this endpoint is to take all of the unseen notifications of a 
recipient and change them to seen.*

[Back to top of Notifications](#notifications-table) / 
[Back to Top](#notifications-api-documentation)

# Appendix

Terms and formats utilized in the API

[Back to Top](#notifications-api-documentation)

## Notification JSON

```
notification: {
    id: ${content primary id},
    recipient: ${recipient username},
    action: ${like, neutral or unlike},
    action_user: ${username of user making action},
    target_item: ${Type of item being acted upon}
}
```

Optional Keys:

`show` : This key will be present in the notification JSON if the target_item is a review or review comment

`room` : This key will be present in the notification JSON if the target_item is a forum or forum comment