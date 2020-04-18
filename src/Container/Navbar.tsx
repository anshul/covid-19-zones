import React, { useState, useEffect } from 'react'
import { BottomNavigation, BottomNavigationAction, makeStyles, createStyles, Theme } from '@material-ui/core'
import { LocationOnTwoTone, LocalOfferTwoTone, HelpTwoTone, HomeTwoTone } from '@material-ui/icons'
import clsx from 'clsx'
import { history } from '../history'

interface Props {
  path: string
}

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      position: 'sticky',
      top: 0,
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

const Navbar: React.FC<Props> = ({ path }) => {
  const classes = useStyles()
  const [current, setCurrent] = useState(path)

  useEffect(() => {
    setCurrent(path)
  }, [path, setCurrent])

  return (
    <div>
      {/* {!isSmallScreen && (
        <div className={classes.logo}>
          <BugReport fontSize='large' />
        </div>
      )} */}
      <BottomNavigation
        value={current}
        onChange={(_, newValue: string) => {
          setCurrent(newValue)
          history.push(`/${newValue}`)
        }}
        className={classes.root}
      // className={clsx(isSmallScreen ? classes.rootSmallScreen : classes.root)}
      >
        <BottomNavigationAction
          classes={{ root: classes.action, selected: classes.selected }}
          label='Home'
          value='home'
          icon={<HomeTwoTone />}
        />
        <BottomNavigationAction
          classes={{ root: classes.action, selected: classes.selected }}
          label='Zones'
          value='zones'
          icon={<LocationOnTwoTone />}
        />
        <BottomNavigationAction
          classes={{ root: classes.action, selected: classes.selected }}
          label='Tags'
          value='tags'
          icon={<LocalOfferTwoTone />}
        />
        <BottomNavigationAction
          classes={{ root: classes.action, selected: classes.selected }}
          label='Help'
          value='help'
          icon={<HelpTwoTone />}
        />
      </BottomNavigation>
    </div>
  )
}

export default Navbar
