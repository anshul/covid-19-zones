import React from 'react'

import { Route, Switch, Redirect } from 'react-router-dom'
// import Home from '../containers/Home'
import ZonePage from '../components/ZonePage'

const Routes: React.FC = () => {
  return (
    <Switch>
      {/* <Route path='/home' component={Home} /> */}
      {/* <Route exact path='/' component={Home} /> */}
      <Route path='/zones/:slug*' component={ZonePage} />
      <Redirect from='/' to='/zones/in' />
    </Switch>
  )
}

export default Routes
