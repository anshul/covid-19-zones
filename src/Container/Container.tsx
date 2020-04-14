import React from 'react'
import { Typography, makeStyles, Theme, createStyles, Grid, Card, CardContent } from '@material-ui/core'
import BarChart from '../components/Charts/BarChart'
import Navbar from './Navbar'
import clsx from 'clsx'
import { useScreen } from '../hooks/useScreen'

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
      overflow: 'auto',
      borderRadius: '12px',
      paddingBottom: '60px',
    },
    gridContainer: {
      width: '100%',
      margin: 0,
    },
    sidebar: {
      paddingRight: theme.spacing(1),
    },
    sidebarItem: {
      borderRadius: theme.spacing(1),
    },
    sidebarNestedItem: {
      paddingLeft: theme.spacing(4),
    },
  })
)

const Container: React.FC = () => {
  const classes = useStyles()

  const { isSmallScreen } = useScreen()

  return (
    <div className={clsx(isSmallScreen ? classes.rootSmallScreen : classes.root)}>
      {!isSmallScreen && <Navbar />}
      <div className={classes.content}>
        <div className={classes.appbar}>
          <Typography variant='h6'>COVID19ZONES</Typography>
        </div>
        <Grid className={classes.gridContainer} container spacing={1}>
          <Grid container item xs={12} sm={12} md={8} xl={9} spacing={1}>
            <Grid item md={6} xl={3} xs={12}>
              <Card>
                <CardContent>
                  <Typography variant='subtitle1'>Total Cases</Typography>
                  <Typography variant='h5'>241,152,102</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item md={6} xl={3} xs={12}>
              <Card>
                <CardContent>
                  <Typography variant='subtitle1'>Recovered</Typography>
                  <Typography variant='h5'>241,152,102</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item md={6} xl={3} xs={12}>
              <Card>
                <CardContent>
                  <Typography variant='subtitle1'>Active Cases</Typography>
                  <Typography variant='h5'>241,152,102</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item md={6} xl={3} xs={12}>
              <Card>
                <CardContent>
                  <Typography variant='subtitle1'>Total Death</Typography>
                  <Typography variant='h5'>241,152,102</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item md={12} xl={12} xs={12}>
              <Card style={{ height: '100%', minHeight: '250px' }}>
                <BarChart />
              </Card>
            </Grid>
          </Grid>
          <Grid container item spacing={1} xs={12} sm={12} md={4} xl={3}>
            <Grid item sm={6} xs={12} md={12} lg={12} xl={12}>
              <Card>
                <CardContent>
                  <Typography variant='h6'>Alert</Typography>
                  <Typography variant='body1'>
                    Lorem, ipsum dolor sit amet consectetur adipisicing elit. Vitae tenetur provident tempore eius necessitatibus unde
                    repellendus itaque, magni reiciendis porro! Qui eum magnam doloribus maxime nostrum necessitatibus doloremque non dolorum.
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item sm={6} xs={12} md={12} lg={12} xl={12}>
              <Card>
                <CardContent>
                  <Typography variant='h6'>Alert</Typography>
                  <Typography variant='body1'>
                    Lorem, ipsum dolor sit amet consectetur adipisicing elit. Vitae tenetur provident tempore eius necessitatibus unde
                    repellendus itaque, magni reiciendis porro! Qui eum magnam doloribus maxime nostrum necessitatibus doloremque non dolorum.
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Grid>
      </div>
      {isSmallScreen && <Navbar />}
    </div>
  )
}

export default Container
