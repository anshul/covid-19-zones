import React, { useRef, useEffect } from 'react'
import uPlot from 'uplot'
import { parse } from 'date-fns'
import 'uplot/dist/uPlot.min.css'

interface Props {
  title: string
  data: {
    [dt: string]: number
  }
}
const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

function slice3(str: string) {
  return str.slice(0, 3)
}

const days3 = days.map(slice3)

const months3 = months.map(slice3)

const engNames = {
  MMMM: months,
  MMM: months3,
  WWWW: days,
  WWW: days3,
}

const dateValue = (str: string): number => {
  const dt = parse(str, 'yyyy-MM-dd', new Date())
  return +dt / 1000
}

const LineChart: React.FC<Props> = ({ data, title }) => {
  const chartRef = useRef(null)

  useEffect(() => {
    const maybeDiv: unknown = chartRef.current
    if (!maybeDiv) return
    if (Object.keys(data).length <= 0) return

    const el: HTMLElement = maybeDiv as HTMLElement
    console.log('update', el)

    const cdata = [Object.keys(data).map((dt) => dateValue(dt)), Object.keys(data).map((dt) => data[dt])]

    const opts = {
      title,
      id: `chart-${title}`,
      class: 'line-chart',
      width: 480,
      height: 270,
      fmtDate: (tpl: string) => uPlot.fmtDate(tpl, engNames),
      series: [
        {},
        {
          show: true,
          spanGaps: false,
          label: title,
          stroke: 'red',
          width: 1,
          fill: 'rgba(255, 0, 0, 0.3)',
          dash: [10, 5],
        },
      ],
    }
    const uplot = new uPlot(opts, cdata, el)
    return () => {
      console.log('delete', el)
      uplot.destroy()
    }
  }, [data, title])

  return (
    <div className='chart-root' style={{ minWidth: '500px', minHeight: '300px' }}>
      <div ref={chartRef} />
    </div>
  )
}

export default LineChart
