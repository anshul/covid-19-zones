import React from 'react'

import { Route, Switch, Redirect } from 'react-router-dom'
import Home from '../containers/Home'

const Routes: React.FC = () => {
  return (
    <Switch>
      <Route path='/home' component={Home} />
      <Route exact path='/' component={Home} />
      <Redirect exact from='/' to='/home' />
    </Switch>
  )
}

export default Routes
