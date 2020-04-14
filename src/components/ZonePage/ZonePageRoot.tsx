import React from 'react'
import { ResponsiveLine } from '@nivo/line'
import { Paper, makeStyles, createStyles, Theme, List, ListItem, Grid, ListItemText, ListSubheader, ListItemIcon } from '@material-ui/core'
import useSWR from 'swr'
import { history } from '../../history'
import { ArrowBack } from '@material-ui/icons'

interface Props {
  slug: string
  gotoZone: (slug: string) => void
  gotoParentZone: () => void
}

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    lineChartContainer: {
      height: '50vh',
    },
    zoneList: {
      height: '50vh',
      overflow: 'auto',
    },
  })
)

const ZonePageRoot: React.FC<Props> = ({ slug, gotoZone, gotoParentZone }) => {
  const classes = useStyles()
  const { data, error } = useSWR(`/api/zone?slug=${slug}`)

  return (
    <Grid container spacing={1}>
      <Grid item xs={12} md={2}>
        <Paper>
          <List className={classes.zoneList}>
            <ListItem button onClick={() => gotoParentZone()}>
              <ListItemIcon>
                <ArrowBack />
              </ListItemIcon>
              <ListItemText primary='Parent Zone' />
            </ListItem>
            {data?.siblingZones.map((zone: any) => (
              <ListItem key={zone.slug} selected={zone.slug === slug} button onClick={() => gotoZone(zone.slug)}>
                <ListItemText primary={zone.name} />
              </ListItem>
            ))}
          </List>
        </Paper>
      </Grid>
      <Grid item xs={12} md={10}>
        <Paper className={classes.lineChartContainer}>
          <ResponsiveLine
            data={[
              { id: 'Confirmed Cases (Daily)', data: data?.perDayCounts ?? [] },
              { id: 'Confirmed Cases (3 Day Moving Average)', data: data?.threeDayMovingAverage ?? [] },
            ]}
            margin={{ top: 50, right: 110, bottom: 50, left: 60 }}
            xScale={{ type: 'point' }}
            yScale={{ type: 'linear', min: 'auto', max: 'auto', reverse: false }}
            axisTop={null}
            axisLeft={null}
            axisBottom={{
              orient: 'bottom',
              tickSize: 5,
              tickPadding: 5,
              tickRotation: 0,
            }}
            axisRight={{
              orient: 'right',
              tickSize: 5,
              tickPadding: 5,
              tickRotation: 0,
            }}
            colors={{ scheme: 'nivo' }}
            pointSize={10}
            pointBorderColor={{ from: 'serieColor' }}
            useMesh={true}
            legends={[
              {
                anchor: 'top-left',
                direction: 'column',
                itemWidth: 80,
                itemHeight: 20,
                itemOpacity: 0.75,
                symbolSize: 12,
                symbolShape: 'circle',
                symbolBorderColor: 'rgba(0, 0, 0, .5)',
              },
            ]}
          />
        </Paper>
      </Grid>
    </Grid>
  )
}

export default ZonePageRoot
