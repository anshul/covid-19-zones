import React from 'react'

import { Route, Switch, Redirect } from 'react-router-dom'
import Home from '../containers/Home'
import ZonePage from '../components/ZonePage'

const Routes: React.FC = () => {
  return (
    <Switch>
      <Route path='/home' component={Home} />
      <Route exact path='/' component={Home} />
      <Redirect exact from='/' to='/home' />
      <Route path='/zones/:slug*' component={ZonePage} />
    </Switch>
  )
}

export default Routes
