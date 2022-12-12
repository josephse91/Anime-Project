import React from 'react'
import ReactDOM from 'react-dom/client'
import UserTable from './UserTable'
import ReviewTable from './ReviewsTable'
import ReviewCommentsTable from './ReviewsCommentsTable'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ReviewTable />
  </React.StrictMode>
)
