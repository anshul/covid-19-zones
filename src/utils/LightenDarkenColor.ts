interface RGB {
  red: number
  green: number
  blue: number
}

export const LightenDarkenColor = (col: string, amt: number, tintOrShade: 'tint' | 'shade'): string => {
  if (col[0] == '#') {
    col = col.slice(1)
  }

  let rgb = hexToRGB(col)
  if (tintOrShade === 'tint') rgb = rgbTint(rgb, amt)
  if (tintOrShade === 'shade') rgb = rgbShade(rgb, amt)

  return '#' + rgbToHex(rgb)
}

function rgbShade(rgb: RGB, i: number) {
  return {
    red: rgb.red * (1 - 0.1 * i),
    green: rgb.green * (1 - 0.1 * i),
    blue: rgb.blue * (1 - 0.1 * i),
  }
}

function rgbTint(rgb: RGB, i: number) {
  return {
    red: rgb.red + (255 - rgb.red) * i * 0.1,
    green: rgb.green + (255 - rgb.green) * i * 0.1,
    blue: rgb.blue + (255 - rgb.blue) * i * 0.1,
  }
}

function hexToRGB(colorValue: string) {
  return {
    red: parseInt(colorValue.substr(0, 2), 16),
    green: parseInt(colorValue.substr(2, 2), 16),
    blue: parseInt(colorValue.substr(4, 2), 16),
  }
}

function pad(number: string, length: number) {
  let str = '' + number
  while (str.length < length) {
    str = '0' + str
  }
  return str
}

function intToHex(rgbint: number) {
  return pad(Math.min(Math.max(Math.round(rgbint), 0), 255).toString(16), 2)
}

function rgbToHex(rgb: RGB) {
  return intToHex(rgb.red) + intToHex(rgb.green) + intToHex(rgb.blue)
}
