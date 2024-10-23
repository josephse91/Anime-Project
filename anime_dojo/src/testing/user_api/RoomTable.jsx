import { useState } from 'react';
import './RoomTable.css';


function RoomTable() {
  const [room, setRoom] = useState("");
  const [search,setSearch] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);
  const [testcase,setTestcase] = useState({});

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if (input.id ==="room") {
      setRoom(input.value)
    } else if (input.id === "search") {
      setSearch(input.value)
    } else if (input.id === "request") {
      setRequest(input.value)
    } else if (input.id === "requestMethod") {
      setRequestMethod(input.value)
    } else if (input.id === "key") {
      setTestcase({...testcase, key: input.value})
    } else if (input.id === "value") {
      setTestcase({...testcase, value: input.value})
    }
    console.log(room,search)
    console.log(testcase, request)
  }

  let formData = new FormData();
  let myHeaders = new Headers();
  let formData2 = new FormData();

  async function apiRequest(options,query = null) {
    let queryInput = query ? query : "";
    let requestStr = "http://localhost:3000" + request + queryInput, requestStr2;
    let apiRequest = await fetch(requestStr, options), apiRequest2
    let data = await apiRequest.json()//, data2
    setResponse(data)
    console.log(requestStr,data)

    const options2 = {
      headers: myHeaders,
      method: "PATCH"
    }
    let requestMethod2 = options2.method

    async function addReviewsToRooms(data) {
      let user = data.user
      let room = data.room
      let roomAction = data.action

      if (roomAction === "delete room") return new Promise(resolve => {
        console.log("Add Reviews API is not used")
        resolve({status: "failed", message: "add Reviews API is not used"})
      })

      if (
        data.status === "complete" && 
        requestMethod2 === "PATCH" &&
        roomAction
        ) {
        options2.body = formData2;
        
        // console.log("This is complete data: ",data, "This is the data action: ", data.action, action, typeof action)
        formData2.append("room_action",roomAction)

        requestStr2 = "http://localhost:3000/api/"
        requestStr2 += `rooms/${room.room_name}/add_user_reviews/${user.username}`
        apiRequest2 = await fetch(requestStr2, options2)
        let data2 = await apiRequest2.json()
        console.log(apiRequest2.url, data2, options2)

        return new Promise(resolve => resolve({status: "success", data: data2}))
      }

      return new Promise(resolve => resolve({status: "failed"}))
    }

      apiRequest2 = await addReviewsToRooms(data)

    

    if (data.notifications || data.notification_count) {
      const notificationsEndpoint = await notificationRequests(data)
      const notifications = await notificationsCall(notificationsEndpoint,data)
    }

    const data3 = apiRequest2.data 
    console.log("this is new data: ",data)
    // conditional is necessary because the data3 relies on the addReviewsToRooms function which isn't run when a room is deleted. This is because when deleting a room, the addReviewsToRooms function requires a room object search that no longer exists
    
    if(data.action !== "delete room") {
      var showEndpoints = await showRatingRequests(data3)
    } else {
      var showEndpoints = await showRatingRequests(data)
    }
    
    const showRequest = await showRatingCalls(showEndpoints)

    return showRequest
  }

  async function showRatingRequests(data) {
    if (!data || data.status === "failed") return new Promise(resolve => {
      //console.log("Add reviews to Room Request Failed")
      resolve({status: "failed"})
    })

    let endpoints = {};
    if (data.action === "member added" && data.add_shows.length) {
      endpoints["POST"] = {
        endpoint: "/api/show_ratings/",
        params: [
          ["reviews", data.add_shows],
          ["room_id", data.room.room_name],
        ]
      }
    }

    if (data.action === "member added" && data.edit_existing_shows.length) {
      endpoints["PATCH"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["reviews", data.edit_existing_shows],
          ["room_id", data.room.room_name],
          ["show_action", data.action]
        ]
      }
    }

    if (data.action === "member removed" && data.remove_shows.length) {
      endpoints["DELETE"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["reviews", data.remove_shows],
          ["room_id", data.room.room_name]
        ]
      }
    }

    if (data.action === "member removed" && data.edit_existing_shows.length) {
      endpoints["PATCH"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["reviews", data.edit_existing_shows],
          ["room_id", data.room.room_name],
          ["show_action", data.action]
        ]
      }
    }

    if (data.action === "add review" && data.rooms_to_add_show.length) {
      endpoints["POST"] = {
        endpoint: "/api/show_ratings/",
        params: [
          ["review", data.review],
          ["rooms", data.rooms_to_add_show],
        ]
      }
    }

    if (data.action === "add review" && data.rooms_to_edit_show.length) {
      endpoints["PATCH"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["review", data.review],
          ["rooms", data.rooms_to_edit_show],
          ["show_action", data.action]
        ]
      }
    }

    if (data.action === "edit review" && data.rooms_to_edit_show.length) {
      endpoints["PATCH"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["review", data.review],
          ["rooms", data.rooms_to_edit_show],
          ["show_action", data.action]
        ]
      }
    }

    if (data.action === "delete review" && data.rooms_to_edit_show.length) {
      endpoints["PATCH"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["review", data.review],
          ["rooms", data.rooms_to_edit_show],
          ["show_action", data.action]
        ]
      }
    }

    if (data.action === "delete review" && data.rooms_to_delete_show.length) {
      endpoints["DELETE"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["review", data.review],
          ["rooms", data.rooms_to_delete_show]
        ]
      }
    }

    if (data.action === "delete room" && data.remove_shows.length) {
      endpoints["DELETE"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["reviews", data.remove_shows],
          ["room_id", data.room]
        ]
      }
    }
    return endpoints
  }

  async function showRatingCalls(requestInfo) {
    if (requestInfo.status === "failed") return new Promise(resolve => {
      console.log("Show API was not run")
      resolve({status: "failed"})
    })

    const options3 = {
      headers: myHeaders,
    }
    
    let requestStr = "http://localhost:3001";
    let currentReq = ""
    for (let [method,info] of Object.entries(requestInfo)) {
      options3.method = method;
      let formData3 = new FormData()
      options3.body = formData3

      for (let i = 0; i < info.params.length; i++) {
        let param = info.params[i][0]
        let value = info.params[i][1]
        if (param === "reviews" || param === "rooms" || param === "review") {
          value = JSON.stringify(value)
        }
        formData3.append(param,value)
      }

      currentReq = requestStr + info.endpoint
      let apiRequest = await fetch(currentReq, options3)
      let data = await apiRequest.json()
      console.log(currentReq, data)
    }
    return "Function call complete"
  }

  async function notificationRequests(data) {
    let endpoints = {};
    let user = data.notifications[0].recipient
    let actionUser = data.notifications[0].action_user
    let targetItem = data.notifications[0].target_item.toLowerCase()

    if (data.notification_count) {
      endpoints["GET"] = {
        endpoint: `/api/notifications_count/${user}`,
        params: []
      }
    } else if (user === actionUser && targetItem !== "recommendation") {
      endpoints["PATCH"] = {
        endpoint: `/api/notifications/${user}`,
        params: []
      }
    } else if (user !== actionUser || targetItem == "recommendation") {
      endpoints["POST"] = {
        endpoint: `/api/notifications/`,
        params: ["notification", data]
      }
    }
    return new Promise(resolve => resolve({status: "success", endpoints: endpoints}))
  }

  async function notificationsCall(endpointData,actionData) {
    const options5 = {
      headers: myHeaders,
    }
    
    let requestStr = "http://localhost:3003";

    const method = Object.keys(endpointData.endpoints)[0]
    const endpoints = endpointData.endpoints

    options5.method = method

    let formData5 = new FormData()
    options5.body = formData5

    let notifications = actionData.notifications
    let notificationData = []

    console.log(endpointData,actionData, method,notifications)

    for (let notification of notifications) {
      let param = "notification"
      let value = notification
      formData5.append(param,JSON.stringify(value))

      requestStr += endpoints[method].endpoint
      let apiRequest = await fetch(requestStr, options5)
      let data = await apiRequest.json()
      console.log(requestStr, data)
      notificationData.push(data) 
    }

    return new Promise(resolve => resolve({status: "success", data: notificationData}))
  }
  
  let sendRequest = function(e) {
    e.preventDefault;

    const options = {
      headers: myHeaders,
      method: requestMethod
    }

    //Local storage has been selected as the cookie to preserve the session token.
    // Since the local storage cannot be captured by the rails API directly, the localstorage is always sent through the header

    const adSessionToken = localStorage.getItem('ad_session_token')
    let headerSessionToken = myHeaders.get("ad_session_token")

    //headerSessionToken = "KhSsq5juOk2LkD08FsTMfg" //Serge
    //headerSessionToken = "Tq13m7KnuZYMMCGCvujABA" //David
    //headerSessionToken = "0KJU4ULJdT2bXaKqM3dqwQ" //Aviel
    headerSessionToken = "JNoCEcPm9X1WSjqCkPS2GQ" //Aldane
    //headerSessionToken = "KhSsq5juOk2LkD08FsTMfg" //Serge
    //headerSessionToken = "rsT2jbeua6Jc6e3gwpP0lA" //Tonette Stokes DVM
    //headerSessionToken = "1U7bmf8siS6tZ3Cn_n1DPw" //Mrs. Erasmo Runolfsson
    //headerSessionToken = "z8e2d3ji4MaFjztwIM1dCw" //Mittie Hermiston
    //headerSessionToken = "MYac2pD4MEWup9jhaekk_g" //Allia
    

    if(headerSessionToken) {
      myHeaders.set("ad_session_token",headerSessionToken);
      //myHeaders.set("ad_session_token",adSessionToken);
    } else {
      myHeaders.set("ad_session_token",headerSessionToken);
      //myHeaders.append("ad_session_token",adSessionToken)
    }

    if (room) formData.append('room_id',room);

    // This is where you will format the testcase values
    // let testcaseInput = JSON.stringify({action: "add",focusRequest: testcase.value })
    let testcaseInput = testcase.value
    // let testcaseInputString = JSON.stringify(testcaseInput)
    let testcaseInputString = testcaseInput;

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod === "DELETE") {
      options.body = formData
      //formData.append("request","Aldane")
      //formData.append("private_room",false)
      //formData.append("submitted_key", "3mosYAlgW2nqU9UTecscgQ")
      //formData.append("make_entry_key", true)
      // formData.append("user_remove","Aviel")
      formData.append("room_action","remove user")
      formData.append(testcase.key,testcaseInputString)
    }

    apiRequest(options,search)
    console.log("Submit has been handled")
  }

  return (
    <div className="App" id="container">
      <div className='testForm' id='userTableForm'>
      <form className="credentials" onChange={handleChange}>
      <div className='inputLine'>
        <label htmlFor="room">Room:</label>
        <input type="text" id="room" name="room" value={room}></input>
      </div>
      <div className='inputLine'>
        <label htmlFor="search">Search:</label>
        <input type="text" id="search" name="search" value={search}/>
      </div>
      <div className='inputLine'>
          <label htmlFor="key">Key:</label>
          <input type="text" id="key" name="key" value={testcase.key}/>
          <label htmlFor="value">Value:</label>
          <input type="text" id="value" name="value" value={testcase.value}/>
      </div>
      <div className='inputLine'>
          <label htmlFor="method">Method:</label>
          <input type="text" id="requestMethod" name="requestMethod" value={requestMethod}/>
          <label htmlFor="request">Request:</label>
          <input type="text" id="request" name="request" value={request}/>
      </div>  
      </form>
      <button className='request' id="requestButton" onClick={sendRequest}>Send</button>
      </div>
      
    </div>
  )
}



export default RoomTable
