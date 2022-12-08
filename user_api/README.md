
# User-Api-Documentation

This document details the information available for the users of the Anime Dojo application as well as the parameter requirements



## Table Summaries

This API will be used to manage any actions done by the user. The tables that will be included are a User table, Reviews table a reviews comment table.

[**User Table**](#User-Table): Will provide details of the user and maintain the inputs specific to the user such as the rooms that they are in, their peers and their pending requests

**Review Table**: Holds user information about each review that they have made

**Review Comments**: Holds comments that will be nested under each review
## API Reference
- User endpoints
- Review endpoints
- Review Comment endpoints

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
| **`rooms` | `json` | View [JSON format](#User-room/peer-Parameter-input) below            |
| **`peers` | `json` | View [JSON format](#User-room/peer-Parameter-input) below            |
| **`requests` | `json` | View [JSON format](#User-Requests-Parameter-input) below         |

*These inputs will be provided within account information
**Refer to JSON object in [Appendix](#Appendix)

**Delete User** (destroy)

```http
  DELETE /api/users/${username}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `username`| `string` | Username of item to fetch         |

# Appendix

Find terms and formats utilized in the API below

### User room/peer Parameter input

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



## Authors

- [Serge-Edouard Joseph](https://josephse91.github.io)

