import React from 'react'
import './App.scss'
import { ThemeProvider } from '@material-ui/core'
import { baseTheme } from './theme'
import { Router } from 'react-router-dom'
import { history } from './history'
import Container from './Container/Container'

const App = () => {
  return (
    <ThemeProvider theme={baseTheme}>
      <Router history={history}>
        <Container />
      </Router>
    </ThemeProvider>
  )
}

export default App
