import { useState } from 'react';


function ForumCommentsTable() {
  const [forum, setForum] = useState("");
  const [commentOwner,setCommentOwner] = useState("");
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);
  const [testcase,setTestcase] = useState({});

  let handleChange = function(e) {
    e.preventDefault;

    let input = e.target
    if (input.id ==="forum") {
      setForum(input.value)
    } else if (input.id === "comment_owner") {
      setCommentOwner(input.value)
    } else if (input.id === "request") {
      setRequest(input.value)
    } else if (input.id === "requestMethod") {
      setRequestMethod(input.value)
    } else if (input.id === "key") {
      setTestcase({...testcase, key: input.value})
    } else if (input.id === "value") {
      setTestcase({...testcase, value: input.value})
    }
    console.log(forum,commentOwner)
    console.log(testcase, request)
  }

  let formData = new FormData();
  let myHeaders = new Headers();

  async function apiRequest(options,query = "") {
    let queryInput = query;
    let requestStr = "http://localhost:3000" + request + queryInput;
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

    let query = ""
    let user = "Jarret" 

    let queryParams = [];
    if (forum) queryParams.push(`forum_id=${Number(forum)}`)
    if (commentOwner) queryParams.push(`comment_owner=${commentOwner}`)
    if (user) queryParams.push(`current_user=${user}`)
    if (queryParams.length) {
      query += "?"
      queryParams.forEach((param,idx) => {
        if (idx > 0) query += "&"
        query += param
      })
    }

    // This is where you will format the testcase values
    // let testcaseInput = JSON.stringify({action: "add",focusRequest: testcase.value })
    let testcaseInput = testcase.value
    // let testcaseInputString = JSON.stringify(testcaseInput)
    let testcaseInputString = testcaseInput;

    if (requestMethod === "POST" || requestMethod === "PATCH" || requestMethod === "DELETE") {
      options.body = formData
      // formData.append("comment", "Naruto original is the best answer. Shippuden has holes in it") // Mandatory
      // formData.append("parent", 6) // Mandatory

      let votesAction = {user: user, net: 0, target: 1}
      formData.append("votes",JSON.stringify(votesAction))

      // formData.append("level",0) // Not Required
      // formData.append("children", {}) // Not Required
      // formData.append("top_comment",0) // Not required
      if (testcase.key) formData.append(testcase.key,testcaseInputString)
    }

    apiRequest(options,query)
    console.log("Submit has been handled")
  }

  return (
    <div className="App" id="container">
      <div className='testForm' id='userTableForm'>
      <form className="credentials" onChange={handleChange}>
        <label htmlFor="forum">Forum:</label>
        <input type="text" id="forum" name="forum" value={forum}></input>
        <label htmlFor="comment_owner">Comment Owner:</label>
        <input type="text" id="comment_owner" name="comment_owner" value={commentOwner}/>

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



export default ForumCommentsTable
