import React from 'react'
import { ResponsiveLine } from '@nivo/line'
import {
  Paper,
  makeStyles,
  createStyles,
  Theme,
  Grid,
  Typography,
  TableContainer,
  Table,
  TableHead,
  TableRow,
  TableCell,
  TableBody,
  IconButton,
  Toolbar,
} from '@material-ui/core'
import useSWR from 'swr'
import { ArrowBack } from '@material-ui/icons'
import clsx from 'clsx'
import { startCase } from 'lodash'

interface Props {
  slug: string
  gotoZone: (slug: string) => void
  gotoParentZone: () => void
}

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    lineChart: {
      height: '30vh',
    },
    zoneList: {
      height: '50vh',
      overflow: 'auto',
    },
    zoneListItem: {
      padding: theme.spacing(1),
      cursor: 'pointer',
      '&:hover': {
        backgroundColor: '#eaeaea',
      },
    },
    zoneListParentItem: {
      display: 'flex',
      alignItems: 'center',
    },
    zoneListParentItemText: {
      marginLeft: theme.spacing(2),
    },
  })
)

const ZonePageRoot: React.FC<Props> = ({ slug, gotoZone, gotoParentZone }) => {
  const classes = useStyles()
  const { data } = useSWR(`/api/zone?slug=${slug}`)
  const colorMap: { [key: string]: { [key: string]: string } } = {
    active: {
      color: '#212121',
      backgroundColor: '#82B1FF',
      chartColor: '#2196F3',
    },
    recovered: {
      color: '#212121',
      backgroundColor: '#B9F6CA',
      chartColor: '#4CAF50',
    },
    deceased: {
      color: '#212121',
      backgroundColor: '#ff8a80',
      chartColor: '#f44336',
    },
  }

  const table = (
    <Grid item xs={12} md={4}>
      <Paper variant='outlined'>
        {data?.parentZone && (
          <Toolbar>
            <IconButton edge='start' onClick={() => gotoParentZone()} className={clsx(classes.zoneListItem, classes.zoneListParentItem)}>
              <ArrowBack />
            </IconButton>
            <Typography variant='h6' style={{ marginLeft: '16px', fontWeight: 'bold', color: '#0000008a' }}>
              {data?.parentZone.name}
            </Typography>
          </Toolbar>
        )}
        <TableContainer style={{ height: '100vh' }}>
          <Table stickyHeader aria-label='sticky table'>
            <TableHead>
              <TableRow>
                <TableCell>Zone</TableCell>
                <TableCell>Total</TableCell>
                <TableCell>Active</TableCell>
                <TableCell>Recovered</TableCell>
                <TableCell>Deceased</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data?.siblingZones.map((zone: any) => (
                <TableRow selected={slug === zone.slug} hover key={zone.code} onClick={() => gotoZone(zone.slug)}>
                  <TableCell>{zone.name}</TableCell>
                  <TableCell>{zone.totalCases}</TableCell>
                  <TableCell>{zone.totalActive}</TableCell>
                  <TableCell>{zone.totalRecovered}</TableCell>
                  <TableCell>{zone.totalDeceased}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>
    </Grid>
  )

  const charts = (
    <Grid item spacing={2} xs={12} md={4}>
      <Grid container spacing={2} item xs={12}>
        <Grid item xs={12}>
          {data && <Typography variant='h6'>{data.zone}</Typography>}
        </Grid>
        <Grid item xs={12} md={3}>
          <div style={{ cursor: 'pointer', padding: '8px 16px', color: '#212121', backgroundColor: '#ECEFF1' }}>
            <Typography variant='subtitle1'>Total</Typography>
            <Typography variant='h5'>
              <b>{data?.totalCases || '--'}</b>
            </Typography>
          </div>
        </Grid>
        {/*<Grid item xs={12} md={3}>
          <div style={{ cursor: 'pointer', padding: '8px 16px', color: '#212121', backgroundColor: '#82B1FF' }}>
            <Typography variant='subtitle1'>Active</Typography>
            <Typography variant='h5'>
              <b>{data?.active.totalCount || '--'}</b>
            </Typography>
          </div>
        </Grid>
        <Grid item xs={12} md={3}>
          <div style={{ cursor: 'pointer', padding: '8px 16px', color: '#212121', backgroundColor: '#B9F6CA' }}>
            <Typography variant='subtitle1'>Recovered</Typography>
            <Typography variant='h5'>
              <b>{data?.recovered.totalCount || '--'}</b>
            </Typography>
          </div>
        </Grid>
        <Grid item xs={12} md={3}>
          <div style={{ cursor: 'pointer', padding: '8px 16px', color: '#212121', backgroundColor: '#ff8a80' }}>
            <Typography variant='subtitle1'>Deceased</Typography>
            <Typography variant='h5'>
              <b>{data?.deceased.totalCount || '--'}</b>
            </Typography>
          </div>
          </Grid>*/}
        {['active'].map((cases) => (
          <Grid key={cases} item xs={12}>
            <div className={classes.lineChart}>
              <ResponsiveLine
                colors={[colorMap[cases].chartColor, '#607D8B']}
                data={[
                  { id: `${startCase(cases)} Cases (Daily)`, data: data ? data[cases].perDayCounts : [] },
                  { id: `${startCase(cases)} Cases (5 Day Moving Average)`, data: data ? data[cases].fiveDayMovingAverage : [] },
                ]}
                margin={{ top: 60, right: 50, bottom: 60, left: 30 }}
                xScale={{
                  type: 'time',
                  format: '%Y-%m-%d',
                  precision: 'day',
                }}
                xFormat='time:%Y-%m-%d'
                yScale={{ type: 'linear', min: 'auto', max: data ? data.yMax : 'auto', reverse: false }}
                axisTop={null}
                axisLeft={null}
                axisBottom={{
                  orient: 'bottom',
                  tickSize: 5,
                  tickPadding: 5,
                  tickRotation: 90,
                  format: '%b %d',
                  tickValues: 'every 2 days',
                  legend: 'time scale',
                }}
                axisRight={{
                  orient: 'right',
                  tickSize: 5,
                  tickPadding: 5,
                  tickRotation: 0,
                }}
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
            </div>
          </Grid>
        ))}
      </Grid>
    </Grid>
  )

  return (
    <Grid container spacing={1}>
      <Grid item xs={12} md={2} />
      {charts}
      {table}
    </Grid>
  )
}

export default ZonePageRoot
