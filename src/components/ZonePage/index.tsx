import React from "react";
import { RouteComponentProps } from "react-router";
import ZonePageRoot from "./ZonePageRoot";

const ZonePage: React.FC<RouteComponentProps<{ slug: string }>> = ({location, match}) => {
  return (
    <ZonePageRoot />
  )
}

export default ZonePage