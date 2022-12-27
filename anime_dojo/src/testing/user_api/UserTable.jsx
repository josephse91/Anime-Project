import { useState } from 'react';
import './UserTable.css';


function UserTable() {
  const [username, setUsername] = useState("");
  const [password,setPassword] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);
  const [testcase,setTestcase] = useState({});

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if (input.id ==="username") {
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
    console.log(username,password)
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
  }
  
  let sendRequest = function(e) {
    e.preventDefault;

    const options = {
      headers: myHeaders,
      method: requestMethod
    }

    if (username) formData.append('username',username);
    if (password) formData.append('password',password);

    // This is where you will format the testcase values
    // let testcaseInput = JSON.stringify({action: "add",focusRequest: testcase.value })
    let testcaseInput;

    let roomPeerParam = new Set(["rooms","peers"]);
    let requestParam = new Set(["requests"])

    if (roomPeerParam.has(testcase.key)) {
      testcaseInput = {action: "add", peerFocus: testcase.value };
      testcaseInput = JSON.stringify(testcaseInput)
    } else if (requestParam.has(testcase.key)) {
      testcaseInput = {
        action: "add",
        requestFocus: testcase.value
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
      // formData.append("new_username","Aldane1")
      // formData.append("new_password","password")
      // formData.append("password_digest",'password')
      // formData.append("genre_preference","Isakai")
      // formData.append("go_to_motto","Stay Chill Homie")
      // let peerRequest = {action: "add", requestFocus:"Allia"}
      // formData.append("requests",JSON.stringify(peerRequest))
      let peerAdd = {action: "add", peerFocus: "Allia"}
      formData.append("peers",JSON.stringify(peerAdd))
    }

    apiRequest(options,query)
    console.log("Submit has been handled")
  }


  return (
    <div className="App" id="container">
      <div className='testForm' id='userTableForm'>
      <form className="credentials" onChange={handleChange}>
        <label htmlFor="username">Username:</label>
        <input type="text" id="username" name="username" value={username}></input>
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
