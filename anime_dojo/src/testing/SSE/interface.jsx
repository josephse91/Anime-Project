import "./SSE CSS/main.css"
import { useState } from "react"

export default function Interface() {
    const [username, setUsername] = useState("");
    const [actionUser, setActionUser] = useState("");

    return(
        <div className="interface">
            <UserSelect userType="user" username={username} setUsername={setUsername} />
            <div className="userData">
                <div className="box" id="one"></div>
                <div className="box" id="two"></div>
                <div className="box" id="three"></div>
                <div className="box" id="four"></div>
                <div className="box" id="five">
                    <div className="accordian" id="first"></div>
                    <div className="accordian" id="second"></div>
                    <div className="accordian" id="third"></div>
                </div>
            </div>
            <UserSelect userType="actionUser" username={actionUser} setUsername={setActionUser} />
            <div className="actionUserBox"></div> 
        </div>
    )
}

function UserSelect(props) {
    const userType = props.userType;
    const username = props.username;
    const setUsername = props.setUsername;

    const userID = userType == "user" ? "User" : "ActionUser";

    const handleChange = function(e) {
        e.preventDefault();

        setUsername(e.target.value)
        console.log(username)
    }

    return(
        <div className="userEntry" id={userID}>
            <p>{userID}: </p>
            <input className="userInputField" type="text" onChange={handleChange}/>
        </div>
    )
}