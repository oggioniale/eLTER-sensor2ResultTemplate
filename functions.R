###
# Functions
###
sosHost <- 'http://getit.lteritalia.it'
# List of procedure URI and name by SOS endpoint
getProcedureList <- function(sosHost) {
  # xslProcUrl.url <- "https://www.get-it.it/objects/sensors/xslt/Capabilities_proceduresUrlList.xsl"
  xslProcUrl.url <- "./xslt/Capabilities_proceduresUrlList.xsl"
  styleProcUrl <- xml2::read_xml(xslProcUrl.url, package = "xslt")
  
  listProcedure <- read.csv(text = xslt::xml_xslt((
    xml2::read_xml(
      paste0(sosHost,
             '/observations/service?service=SOS&request=GetCapabilities&Sections=Contents'),
      package = "xslt"
    )
  ), styleProcUrl), header = TRUE, sep = ';')
  
  sensorName <- vector("character", nrow(listProcedure))
  sensorLon <- vector("character", nrow(listProcedure))
  sensorLat <- vector("character", nrow(listProcedure))
  for (i in 1:nrow(listProcedure)) {
    SensorML <- xml2::read_xml(
      as.character(
        paste0(
          sosHost,
          '/observations/service?service=SOS&amp;version=2.0.0&amp;request=DescribeSensor&amp;procedure=',
          listProcedure$uri[i],
          '&amp;procedureDescriptionFormat=http%3A%2F%2Fwww.opengis.net%2FsensorML%2F1.0.1'
        )
      )
    )
    ns <- xml2::xml_ns(SensorML)
    sensorName[i] <- as.character(xml2::xml_find_all(
      SensorML, 
      "//sml:identification/sml:IdentifierList/sml:identifier[@name='short name']/sml:Term/sml:value/text()",
      ns
    ))
    sensorLon[i] <- as.character(xml2::xml_find_all(
      SensorML,
      "//sml:position/swe:Position/swe:location/swe:Vector/swe:coordinate[@name='easting']/swe:Quantity[@axisID='Lon']/swe:value/text()",
      ns
    ))
    sensorLat[i] <- as.character(xml2::xml_find_all(
      SensorML,
      "//sml:position/swe:Position/swe:location/swe:Vector/swe:coordinate[@name='northing']/swe:Quantity[@axisID='Lat']/swe:value/text()",
      ns
    ))
  }
  listProcedure <- split(c(as.list(listProcedure$uri), sensorLon, sensorLat), seq(length(sensorName))) 
  names(listProcedure) <- sensorName
  return(listProcedure)
}

