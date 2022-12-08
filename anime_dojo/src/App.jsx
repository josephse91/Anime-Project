import { useState } from 'react';
import './App.css';


function App() {
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

  async function apiRequest(options) {
    let requestStr = "http://localhost:3000" + request;
    let apiRequest = await fetch(requestStr, options)
    let data = await apiRequest.json()
    setResponse(data)
    console.log(requestStr,data)
    addElement(data)
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
      testcaseInput = {action: "add", focusPeer: testcase.value };
    } else if (requestParam.has(testcase.key)) {
      testcaseInput = {
        action: "add",
        requestType: "room", 
        focusRequest: testcase.value,
        val: "peer4" 
      };
    } else {
      testcaseInput = testcase.value
    }

    let testcaseInputString = JSON.stringify(testcaseInput)

    if (requestMethod === "POST" || requestMethod === "PATCH") {
      options.body = formData
      formData.append(testcase.key,testcaseInputString)
    }

    apiRequest(options)
    console.log("Submit has been handled")
  }

  function addElement(data) {
    // create a new div element
    const req = document.createElement("div");
  
    // and give it some content
    req.innerHTML = JSON.stringify(data)
  
    // add the newly created element and its content into the DOM
    const lastChild = document.getElementById("container");
    lastChild.append(req)
  }

  return (
    <div className="App" id="container">
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
  )
}



export default App
