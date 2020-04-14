import React from 'react'
import './App.scss'
import { ThemeProvider } from '@material-ui/core'
import { baseTheme } from './theme'
import Routes from './Container/Routes'
import { Router } from 'react-router-dom'
import { history } from './history'

const App = () => {
  return (
    <ThemeProvider theme={baseTheme}>
      <Router history={history}>
        <Routes />
      </Router>
    </ThemeProvider>
  )
}

export default App
