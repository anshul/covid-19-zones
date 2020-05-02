import React from 'react'
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
import { LightenDarkenColor } from '../../utils/LightenDarkenColor'
import LineChart from './LineChart'

const capitalize = (str: string) => str.charAt(0).toUpperCase() + str.slice(1)

interface Props {
  code: string
  gotoZone: (code: string) => void
  gotoParentZone: () => void
}

interface Zone {
  code: string
  name: string
  cumulativeInfections: number
  currentActives: number
  cumulativeRecoveries: number
  cumulativeFatalities: number
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

interface StringMap {
  [key: string]: string
}

const LABELS: StringMap = {
  confirmed: 'infections',
  active: 'actives',
  recovered: 'recoveries',
  deceased: 'fatalities',
}

const ZonePageRoot: React.FC<Props> = ({ code, gotoZone, gotoParentZone }) => {
  const classes = useStyles()
  const { data } = useSWR(`/api/zone?code=${code}`)
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
      <Grid item xs={12} md={6}>
        <Grid container spacing={2} item xs={12}>
          <Grid item xs={12}>
            {data && data.parentZone && (
              <Breadcrumbs>
                <Link color='inherit' href='/' onClick={gotoParentZone}>
                  {data.parentZone.name}
                </Link>
                <Typography color='textPrimary'>{data.name}</Typography>
              </Breadcrumbs>
            )}
          </Grid>
          {['confirmed', 'active', 'recovered', 'deceased'].map((cases) => (
            <Grid key={cases} item xs={12} md={3}>
              <div
                style={{
                  cursor: 'pointer',
                  padding: '8px 16px',
                  color: colorMap[cases].color,
                  backgroundColor: colorMap[cases].backgroundColor,
                }}
              >
                <Typography variant='subtitle1'>{LABELS[cases]}</Typography>
                <Typography variant='h5'>
                  <b>{data ? data[cases] : '--'}</b>
                </Typography>
              </div>
            </Grid>
          ))}
          {['confirmed', 'active', 'recovered', 'deceased'].map((cases) => (
            <Grid key={cases} item xs={12} style={{ marginBottom: '30px', marginTop: '20px' }}>
              <div className={classes.lineChart}>
                <LineChart title={LABELS[cases]} data={data ? data[`ts${capitalize(LABELS[cases])}`] : {}} />
              </div>
            </Grid>
          ))}
        </Grid>
      </Grid>
      <Grid item xs={12} md={6}>
        {data?.parentZone && (
          <Toolbar>
            <IconButton edge='start' onClick={() => gotoParentZone()} className={clsx(classes.zoneListItem, classes.zoneListParentItem)}>
              <ArrowBack />
            </IconButton>
            <Typography variant='h6' style={{ marginLeft: '16px', fontWeight: 700, color: '#0000008a' }}>
              {data?.parentZone.name} / {data.name}
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
              {data?.relatedZones.map((zone: Zone) => (
                <TableRow selected={code === zone.code} hover key={zone.code} onClick={() => gotoZone(zone.code)}>
                  <TableCell>{zone.name}</TableCell>
                  <TableCell>{zone.cumulativeInfections}</TableCell>
                  <TableCell>{zone.currentActives}</TableCell>
                  <TableCell>{zone.cumulativeRecoveries}</TableCell>
                  <TableCell>{zone.cumulativeFatalities}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Grid>
    </Grid>
  )
}

export default ZonePageRoot
