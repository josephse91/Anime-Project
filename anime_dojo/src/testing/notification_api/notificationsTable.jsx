import { useState } from 'react';


function NotificationsTable() {
  const [room,setUser] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);
  const [testcase,setTestcase] = useState({});

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if (input.id === "request") {
      setRequest(input.value)
    } else if (input.id === "requestMethod") {
      setRequestMethod(input.value)
    }
  }

  let formData = new FormData();
  let myHeaders = new Headers();

  async function apiRequest(searchParam,options) {
    let requestStr = "http://localhost:3003/" + request + searchParam;
    let apiRequest = await fetch(requestStr, options)
    let data = await apiRequest.json()
    console.log(requestStr, data)
  }
  
  let sendRequest = function(e) {
    e.preventDefault;

    const options = {
      headers: myHeaders,
      method: requestMethod
    }
 
    let search = ""

    if (requestMethod === "POST" || requestMethod === "PATCH") {
      options.body = formData;

      const user = {username: "Allia"}
      const notification1 = {
        id: 13,
        target_item: "Review",
        event_action: "like",
        action_user: "Aviel",
        recipient: "Jarret",
        show: "Jujutsu Kaisen"
      }

      const notification2 = {
        id: 13,
        target_item: "Review",
        event_action: "like",
        action_user: "Serge",
        recipient: "Jarret",
        show: "Jujutsu Kaisen"
      }

      const notification3 = {
        id: 13,
        target_item: "Review",
        event_action: "like",
        action_user: "Aldane",
        recipient: "Jarret",
        show: "Jujutsu Kaisen"
      }

      const notification4 = {
        id: 13,
        target_item: "Review",
        event_action: "like",
        action_user: "David",
        recipient: "Jarret",
        show: "Jujutsu Kaisen"
      }

      formData.append("notification", JSON.stringify(notification1))
      // formData.append("notification", JSON.stringify(notification2))
      // formData.append("notification", JSON.stringify(notification3))
      // formData.append("notification", JSON.stringify(notification4))
    }

    apiRequest(search,options)
    console.log("Submit has been handled")
  }

  return (
    <div className="App" id="container">
      <div className='testForm' id='reviewTableForm'>
      <form className="credentials" onChange={handleChange}>
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

export default NotificationsTable
