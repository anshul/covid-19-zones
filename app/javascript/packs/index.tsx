import React from 'react'
import ReactDOM from 'react-dom'
import App from '../../../src/App'
import '../../../src/index.css'
import * as serviceWorker from '../../../src/serviceWorker'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<App />, document.getElementById('root'))
})

serviceWorker.unregister()
