import { useState } from 'react';
import './ReviewsCommentsTable.css';


function ReviewCommentsTable() {
  const [review,setReview] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);
  const [testcase,setTestcase] = useState({});

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if(input.id === "reviewCommentsReview") {
      setReview((Number(input.value) || null))
    } else if (input.id === "request") {
      setRequest(input.value)
    } else if (input.id === "requestMethod") {
      setRequestMethod(input.value)
    } else if (input.id === "reviewKey") {
      setTestcase({...testcase, key: input.value})
    } else if (input.id === "value") {
      setTestcase({...testcase, value: input.value})
    }

    console.log(review,typeof review, request)
  }

  let formData = new FormData();
  let myHeaders = new Headers();

  async function apiRequest(options,searchParam) {
    let requestStr = "http://localhost:3000/" + request + searchParam;
    let apiRequest = await fetch(requestStr, options)
    let data = await apiRequest.json()
    setResponse(data)
    console.log(requestStr,data)

    // Logic meant to focus on the localStorage
    let dataMap = new Map(Object.entries(data))
    
    // capturing the session key if provided
    let AdSessionTokenKey = [...dataMap.keys()].includes("ad_session_token")
    let AdSessionTokenValue = dataMap.get("ad_session_token")

    if(AdSessionTokenKey && AdSessionTokenValue) {
      localStorage.setItem("ad_session_token",data["ad_session_token"])
      console.log("new session_token: ", data["ad_session_token"])
    } else if (AdSessionTokenKey && !AdSessionTokenValue) {
      localStorage.removeItem("ad_session_token")
      console.log("removed session_token: ", data["ad_session_token"])
    }

    let followUp = await followUpAPIs(data,searchParam)
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
    let testcaseInputString = JSON.stringify(testcaseInput);

    let search = "?"
    let user = "Serge"
    let comment = "We all seem to agree"

      search += "review_id=" + review;
      //search += `&comment=${comment}`;
      //search += `&user_id=${user}`;
      //search += "&comment_type=comment";
      //search += "&parent=" + 7;
      // search += "&top_comment=" + 16;

    if (search.length === 1) search = ""

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod == "DELETE") {
      options.body = formData;
      //formData.append("comment",comment);
      //formData.append("user_id",user)
      //formData.append("comment_type", "reply")
      //formData.append("parent",25)
      let likesAction = {user: user, initialLike: 0, targetLike: 1}
      formData.append("likes",JSON.stringify(likesAction))
      if (testcase.key) formData.append(testcase.key,testcaseInputString);
    }

    apiRequest(options,search)
    console.log("Submit has been handled")
  }

  // Follow up APIs

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

    let ActionUserUsername = actionUser.toLowerCase()

    if (ActionUserUsername === targetItem) return new Promise(resolve => {
      resolve({status: "N/A", message: "No notification required on self"})
    })

    if (data.notification_count) {
      endpoints["GET"] = {
        endpoint: `/api/notifications_count/${user}`,
        params: []
      }
    } else if (user !== actionUser) {
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
    console.log(endpointData,actionData)
    requestStr += endpoints[method].endpoint

    options5.method = method

    let formData5 = new FormData()
    options5.body = formData5

    let notifications = actionData.notifications
    let notificationData = []

    console.log(endpointData,actionData, method,notifications)

    // The following is to notify the appropriate users if there are multiple that need to be notified.
    for (let notification of notifications) {
      let param = "notification"
      let value = notification
      formData5.append(param,JSON.stringify(value))

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

  return (
    <div className="App" id="container">
      <div className='testForm' id='reviewCommentsTableForm'>
      <form className="credentials" onChange={handleChange}>
      <div className='inputLine'>
        <label htmlFor="reviewCommentsReview">Review:</label>
        <input type="text" id="reviewCommentsReview" name="reviewCommentsReview" value={review}/>
      </div>
      <div className='inputLine'>
        <label htmlFor="reviewKey">Key:</label>
        <input type="text" id="reviewCommentsKey" name="reviewCommentsKey" value={testcase.key}/>
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

export default ReviewCommentsTable
