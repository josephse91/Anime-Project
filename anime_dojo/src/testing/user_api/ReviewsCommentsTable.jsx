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
    let testcaseInputString = JSON.stringify(testcaseInput);

    let search = "?"
    let user = "Serge"
    let comment = "I love very good things"

      // search += "review_id=" + review;
      // search += `&comment=${comment}`;
      search += `&user_id=${user}`;
      // search += "&comment_type=reply";
      // search += "&parent=" + 20;
      // search += "&top_comment=" + 16;

    if (search.length === 1) search = ""

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod == "DELETE") {
      options.body = formData;
      let likesAction = {user: user, net: 1, target: 0}
      formData.append("likes",JSON.stringify(likesAction))
      if (testcase.key) formData.append(testcase.key,testcaseInputString);
    }

    apiRequest(options,search)
    console.log("Submit has been handled")
  }

  return (
    <div className="App" id="container">
      <div className='testForm' id='reviewCommentsTableForm'>
      <form className="credentials" onChange={handleChange}>
        <label htmlFor="reviewCommentsReview">Review:</label>
        <input type="text" id="reviewCommentsReview" name="reviewCommentsReview" value={review}/>
        <label htmlFor="reviewKey">Key:</label>
        <input type="text" id="reviewCommentsKey" name="reviewCommentsKey" value={testcase.key}/>
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

export default ReviewCommentsTable
