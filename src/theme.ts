import { createMuiTheme } from '@material-ui/core'

export const baseTheme = createMuiTheme(
  {
    // palette: {
    //   type: 'dark',
    //   primary: {
    //     main: '#1eb980',
    //   },
    //   secondary: {
    //     main: '#3ecf8e',
    //   },
    //   common: {
    //     white: '#f6f9fc',
    //     black: '#6b7c93',
    //   },
    //   background: {
    //     paper: '#1b1c21',
    //     default: '#141419',
    //   },
    //   divider: '#27292e',
    // },

    typography: {
      fontFamily: `Roboto Mono, sans-serif`,
    },
  },
  {
    accent: {
      main: '#6772e5',
    },
  }
)
