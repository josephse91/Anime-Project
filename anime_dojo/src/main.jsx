import React from 'react'
import ReactDOM from 'react-dom/client'
import UserTable from './testing/user_api/UserTable'
import ReviewTable from './testing/user_api/ReviewsTable'
import ReviewCommentsTable from './testing/user_api/ReviewsCommentsTable'
import RoomTable from './testing/user_api/RoomTable'
import ForumsTable from './testing/user_api/ForumsTable'
import ForumCommentsTable from './testing/user_api/ForumCommentsTable'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <RoomTable />
  </React.StrictMode>
)
