import { useState } from 'react';
import './ReviewsTable.css';


function ReviewTable() {
  const [user,setUser] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);
  const [testcase,setTestcase] = useState({});

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if(input.id === "reviewUser") {
      setUser(input.value)
    } else if (input.id === "request") {
      setRequest(input.value)
    } else if (input.id === "requestMethod") {
      setRequestMethod(input.value)
    } else if (input.id === "reviewKey") {
      setTestcase({...testcase, key: input.value})
    } else if (input.id === "value") {
      setTestcase({...testcase, value: input.value})
    }

    console.log(testcase, request)
  }

  let formData = new FormData();
  let formData2 = new FormData();
  let myHeaders = new Headers();

  async function apiRequest(searchParam,options) {
    let requestStr = "http://localhost:3000/" + request + searchParam;
    let apiRequest = await fetch(requestStr, options)
    let data = await apiRequest.json()
    console.log(requestStr, data)

    setResponse(data)

    let followUp = await followUpAPIs(data,searchParam)
  }

  async function followUpAPIs(data,searchParam) {
    if (data.status === "failed") return new Promise(resolve => {
      resolve({status: "N/A", message: "follow up API was not utilized"})
    })

    const likeActions = new Set(["like","neutral","unlike"])
    const reviewActions = new Set(["add review","edit review","delete review"])
    const roomActions = new Set(["member added","member removed"])
    
    let followUpData

    if (likeActions.has(data.action)) {
      const endpoints = await likeAPIendpoint(data)
      const likeRequest = await likeAPICall(endpoints.endpoints)

      followUpData = likeRequest
    } else {
      let apiRequest2 = await addReviewsToRooms(data,searchParam)
      // data2 = await apiRequest2.json()
      const data3 = apiRequest2.data

      const showEndpoints = await showRatingRequests(data3)
      const showRequest = await showRatingCalls(showEndpoints)

      followUpData =  showRequest
    }

    if (data.notifications || data.notification_count) {
      const notificationsEndpoint = await notificationRequests(data)
      const notifications = await notificationsCall(notificationsEndpoint,data)
    }
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

  async function likeAPIendpoint(data) {

    let endpoints = {};
    const itemID = data.like_action.id

    let runAPI = true;

    // net is the starting value of a current_user like status. Which means the like is being created for the first time
    if (data.like_action.initialLike === 0) {
      endpoints["POST"] = {
        endpoint: "/api/likes/",
        params: [
          ["like_action", data.like_action]
        ]
      }
    } else if (data.action === "neutral") {

      endpoints["DELETE"] = {
        endpoint: `/api/likes/${itemID}`,
        params: [
          ["like_action", data.like_action]
        ]
      }
    } else if (data.action === "like" || data.action === "unlike") {
      endpoints["PATCH"] = {
        endpoint: `/api/likes/${itemID}`,
        params: [
          ["like_action", data.like_action]
        ]
      }
    }
    return new Promise(resolve => resolve({status: "success", endpoints: endpoints}))
  }

  async function likeAPICall(likeEndpoint) {
    const options4 = {
      headers: myHeaders,
    }
    
    let requestStr = "http://localhost:3002";

    const method = Object.keys(likeEndpoint)[0]

    options4.method = method

    let formData4 = new FormData()
    options4.body = formData4

    let params = likeEndpoint[method].params

    for (let i = 0; i < params.length; i++) {
      let param = params[i][0]
      let value = params[i][1]
      if (param === "like_action") {
        value = JSON.stringify(value)
      }
      formData4.append(param,value)
    }

    requestStr += likeEndpoint[method].endpoint
    let apiRequest = await fetch(requestStr, options4)
    let data = await apiRequest.json()
    console.log(requestStr, data) 

    return new Promise(resolve => resolve({status: "success", data: data}))
  }

  async function addReviewsToRooms(data,searchParam) {
    let data2
    let apiRequest2

    const options2 = {
      headers: myHeaders,
      method: "PATCH"
    }

    let requestMethod2 = options2.method

    if (data.status === "complete" && requestMethod2 === "PATCH") {
      options2.body = formData2;
      let review = data.review
      let reviewAction = data.action
      // console.log("This is complete data: ",data, "This is the data action: ", data.action, action, typeof action)
      formData2.append("review_action",reviewAction)
      formData2.append("show_object",JSON.stringify(review))

      let requestStr2 = `http://localhost:3000/api/reviews/${review.show}/rooms`+ searchParam;
      let apiRequest2 = await fetch(requestStr2, options2)
      let data2 = await apiRequest2.json()
      console.log(apiRequest2, data2,options2)

      return new Promise(resolve => resolve({status: "success", data: data2}))
    }

    return new Promise(resolve => resolve({status: "failed"}))
  }

  async function showRatingRequests(data) {
    if (data.status === "failed") return new Promise(resolve => {
      resolve({status: "failed"})
    })

    let endpoints = {};
    if (data.action === "member added" && data.add_shows.length) {
      endpoints["POST"] = {
        endpoint: "/api/show_ratings/",
        params: [
          ["reviews", data.add_shows],
          ["room_id", data.room],
        ]
      }
    }

    if (data.action === "member added" && data.edit_existing_shows.length) {
      endpoints["PATCH"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["reviews", data.edit_existing_shows],
          ["room_id", data.room],
          ["show_action", data.action]
        ]
      }
    }

    if (data.action === "member removed" && data.remove_shows.length) {
      endpoints["DELETE"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["reviews", data.remove_shows],
          ["room_id", data.room]
        ]
      }
    }

    if (data.action === "member removed" && data.edit_existing_shows.length) {
      endpoints["PATCH"] = {
        endpoint: "/api/show_ratings/fill",
        params: [
          ["reviews", data.edit_existing_shows],
          ["room_id", data.room],
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
    return endpoints
  }

  async function showRatingCalls(requestInfo) {
    const options3 = {
      headers: myHeaders,
    }

    let data
    
    let requestStr = "http://localhost:3001";
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

      let currentReq = requestStr += info.endpoint
      let apiRequest = await fetch(currentReq, options3)
      data = await apiRequest.json()
      console.log(currentReq, data) 
    }
    return new Promise(resolve => resolve({status: "success", data: data}))
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
    if(headerSessionToken) {
      myHeaders.set("ad_session_token",adSessionToken);
    } else {
      myHeaders.append("ad_session_token",adSessionToken)
    }

    // This is where you will format the testcase values
    // let testcaseInput = JSON.stringify({action: "add",focusRequest: testcase.value })
    let testcaseInput = testcase.value;
    let testcaseInputString = typeof testcase.value ==="number" ? Number(testcase.value) : testcaseInput;

    let search = ""
    if (user) {
      // Since there is no body allowed in form data in a GET request, this must be sent through the query data
      search += "?user_id=" + user;
      //search += "&in_network=true";
      // let range = JSON.stringify({"top": 95, "bottom":80})
      // search += `&range=${range}`;
    }
    myHeaders.append("user_id",user);

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod == "DELETE") {
      options.body = formData
      if (testcase.key) formData.append(testcase.key,testcaseInput)
      // The next few lines are meant for review creation and editting
      formData.append("rating",87)
      //formData.append("amount_watched","completed")
      //formData.append("highlighted_points",'Surprisingly and epicly sad ending')
      //formData.append("overall_review","This has the qualities to be a classic")
      //formData.append("watch_priority",1)
      //let likesAction = {user: user, initialLike: 0, targetLike: 1}
      //formData.append("likes",JSON.stringify(likesAction))

      // formData.append("referral_id","Jarret") (Never required)

      if (testcase.key) formData.append(testcase.key,testcaseInputString);
    }

    apiRequest(search,options)
    console.log("Submit has been handled")
  }

  return (
    <div className="App" id="container">
      <div className='testForm' id='reviewTableForm'>
      <form className="credentials" onChange={handleChange}>
        <div className='inputLine'>
          <label htmlFor="reviewUser">User:</label>
          <input type="text" id="reviewUser" name="reviewUser" value={user}/>
        </div>
        <div className='inputLine'>
          <label htmlFor="reviewKey">Key:</label>
          <input type="text" id="reviewKey" name="reviewKey" value={testcase.key}/>
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

export default ReviewTable
