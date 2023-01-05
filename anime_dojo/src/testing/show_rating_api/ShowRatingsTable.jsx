import { useState } from 'react';


function ShowRatingsTable() {
  const [room,setUser] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);
  const [testcase,setTestcase] = useState({});

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if(input.id === "room") {
      setUser(input.value)
    } else if (input.id === "request") {
      setRequest(input.value)
    } else if (input.id === "requestMethod") {
      setRequestMethod(input.value)
    } else if (input.id === "showKey") {
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
    let requestStr = "http://localhost:3001/" + request + searchParam, requestStr2;
    let apiRequest = await fetch(requestStr, options), apiRequest2
    let data = await apiRequest.json(), data2
    console.log(requestStr, data)
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
    if (room) {
      search += "?room_id=" + room;
      // search += "&in_network=true";
      // let range = JSON.stringify({"top": 95, "bottom":80})
      // search += `&range=${range}`;
    }

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod == "DELETE") {
      options.body = formData;

      const user = {username: "Allia"}
      const review1 = {
        user: "Serge", 
        show: "Code Geass 3", 
        rating: 66
      }

      const review2 = {
        user: "Allia", 
        show: "Naruto", 
        rating: 85
      }

      const rooms = [
        {id: 2, room_name: "Planet Vegeta"},
        {id: 3, room_name: "Bedstuy"}
      ]

      const action = "delete review"

      const add_shows = [review1,review2]

      const data = {
        review: review1,
        reviews: add_shows,
        rooms: rooms,
        action: action
      }

      formData.append("user", user.username)
      formData.append("review", JSON.stringify(data.review))
      formData.append("rooms", JSON.stringify(data.rooms))
      formData.append("show_action", data.action)
      // formData.append("reviews", JSON.stringify(data.reviews))

      if (testcase.key) formData.append(testcase.key,testcaseInputString);
    }

    apiRequest(search,options)
    console.log("Submit has been handled")
  }

  return (
    <div className="App" id="container">
      <div className='testForm' id='reviewTableForm'>
      <form className="credentials" onChange={handleChange}>
        <label htmlFor="room">Room:</label>
        <input type="text" id="room" name="room" value={room}/>
        <label htmlFor="reviewKey">Key:</label>
        <input type="text" id="showKey" name="showKey" value={testcase.key}/>
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

export default ShowRatingsTable
