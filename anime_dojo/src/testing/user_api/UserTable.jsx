import { useState } from 'react';
import './UserTable.css';


function UserTable() {
  const [currentUser, setUsername] = useState("");
  const [password,setPassword] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);
  const [testcase,setTestcase] = useState({});

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if (input.id ==="currentUser") {
      setUsername(input.value)
    } else if (input.id === "password") {
      setPassword(input.value)
    } else if (input.id === "request") {
      setRequest(input.value)
    } else if (input.id === "requestMethod") {
      setRequestMethod(input.value)
    } else if (input.id === "key") {
      setTestcase({...testcase, key: input.value})
    } else if (input.id === "value") {
      setTestcase({...testcase, value: input.value})
    }
    console.log(currentUser,password)
    console.log(testcase, request)
  }

  let formData = new FormData();
  let myHeaders = new Headers();

  async function apiRequest(options,query) {
    let requestStr = "http://localhost:3000" + request + query;
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
    await followUpAPIs(data)
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

    if (currentUser) formData.append('user_id',currentUser);
    if (request.includes("/api/sessions")) formData.append('username',currentUser);
    //myHeaders.append("ad_session_token",adSessionToken);
    if (password) formData.append('password',password);
    // This is where you will format the testcase values
    // let testcaseInput = JSON.stringify({action: "add",focusRequest: testcase.value })
    let testcaseInput;

    let roomPeerParam = new Set(["rooms","peers"]);
    let requestParam = new Set(["requests"])

    if (roomPeerParam.has(testcase.key)) {
      let [action, peerFocus] = testcase.value.split("-");
      testcaseInput = {action: action, peerFocus: peerFocus };
      testcaseInput = JSON.stringify(testcaseInput)
    } else if (requestParam.has(testcase.key)) {
      let [action, requestFocus] = testcase.value.split("-");
      testcaseInput = {
        action: action,
        requestFocus: requestFocus
      };
      testcaseInput = JSON.stringify(testcaseInput)
    } else {
      testcaseInput = testcase.value
    }

    let query = ""
    // query += "session_token=1"
    if (query) query = "?" + query

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod === "DELETE") {
      options.body = formData
      if (testcase.key) formData.append(testcase.key,testcaseInput)
      //formData.append("session_token","DIDA4gm9QYmulrzs29CPTA")
      // formData.append("new_password","password")
      // formData.append("password_digest",'password')
      // formData.append("genre_preference","Shounen")
      // formData.append("go_to_motto","Where is Ichigo?")
      // let peerRequest = {action: "add", requestFocus:"Jarret"}
      // formData.append("requests",JSON.stringify(peerRequest))
      // let peerAdd = {action: "add", peerFocus: "Jarret"}
      // formData.append("peers",JSON.stringify(peerAdd))
    }

    apiRequest(options,query)
    console.log("Submit has been handled")
  }

  async function followUpAPIs(data) {
    if (data.status === "failed") return new Promise(resolve => {
      resolve({status: "N/A", message: "follow up API was not utilized"})
    })

    if (data.notifications || data.notification_count) {
      const notificationsEndpoint = await notificationRequests(data)
      const output = await notificationsCall(notificationsEndpoint,data)
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
    } else if (user !== actionUser) {
        endpoints["POST"] = {
          endpoint: `/api/notifications/`,
          params: ["notification", data]
        }
      } else if (user !== actionUser) {
        endpoints["PATCH"] = {
          endpoint: `/api/notifications/${user}`,
          params: []
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


  return (
    <div className="App" id="container">
      <div className='testForm' id='userTableForm'>
      <form className="credentials" onChange={handleChange}>
        <label htmlFor="currentUser">Current User:</label>
        <input type="text" id="currentUser" name="currentUser" value={currentUser}></input>
        <label htmlFor="password">Password:</label>
        <input type="text" id="password" name="password" value={password}/>

        <div id="testcaseLabels">
          <label htmlFor="key">Key:</label>
          <label htmlFor="value">Value:</label>
        </div>

        <div id="testcaseInputs">
          <input type="text" id="key" name="key" value={testcase.key}/>
          <input type="text" id="value" name="value" value={testcase.value}/>
        </div>

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



export default UserTable
