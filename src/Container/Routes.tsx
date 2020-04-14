import React from 'react'

import { Route, Switch } from 'react-router-dom'
import Container from './Container'
import ZonePage from '../components/ZonePage'

const Routes: React.FC = () => {
  return (
    <Switch>
      <Route exact path='/' component={Container} />
      <Route path='/zone/:slug*' component={ZonePage} />
    </Switch>
  )
}

export default Routes
