import React from 'react'
import ReactDOM from 'react-dom/client'
import UserTable from './testing/user_api/UserTable'
import ReviewTable from './testing/user_api/ReviewsTable'
import ReviewCommentsTable from './testing/user_api/ReviewsCommentsTable'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ReviewCommentsTable />
  </React.StrictMode>
)
