import React from 'react'
import { Typography, makeStyles, Theme, createStyles } from '@material-ui/core'
import Navbar from './Navbar'
import clsx from 'clsx'
import { useScreen } from '../hooks/useScreen'
import Routes from './Routes'
import { Route } from 'react-router-dom'

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      width: '100%',
      display: 'flex',
      backgroundColor: theme.palette.background.default,
      color: theme.palette.text.primary,
    },
    rootSmallScreen: {
      width: '100% !important',
      height: '100%',
      backgroundColor: theme.palette.background.default,
      color: theme.palette.text.primary,
    },
    appbar: {
      width: 'calc(100% - 24px)',
      height: '72px',
      padding: '0 12px',
      backgroundColor: theme.palette.background.default,
      display: 'flex',
      alignItems: 'center',
    },
    content: {
      height: '100vh',
      width: '100%',
      overflow: 'auto',
      borderRadius: '12px',
    },
  })
)

const Container: React.FC = () => {
  const classes = useStyles()

  const { isSmallScreen } = useScreen()

  const renderNavBar = () => {
    return (
      <Route
        path='*'
        render={({ history }) => {
          const path = history.location.pathname
          return <Navbar path={path.replace('/', '')} />
        }}
      />
    )
  }

  return (
    <div className={clsx(isSmallScreen ? classes.rootSmallScreen : classes.root)}>
      {!isSmallScreen && renderNavBar()}
      <div className={classes.content}>
        <div className={classes.appbar}>
          <Typography variant='h6'>COVID19ZONES</Typography>
        </div>
        <Routes />
      </div>
      {isSmallScreen && renderNavBar()}
    </div>
  )
}

export default Container
