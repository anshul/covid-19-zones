import React from 'react'
import { ResponsiveBar } from '@nivo/bar'
import { chartTheme } from './chartTheme'
import { useTheme } from '@material-ui/core'

const BarChart: React.FC = () => {
  const theme = useTheme()

  const keys = ['hot dogs', 'burgers', 'sandwich', 'kebab', 'fries', 'donut']

  const commonProps = {
    margin: { top: 60, right: 80, bottom: 60, left: 80 },
    theme: chartTheme(theme),
    data: [
      {
        country: 'AD',
        'hot dog': 48,
        'hot dogColor': 'hsl(145, 70%, 50%)',
        burger: 74,
        burgerColor: 'hsl(195, 70%, 50%)',
        sandwich: 99,
        sandwichColor: 'hsl(224, 70%, 50%)',
        kebab: 100,
        kebabColor: 'hsl(195, 70%, 50%)',
        fries: 49,
        friesColor: 'hsl(89, 70%, 50%)',
        donut: 77,
        donutColor: 'hsl(20, 70%, 50%)',
      },
      {
        country: 'AE',
        'hot dog': 33,
        'hot dogColor': 'hsl(62, 70%, 50%)',
        burger: 126,
        burgerColor: 'hsl(268, 70%, 50%)',
        sandwich: 13,
        sandwichColor: 'hsl(253, 70%, 50%)',
        kebab: 19,
        kebabColor: 'hsl(336, 70%, 50%)',
        fries: 156,
        friesColor: 'hsl(171, 70%, 50%)',
        donut: 151,
        donutColor: 'hsl(12, 70%, 50%)',
      },
      {
        country: 'AF',
        'hot dog': 31,
        'hot dogColor': 'hsl(100, 70%, 50%)',
        burger: 55,
        burgerColor: 'hsl(263, 70%, 50%)',
        sandwich: 54,
        sandwichColor: 'hsl(35, 70%, 50%)',
        kebab: 128,
        kebabColor: 'hsl(227, 70%, 50%)',
        fries: 80,
        friesColor: 'hsl(93, 70%, 50%)',
        donut: 91,
        donutColor: 'hsl(57, 70%, 50%)',
      },
      {
        country: 'AG',
        'hot dog': 150,
        'hot dogColor': 'hsl(242, 70%, 50%)',
        burger: 134,
        burgerColor: 'hsl(22, 70%, 50%)',
        sandwich: 164,
        sandwichColor: 'hsl(359, 70%, 50%)',
        kebab: 183,
        kebabColor: 'hsl(336, 70%, 50%)',
        fries: 193,
        friesColor: 'hsl(239, 70%, 50%)',
        donut: 79,
        donutColor: 'hsl(287, 70%, 50%)',
      },
      {
        country: 'AI',
        'hot dog': 105,
        'hot dogColor': 'hsl(23, 70%, 50%)',
        burger: 121,
        burgerColor: 'hsl(8, 70%, 50%)',
        sandwich: 74,
        sandwichColor: 'hsl(191, 70%, 50%)',
        kebab: 81,
        kebabColor: 'hsl(339, 70%, 50%)',
        fries: 31,
        friesColor: 'hsl(345, 70%, 50%)',
        donut: 189,
        donutColor: 'hsl(104, 70%, 50%)',
      },
      {
        country: 'AL',
        'hot dog': 88,
        'hot dogColor': 'hsl(335, 70%, 50%)',
        burger: 42,
        burgerColor: 'hsl(141, 70%, 50%)',
        sandwich: 65,
        sandwichColor: 'hsl(23, 70%, 50%)',
        kebab: 84,
        kebabColor: 'hsl(203, 70%, 50%)',
        fries: 1,
        friesColor: 'hsl(62, 70%, 50%)',
        donut: 115,
        donutColor: 'hsl(116, 70%, 50%)',
      },
      {
        country: 'AM',
        'hot dog': 186,
        'hot dogColor': 'hsl(26, 70%, 50%)',
        burger: 178,
        burgerColor: 'hsl(74, 70%, 50%)',
        sandwich: 7,
        sandwichColor: 'hsl(66, 70%, 50%)',
        kebab: 30,
        kebabColor: 'hsl(40, 70%, 50%)',
        fries: 77,
        friesColor: 'hsl(2, 70%, 50%)',
        donut: 123,
        donutColor: 'hsl(151, 70%, 50%)',
      },
    ],
    indexBy: 'country',
    keys,
    padding: 0.2,
    labelTextColor: 'inherit:darker(1.4)',
    labelSkipWidth: 16,
    labelSkipHeight: 16,
  }

  return (
    <div style={{ height: '400px' }}>
      <ResponsiveBar {...commonProps} groupMode='grouped' />
    </div>
  )
}

export default BarChart
