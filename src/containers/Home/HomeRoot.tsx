import React from 'react'
import { Typography, makeStyles, createStyles, Grid, Card, CardContent } from '@material-ui/core'

const useStyles = makeStyles(() =>
  createStyles({
    gridContainer: {
      width: '100%',
      marginBottom: '60px',
    },
  })
)

const HomeRoot: React.FC = () => {
  const classes = useStyles()

  return (
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
          <Card style={{ height: '100%', minHeight: '250px' }}>Bar chart goes here</Card>
        </Grid>
      </Grid>
      <Grid container item spacing={1} xs={12} sm={12} md={4} xl={3}>
        <Grid item sm={6} xs={12} md={12} lg={12} xl={12}>
          <Card>
            <CardContent>
              <Typography variant='h6'>Alert</Typography>
              <Typography variant='body1'>
                Lorem, ipsum dolor sit amet consectetur adipisicing elit. Vitae tenetur provident tempore eius necessitatibus unde repellendus
                itaque, magni reiciendis porro! Qui eum magnam doloribus maxime nostrum necessitatibus doloremque non dolorum.
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item sm={6} xs={12} md={12} lg={12} xl={12}>
          <Card>
            <CardContent>
              <Typography variant='h6'>Alert</Typography>
              <Typography variant='body1'>
                Lorem, ipsum dolor sit amet consectetur adipisicing elit. Vitae tenetur provident tempore eius necessitatibus unde repellendus
                itaque, magni reiciendis porro! Qui eum magnam doloribus maxime nostrum necessitatibus doloremque non dolorum.
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Grid>
  )
}

export default HomeRoot
