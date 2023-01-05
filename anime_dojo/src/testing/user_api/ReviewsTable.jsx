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
    let requestStr = "http://localhost:3000/" + request + searchParam, requestStr2;
    let apiRequest = await fetch(requestStr, options), apiRequest2
    let data = await apiRequest.json(), data2
    console.log(requestStr, data)

    const options2 = {
      headers: myHeaders,
      method: "PATCH"
    }
    let requestMethod2 = options2.method

    async function addReviewsToRooms(data) {
      if (data.status === "complete" && requestMethod2 === "PATCH") {
        options2.body = formData2;
        let review = data.review
        let reviewAction = data.action
        // console.log("This is complete data: ",data, "This is the data action: ", data.action, action, typeof action)
        formData2.append("review_action",reviewAction)
        formData2.append("show_object",JSON.stringify(review))

        requestStr2 = `http://localhost:3000/api/reviews/${review.show}/rooms`+ searchParam;
        apiRequest2 = await fetch(requestStr2, options2)
        data2 = await apiRequest2.json()
        console.log(apiRequest2, data2,options2)

        return new Promise(resolve => resolve({status: "success", data: data2}))
      }

      return new Promise(resolve => resolve({status: "failed"}))
    }

    setResponse(data)

    apiRequest2 = await addReviewsToRooms(data)
    // data2 = await apiRequest2.json()
    const data3 = apiRequest2.data

    console.log(requestStr2, data2)

    const showEndpoints = await showRatingRequests(data3)
    const showRequest = await showRatingCalls(showEndpoints)

    return showRequest
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
      let data = await apiRequest.json()
      console.log(currentReq, data) 
    }
    return "Function call complete"
  }

  
  
  let sendRequest = function(e) {
    e.preventDefault;

    const options = {
      headers: myHeaders,
      method: requestMethod
    }

    // This is where you will format the testcase values
    // let testcaseInput = JSON.stringify({action: "add",focusRequest: testcase.value })
    let testcaseInput = testcase.value;
    let testcaseInputString = typeof testcase.value ==="number" ? Number(testcase.value) : testcaseInput;

    let search = ""
    if (user) {
      search += "?current_user=" + user;
      // search += "&in_network=true";
      // let range = JSON.stringify({"top": 95, "bottom":80})
      // search += `&range=${range}`;
    }

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod == "DELETE") {
      options.body = formData;
      formData.append("rating",90)
      formData.append("amount_watched","Completed")
      // // formData.append("highlighted_points",'[]')
      formData.append("overall_review","This anime is growing on me")
      // formData.append("referral_id","Jarret")
      formData.append("watch_priority",0)
      // let likesAction = {user: user, net: 0, target: 1}
      // formData.append("likes",JSON.stringify(likesAction))

      if (testcase.key) formData.append(testcase.key,testcaseInputString);
    }

    apiRequest(search,options)
    console.log("Submit has been handled")
  }

  return (
    <div className="App" id="container">
      <div className='testForm' id='reviewTableForm'>
      <form className="credentials" onChange={handleChange}>
        <label htmlFor="reviewUser">User:</label>
        <input type="text" id="reviewUser" name="reviewUser" value={user}/>
        <label htmlFor="reviewKey">Key:</label>
        <input type="text" id="reviewKey" name="reviewKey" value={testcase.key}/>
        <label htmlFor="value">Value:</label>
        <input type="text" id="value" name="value" value={testcase.value}/>

        <div id="requestLabels">
          <label htmlFor="method">Method:</label>
          <label htmlFor="request">Request:</label>
        </div>
        
        <div id="requestInputs">
          <input type="text" id="requestMethod" name="requestMethod" value={requestMethod}/>
          <input type="text" id="request" name="request" value={request}/>
        </div>
        
      </form>
      <button className='request' id="requestButton" onClick={sendRequest}>Send</button>
      </div>
      
    </div>
  )
}

export default ReviewTable
