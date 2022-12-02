import { useState } from 'react'
import './App.css'

function App() {
  const [username, setUsername] = useState("");
  const [password,setPassword] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null)

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if (input.id ==="username") {
      setUsername(input.value)
    } else if (input.id === "password") {
      setPassword(input.value)
    } else if (input.id === "request") {
      setRequest(input.value)
    }
    console.log(username,password,request)
  }

  async function apiRequest() {
    let apiRequest = await fetch("https://www.boredapi.com/api/activity")
    let data = await apiRequest.json()
    setResponse(data)
    addElement(data)
    console.log("response: ",response)
  }
  
  let sendRequest = function(e) {
    e.preventDefault;
    apiRequest()
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
        <label htmlFor="request">Request:</label>
        <input type="text" id="request" name="request" value={request}/>
      </form>
      <button className='request' id="requestButton" onClick={sendRequest}>Send</button>
    </div>
  )
}

export default App
