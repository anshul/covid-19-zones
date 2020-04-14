import React, { useState } from 'react'
import { BottomNavigation, BottomNavigationAction, makeStyles, createStyles, Theme } from '@material-ui/core'
import { Home, LocationOn, LocalOffer, Help, BugReport } from '@material-ui/icons'
import clsx from 'clsx'
import { useScreen } from '../hooks/useScreen'

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      display: 'block',
      width: '100px',
      height: 'calc(100vh - 72px)',
      backgroundColor: theme.palette.background.default,
      textAlign: 'center',
    },
    rootSmallScreen: {
      position: 'fixed',
      bottom: 0,
      width: '100%',
      backgroundColor: theme.palette.background.default,
    },
    logo: {
      width: '100px',
      height: '72px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    },
    action: {
      width: '100%',
      padding: '24px 12px',
    },
    selected: {
      fontWeight: 700,
      fontSize: '16px',
    },
  })
)

const Navbar: React.FC = () => {
  const classes = useStyles()
  const [current, setCurrent] = useState('home')

  const { isSmallScreen } = useScreen()

  return (
    <div>
      {!isSmallScreen && (
        <div className={classes.logo}>
          <BugReport fontSize='large' />
        </div>
      )}
      <BottomNavigation
        value={current}
        onChange={(_, newValue: string) => setCurrent(newValue)}
        className={clsx(isSmallScreen ? classes.rootSmallScreen : classes.root)}
      >
        <BottomNavigationAction classes={{ root: classes.action, selected: classes.selected }} label='Home' value='home' icon={<Home />} />
        <BottomNavigationAction
          classes={{ root: classes.action, selected: classes.selected }}
          label='Zones'
          value='zones'
          icon={<LocationOn />}
        />
        <BottomNavigationAction
          classes={{ root: classes.action, selected: classes.selected }}
          label='Tags'
          value='tags'
          icon={<LocalOffer />}
        />
        <BottomNavigationAction classes={{ root: classes.action, selected: classes.selected }} label='Help' value='help' icon={<Help />} />
      </BottomNavigation>
    </div>
  )
}

export default Navbar
