import React from 'react'
import { Typography, AppBar, Toolbar, Container as MuiContainer, makeStyles, Theme, createStyles, useTheme, Grid, Paper, Card, CardHeader, CardContent } from '@material-ui/core'

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
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
      height: 'calc(100vh - 65px)',
      marginTop: '65px',
      '& > div': {
        paddingTop: theme.spacing(2),
        paddingLeft: theme.spacing(3),
        paddingRight: theme.spacing(3),
      },
    },
  })
)

const Container: React.FC = () => {
  const classes = useStyles()
  console.log(useTheme())
  return (
    <div className={classes.root}>
      <AppBar position='fixed' className={classes.appbar} elevation={0}>
        <MuiContainer>
          <Toolbar>
            <Typography variant='h6'>COVID19ZONES</Typography>
          </Toolbar>
        </MuiContainer>
      </AppBar>
      <MuiContainer className={classes.content}>
        <Grid container>
          <Grid item xs={12}>
            <Card variant="outlined">
              <CardContent>
                <Typography variant='h6'>Some stuff</Typography>
                <Typography variant='body1'>
                  Lorem ipsum dolor sit amet consectetur adipisicing elit. Itaque et numquam porro dolores obcaecati iusto minima, ipsam commodi aut
                  officiis suscipit consectetur accusamus eius temporibus nisi! Ut temporibus aspernatur suscipit!
            </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </MuiContainer>
    </div >
  )
}

export default Container
