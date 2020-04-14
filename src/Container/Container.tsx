import React from 'react'
import { Typography, Container as MuiContainer, makeStyles, Theme, createStyles, Grid, Card, CardContent } from '@material-ui/core'
import BarChart from '../components/Charts/BarChart'
import Navbar from './Navbar'

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      display: 'flex',
      backgroundColor: theme.palette.background.default,
      color: theme.palette.text.primary,
    },
    appbar: {
      backgroundColor: theme.palette.background.default,
      borderBottomWidth: '1px',
      borderBottomStyle: 'solid',
      borderBottomColor: theme.palette.divider,
    },
    content: {
      height: '100vh',
      borderRadius: '12px',
      backgroundColor: theme.palette.background.paper,
      marginTop: '72px',
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
      <MuiContainer className={classes.content} maxWidth='xl'>
        <Grid container>
          <Grid item xs={12}>
            <Card variant='outlined'>
              <CardContent>
                <Typography variant='h6'>Some stuff</Typography>
                <Typography variant='body1'>
                  Lorem ipsum dolor sit amet consectetur adipisicing elit. Itaque et numquam porro dolores obcaecati iusto minima, ipsam commodi
                  aut officiis suscipit consectetur accusamus eius temporibus nisi! Ut temporibus aspernatur suscipit!
                </Typography>
              </CardContent>
              <BarChart />
            </Card>
          </Grid>
        </Grid>
      </MuiContainer>
    </div>
  )
}

export default Container
