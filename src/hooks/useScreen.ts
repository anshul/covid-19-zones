import { useState, useEffect } from 'react'

export const useScreen = () => {
  const [screenSize, setScreenSize] = useState(window.screen.width)

  useEffect(() => {
    setScreenSize(window.screen.width)
  }, [])

  const isSmallScreen = screenSize <= 600

  return { screenSize, isSmallScreen }
}
