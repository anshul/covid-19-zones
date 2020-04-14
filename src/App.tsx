import React from 'react'
import './App.scss'
import { ThemeProvider } from '@material-ui/core'
import { baseTheme } from './theme'
import { Router } from 'react-router-dom'
import { history } from './history'
import Container from './Container/Container'
import { SWRConfig } from 'swr'

const App = () => {
  return (
    <SWRConfig
      value={{
        fetcher: (url, ...args) => fetch(url, ...args).then((res) => res.json()),
      }}
    >
      <ThemeProvider theme={baseTheme}>
        <Router history={history}>
          <Container />
        </Router>
      </ThemeProvider>
    </SWRConfig>
  )
}

export default App
