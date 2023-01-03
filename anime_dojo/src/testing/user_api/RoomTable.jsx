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
    let data = await apiRequest.json(), data2
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
        data2 = await apiRequest2.json()
        console.log(apiRequest2, data2, options2)
      }
    }

    apiRequest2 = await addReviewsToRooms(data)
  }
  
  let sendRequest = function(e) {
    e.preventDefault;

    const options = {
      headers: myHeaders,
      method: requestMethod
    }

    if (room) formData.append('room_id',room);

    // This is where you will format the testcase values
    // let testcaseInput = JSON.stringify({action: "add",focusRequest: testcase.value })
    let testcaseInput = testcase.value
    // let testcaseInputString = JSON.stringify(testcaseInput)
    let testcaseInputString = testcaseInput;

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod === "DELETE") {
      options.body = formData
      // formData.append("request","Markus Borer LLD")
      // formData.append("submitted_key", "dOHVqfOHP8729TbRgR3Klg")
      // formData.append("make_entry_key", true)
      // formData.append("user_remove","David")
      // formData.append(testcase.key,testcaseInputString)
    }

    apiRequest(options,search)
    console.log("Submit has been handled")
  }

  return (
    <div className="App" id="container">
      <div className='testForm' id='userTableForm'>
      <form className="credentials" onChange={handleChange}>
        <label htmlFor="room">Room:</label>
        <input type="text" id="room" name="room" value={room}></input>
        <label htmlFor="search">Search:</label>
        <input type="text" id="search" name="search" value={search}/>

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



export default RoomTable
