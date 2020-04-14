import React from 'react'
import './App.scss'
import { ThemeProvider } from '@material-ui/core'
import { baseTheme } from './theme'
import Routes from './Container/Routes'
import { Router } from 'react-router-dom'
import { history } from './history'
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
          <Routes />
        </Router>
      </ThemeProvider>
    </SWRConfig>
  )
}

export default App
