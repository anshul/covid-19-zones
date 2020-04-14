import React from 'react'
import { Typography, makeStyles, Theme, createStyles, Grid, Card, CardContent } from '@material-ui/core'
import BarChart from '../components/Charts/BarChart'
import Navbar from './Navbar'

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      width: '100% !important',
      display: 'flex',
      backgroundColor: theme.palette.background.default,
      color: theme.palette.text.primary,
    },
    appbar: {
      width: '100%',
      height: '72px',
      backgroundColor: theme.palette.background.default,
      display: 'flex',
      alignItems: 'center',
    },
    content: {
      height: '100vh',
      borderRadius: '12px',
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

  return (
    <div className={classes.root}>
      <Navbar />
      <div>
        <div className={classes.appbar}>
          <Typography variant='h6'>COVID19ZONES</Typography>
        </div>
        <Grid container spacing={1}>
          <Grid container item xs={9} spacing={1}>
            <Grid item xs={3}>
              <Card>
                <CardContent>
                  <Typography variant='subtitle1'>Total Cases</Typography>
                  <Typography variant='h5'>241,152,102</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={3}>
              <Card>
                <CardContent>
                  <Typography variant='subtitle1'>Recovered</Typography>
                  <Typography variant='h5'>241,152,102</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={3}>
              <Card>
                <CardContent>
                  <Typography variant='subtitle1'>Active Cases</Typography>
                  <Typography variant='h5'>241,152,102</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={3}>
              <Card>
                <CardContent>
                  <Typography variant='subtitle1'>Total Death</Typography>
                  <Typography variant='h5'>241,152,102</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12}>
              <Card>
                <BarChart />
              </Card>
            </Grid>
          </Grid>
          <Grid container item xs={3}>
            <Grid item xs={12}>
              <Card>
                <CardContent>
                  <Typography variant='h6'>Alert</Typography>
                  <Typography variant='body1'>
                    Lorem, ipsum dolor sit amet consectetur adipisicing elit. Vitae tenetur provident tempore eius necessitatibus unde
                    repellendus itaque, magni reiciendis porro! Qui eum magnam doloribus maxime nostrum necessitatibus doloremque non dolorum.
                  </Typography>
                </CardContent>
              </Card>
              <br />
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
    </div>
  )
}

export default Container
