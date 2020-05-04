import React from 'react'
import { RouteComponentProps } from 'react-router'
import ZonePageRoot from './ZonePageRoot'
import { history } from '../../history'

const ZonePage: React.FC<RouteComponentProps<{ code: string }>> = ({ location, match }) => {
  const gotoParentZone = () => {
    history.push(`/zones/${match.params.code.split('/').slice(0, -1).join('/')}`)
  }

  const gotoZone = (code: string) => {
    history.push(`/zones/${code}`)
  }

  return <ZonePageRoot code={match.params.code} gotoZone={gotoZone} gotoParentZone={gotoParentZone} />
}

export default ZonePage
