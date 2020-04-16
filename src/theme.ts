import { createMuiTheme } from '@material-ui/core'

export const baseTheme = createMuiTheme(
  {
    // palette: {
    //   type: 'dark',
    //   primary: {
    //     main: '#3ecf8e',
    //   },
    //   secondary: {
    //     main: '#408af8',
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
      fontFamily: `Poppins, sans-serif`,
    },
  },
  {
    accent: {
      main: '#6772e5',
    },
  }
)
