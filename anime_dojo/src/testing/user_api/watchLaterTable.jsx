import { useState } from 'react';


function WatchLaterTable() {
  const [request,setRequest] = useState("");
  const [response,setResponse] = useState(null);
  const [requestMethod,setRequestMethod] = useState(null);

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
  let formData2 = new FormData();
  let myHeaders = new Headers();

  function addToFormData(watchLaterOrRec) {
    const user_id = watchLaterOrRec.user_id;
    const show = watchLaterOrRec.show;
    const referral_id = watchLaterOrRec.referral_id;

    formData.append("user_id", user_id);
    formData.append("show",show);
    if (referral_id) formData.append("referral_id",referral_id)

  }

  async function apiRequest(searchParam,options) {
    let requestStr = "http://localhost:3000/" + request + searchParam;
    let apiRequest = await fetch(requestStr, options)
    let data = await apiRequest.json()
    console.log(requestStr, data)

    let followUp = await followUpAPIs(data,searchParam)
  }

  async function followUpAPIs(data,searchParam) {
    if (data.status === "failed") return new Promise(resolve => {
      resolve({status: "N/A", message: "follow up API was not utilized"})
    })

    if (data.notifications || data.notification_count) {
      const notifications = await notificationsCall(data)
    }
  }

  async function notificationsCall(watchOrRecData) {
    const options2 = {
      headers: myHeaders,
      method: "POST"
    }
    
    let requestStr = "http://localhost:3003";

    let formData2 = new FormData()
    options2.body = formData2

    let notifications = watchOrRecData.notifications
    let notificationData = [];

    console.log(watchOrRecData,notifications)

    for (let notification of notifications) {
      let param = "notification"
      let value = notification
      formData2.append(param,JSON.stringify(value))

      requestStr += "/api/notifications/"
      let apiRequest = await fetch(requestStr, options2)
      let data = await apiRequest.json()
      console.log(requestStr, data)
      notificationData.push(data) 
    }

    return new Promise(resolve => resolve({status: "success", data: notificationData}))
  }
  
  let sendRequest = function(e) {
    e.preventDefault;

    const options = {
      headers: myHeaders,
      method: requestMethod
    }
 
    let search = ""

    if (requestMethod === "POST" || requestMethod === "DELETE") {
      options.body = formData;

      const user = {username: "Allia"}
      const watchLater1 = {
        user_id: "Serge",
        show: "Vinland Saga"
      }

      const watchLater2 = {
        user_id: "Aldane",
        show: "Code Geass",
      }

      const watchLater3 = {
        user_id: "Jarret",
        show: "One Piece"
      }

      const watchLater4 = {
        user_id: "Serge",
        show: "Black Clover"
      }

      const watchLater5 = {
        user_id: "Aviel",
        show: "Naruto"
      }

      const watchLater6 = {
        user_id: "Jarret",
        show: "Hellsing"
      }

      const rec1 = {
        user_id: "David",
        show: "Bleach",
        referral_id: "Aldane"
      }

      const rec2 = {
        user_id: "Serge",
        show: "Sailor Moon",
        referral_id: "Allia"
      }

      // formData.append("show","Naruto")
      // addToFormData(watchLater1)
      // addToFormData(watchLater2)
      // addToFormData(watchLater3)
      // addToFormData(watchLater4)
      // addToFormData(watchLater5)
      // addToFormData(watchLater6)
      // addToFormData(rec1)
      // addToFormData(rec2)
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

export default WatchLaterTable
