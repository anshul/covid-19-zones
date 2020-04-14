import React from 'react'
import { RouteComponentProps } from 'react-router'
import ZonePageRoot from './ZonePageRoot'
import { history } from '../../history'

const ZonePage: React.FC<RouteComponentProps<{ slug: string }>> = ({ location, match }) => {
  const gotoParentZone = () => {
    history.push(`/zone/${match.params.slug.split('/').slice(0, -1).join('/')}`)
  }

  const gotoZone = (slug: string) => {
    history.push(`/zone/${slug}`)
  }

  return <ZonePageRoot slug={match.params.slug} gotoZone={gotoZone} gotoParentZone={gotoParentZone} />
}

export default ZonePage
