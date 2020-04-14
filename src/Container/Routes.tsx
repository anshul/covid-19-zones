import React from 'react'

import { Route, Switch, Redirect } from 'react-router-dom'
import Home from '../containers/Home'
import ZonePage from '../components/ZonePage'

const Routes: React.FC = () => {
  return (
    <Switch>
      {/* <Route path='/home' component={Home} /> */}
      {/* <Route exact path='/' component={Home} /> */}
      <Route path='/zone/:slug*' component={ZonePage} />
      <Redirect from='/' to='/zone/india/maharashtra/mumbai' />
    </Switch>
  )
}

export default Routes
