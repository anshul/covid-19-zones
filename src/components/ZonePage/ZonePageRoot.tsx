import React from 'react'
import { ResponsiveLine } from '@nivo/line'
import { Paper, makeStyles, createStyles, Theme } from '@material-ui/core'
import useSWR from 'swr'

interface Props {
  slug: string
}

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    lineChartContainer: {
      height: '500px',
    },
  })
)

const ZonePageRoot: React.FC<Props> = ({ slug }) => {
  const classes = useStyles()
  const { data, error } = useSWR(`/api/zone?slug=${slug}`)

  return (
    <>
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
        />
      </Paper>
    </>
  )
}

export default ZonePageRoot
