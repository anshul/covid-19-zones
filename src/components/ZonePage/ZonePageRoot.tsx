import React from 'react'
import { ResponsiveLine } from '@nivo/line'
import {
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
  Breadcrumbs,
  Link,
} from '@material-ui/core'
import useSWR from 'swr'
import { ArrowBack } from '@material-ui/icons'
import clsx from 'clsx'
import { startCase } from 'lodash'
import { LightenDarkenColor } from '../../utils/LightenDarkenColor'

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
    confirmed: {
      color: '#ff1744',
      backgroundColor: LightenDarkenColor('#ff1744', 9, 'tint'),
      chartColor: '#ff1744',
    },
    active: {
      color: '#7656d6',
      backgroundColor: LightenDarkenColor('#7656d6', 9, 'tint'),
      chartColor: '#7656d6',
    },
    recovered: {
      color: '#5dab76',
      backgroundColor: LightenDarkenColor('#5dab76', 9, 'tint'),
      chartColor: '#5dab76',
    },
    deceased: {
      color: '#9E9E9E',
      backgroundColor: LightenDarkenColor('#9E9E9E', 9, 'tint'),
      chartColor: '#9E9E9E',
    },
  }

  return (
    <Grid container spacing={4}>
      <Grid item xs={12} md={4}>
        {data?.parentZone && (
          <Toolbar>
            <IconButton edge='start' onClick={() => gotoParentZone()} className={clsx(classes.zoneListItem, classes.zoneListParentItem)}>
              <ArrowBack />
            </IconButton>
            <Typography variant='h6' style={{ marginLeft: '16px', fontWeight: 700, color: '#0000008a' }}>
              {data?.parentZone.name}
            </Typography>
          </Toolbar>
        )}
        <TableContainer>
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
      </Grid>
      <Grid item xs={12} md={4}>
        <Grid container spacing={2} item xs={12}>
          <Grid item xs={12}>
            {data && <Breadcrumbs>
              <Link color="inherit" href="/" onClick={gotoParentZone}>
                {data.parentZone.name}
              </Link>
              <Typography color="textPrimary">{data.zone}</Typography>
            </Breadcrumbs>}
          </Grid>
          {['confirmed', 'active', 'recovered', 'deceased'].map((cases) => (
            <Grid item xs={12} md={3}>
              <div style={{ cursor: 'pointer', padding: '8px 16px', color: colorMap[cases].color, backgroundColor: colorMap[cases].backgroundColor }}>
                <Typography variant='subtitle1'>{startCase(cases)}</Typography>
                <Typography variant='h5'>
                  <b>{data ? data[cases].totalCount : '--'}</b>
                </Typography>
              </div>
            </Grid>
          ))}
          {['confirmed', 'active', 'recovered', 'deceased'].map((cases) => (
            <Grid key={cases} item xs={12}>
              <div className={classes.lineChart}>
                <ResponsiveLine
                  colors={[colorMap[cases].chartColor, '#B0BEC5']}
                  data={[
                    { id: `${startCase(cases)} Cases (Daily)`, data: data ? data[cases].perDayCounts : [] },
                    { id: `${startCase(cases)} Cases (5 Day Moving Average)`, data: data ? data[cases].fiveDayMovingAverage : [] },
                  ]}
                  margin={{ top: 60, right: 50, bottom: 60, left: 30 }}
                  enableGridX={false}
                  enableGridY={false}
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
                    tickValues: 'every 5 days',
                  }}
                  axisRight={{
                    orient: 'right',
                    tickSize: 5,
                    tickPadding: 5,
                    tickRotation: 0,
                  }}
                  pointSize={5}
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
    </Grid>
  )
}

export default ZonePageRoot
