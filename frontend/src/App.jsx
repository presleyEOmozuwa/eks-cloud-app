import { useState } from 'react'
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { routeData } from './routes/routes';
import './App.css'


function App() {
  const router = createBrowserRouter(routeData());
  return (
    <>
      <RouterProvider router={router}/>
    </>
  )
}

export default App
