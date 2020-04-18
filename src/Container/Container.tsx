import React from 'react'
import { Typography, makeStyles, Theme, createStyles } from '@material-ui/core'
import Routes from './Routes'

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

  // const renderNavBar = () => {
  //   return (
  //     <Route
  //       path='*'
  //       render={({ history }) => {
  //         const path = history.location.pathname
  //         return <Navbar path={path.replace('/', '')} />
  //       }}
  //     />
  //   )
  // }

  return (
    <div className={classes.root}>
      <div className={classes.content}>
        <div className={classes.appbar}>
          <Typography variant='h6'>COVID19ZONES</Typography>
        </div>
        <Routes />
      </div>
    </div>
  )
}

export default Container
