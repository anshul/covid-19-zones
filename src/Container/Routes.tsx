import React from 'react'

import { Route, Switch, Redirect } from 'react-router-dom'
// import Home from '../containers/Home'
import ZonePage from '../components/ZonePage'

const Routes: React.FC = () => {
  return (
    <Switch>
      <Redirect from='/zones' exact to='/zones/in' />
      <Route path='/zones/:code*' component={ZonePage} />
      <Redirect from='/' to='/zones/in' />
    </Switch>
  )
}

export default Routes
