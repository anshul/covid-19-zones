import { Theme } from '@nivo/core'
import { Theme as MuiTheme } from '@material-ui/core'

export const chartTheme = (theme: MuiTheme): Theme => {
  return {
    axis: {
      ticks: {
        text: {
          fill: theme.palette.text.secondary,
        },
      },
    },
    tooltip: {
      container: {
        background: theme.palette.background.paper,
      },
    },
  }
}
