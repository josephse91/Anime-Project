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
  let myHeaders = new Headers();

  async function apiRequest(searchParam,options,options2) {
    let requestStr = "http://localhost:3000/" + request + searchParam, requestStr2;
    let apiRequest = await fetch(requestStr, options), apiRequest2
    let data = await apiRequest.json(), data2
    console.log(requestStr, data)

    let requestMethod2 = options2.method

    async function addReviewsToRooms(data) {
      if (data.status === "complete" && requestMethod2 === "PATCH") {
        let review = data["review"]
        console.log(review)
        requestStr2 = `http://localhost:3000/api/reviews/${review.show}/rooms`+ searchParam;
        return apiRequest2 = await fetch(requestStr2, options2)
      }
      return new Promise(resolve => resolve(JSON.stringify({status: "failed"})))
    }

    setResponse(data)

    apiRequest2 = await addReviewsToRooms(data)
    data2 = await apiRequest2.json()
    console.log(requestStr2, data2)
  }
  
  let sendRequest = function(e) {
    e.preventDefault;

    const options = {
      headers: myHeaders,
      method: requestMethod
    }

    const options2 = {
      headers: myHeaders,
      method: "PATCH"
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
      formData.append("rating",66)
      formData.append("amount_watched","season 1")
      // // formData.append("highlighted_points",'[]')
      formData.append("overall_review","This anime was trash")
      // formData.append("referral_id","Jarret")
      formData.append("watch_priority",-1)
      // let likesAction = {user: user, net: 0, target: 1}
      // formData.append("likes",JSON.stringify(likesAction))

      if (testcase.key) formData.append(testcase.key,testcaseInputString);
    }

    apiRequest(search,options,options2)
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
