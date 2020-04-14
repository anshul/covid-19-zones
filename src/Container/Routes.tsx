import React from 'react'

import { Route, Switch } from 'react-router-dom'
import Container from './Container'

const Routes: React.FC = () => {
  return (
    <Switch>
      <Route exact path='/' component={Container} />
    </Switch>
  )
}

export default Routes
