#
# This is a Shiny web application.
# This application was develop by Alessandro Oggioni CNR IREA
# Licence CC By SA 3.0  http://creativecommon.org/licences/by-SA/3.0
#
# If you download this application, you can run it by clicking
# the 'Run App' button above.
#
###
# Library
###
library(ggplot2)
library(shiny)
library(shinydashboard)
library(leaflet)
library(xslt)
library(xml2)
library(DT)
library(shinycssloaders)
library(crosstalk)
library(shinyjs)
library(shinyBS)
library(leaflet.extras)
library(mapview)
library(mapedit)
library(httr)
library(fs)
library(rintrojs)

###
# UI
###
ui <- fluidPage(
  useShinyjs(),
  introjsUI(),
  
  # Application title
  introBox(
    titlePanel("Create insertResultTemplate"),
    data.step = 1,
    data.intro = "InsertResultTemplate is a SOS request for inserting a result template into a SOS server that describes the structure of the values of a InsertResult. The insertResulTempalte must be associate to a station/sensor. Creating a result template in the SOS server for a station/sensor, a template is created for the observations, and the observations themselves can be entered more easily."
  ),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      width = 5,
      div(
        HTML(
          "<h5 align='justify'>This interface allows to create XML insertResultTemplate for Sensor Observation Service (SOS) starting from a SensorML. Insert below a resolvable and unique ID of the station/sensor (e.g. <a href=\"http://getit.lteritalia.it/sensors/sensor/ds/?format=text/html&sensor_id=http%3A//www.get-it.it/sensors/getit.lteritalia.it/procedure/CampbellScientificInc/noModelDeclared/noSerialNumberDeclared/20170914050327762_790362\">ENEA Santa Teresa meteorological station</a>).</h5>"
        ),
        actionButton("help", "Give me an overview", style = "color: #fff; background-color: #0069D9; border-color: #0069D9")
      ),
      introBox(
        div(HTML("<hr><h4>Service endpoint</h4>")),
        selectInput(
          inputId = "sosHost",
          label = "Select SOS endpoint",
          multiple = F,
          choices = list(
            "LTER-Italy SOS (default)" = "http://getit.lteritalia.it"#,
            # "LTER-Eu CDN SOS" = "http://cdn.lter-europe.net"
          ),
          selected = "http://getit.lteritalia.it"
        ),
        data.step = 2,
        data.intro = "In this dropdown menu you can select the SOS where you want to upload the observations and where is stored the station/sensor information."
      ),
      introBox(
        div(HTML("<hr><h4>Station</h4>")),
        selectInput(inputId = "SensorMLURI",
                    label = HTML("Select name of the station/sensor (e.g. <a href=\"http://getit.lteritalia.it/sensors/sensor/ds/?format=text/html&sensor_id=http%3A//www.get-it.it/sensors/getit.lteritalia.it/procedure/CampbellScientificInc/noModelDeclared/noSerialNumberDeclared/20170914050327762_790362\">ENEA Santa Teresa meteorological station</a>)"), 
                    multiple = FALSE,
                    ""
        ),
        data.step = 3,
        data.intro = "This is the dopdown menu where you must select the name of the station/sensor.",
        div(HTML("<p>In the map the position of the station selected above.</p>")),
        leafletOutput("mymap"),
        div(HTML("<br/>"))
      ),
      # div(HTML(
      #   "<hr><h4>Feature Of Interest (FOI)</h4>"
      # )),
      # textInput('FOI_Name', 'Enter the name of feature of interest'),
      # textInput('FOI_EPSG', 'Enter URL of sample feature'),

      # Input: FOI POPUP
      # actionButton('foi', 'Click for provide station\'s position'),
      # shinyBS::bsModal(
      #   "modalnew",
      #   "Draw the marker for the station's position",
      #   "foi",
      #   size = "medium",
      #   # editModUI("editor"),
      #   leafletOutput("mymap"),
      #   textInput("lat", "Latitude (e.g. 45.9206)"),
      #   textInput("long", "Longitude (e.g. 8.6019)"),
      #   # selectInput(inputId = "srs",
      #   #             label = "Projection",
      #   #             multiple = F,
      #   #             choices = list(
      #   #               "WGS84"="http://www.opengis.net/def/crs/EPSG/0/4326",
      #   #               "..." = ""
      #   #             ),
      #   #             selected = "http://www.opengis.net/def/crs/EPSG/0/4326"
      #   # ),
      #   textInput("sampFeat", "Sampled feature")
      # ),
      introBox(
        actionButton("sendQ", "Upload XML Request", icon = icon("file-upload")),
        data.step = 4,
        data.intro = "With this button you can send the requst to the SOS endpoint selected above."
      )
    ),
    
    # Show a XML of the generated
    mainPanel(
      width = 7,
      tags$head(HTML(
        "<link rel='stylesheet' href='css/codemirror.css'>"
      )),
      tags$head(HTML(
        "<link rel='stylesheet' href='css/show-hint.css'>"
      )),
      # tags$head(HTML(
      #   "<script src='js/jquery.js'></script>"
      # )),
      tags$head(HTML(
        "<script src='js/codemirror.js'></script>"
      )),
      tags$head(HTML(
        "<script src='js/show-hint.js'></script>"
      )),
      tags$head(HTML("<script src='js/xml.js'></script>")),
      tags$head(
        HTML(
          "<style type=\"text/css\">
          .CodeMirror {
          border-top: 1px solid #888;
          border-bottom: 1px solid #888;
          }
          </style>"
        )
      ),
      uiOutput(outputId = "header"),
      introBox(
        uiOutput(outputId = "codeXML"),
        data.step = 5,
        data.intro = "In this box you can see the insertResultTempalte in XML code. You can also use this tool in order to create insertResultTempalte XML request for SOS server not listed into \"Service endpoint\" drop box."
      ),
      verbatimTextOutput("selectParamCSV")
    ),
  )
)

###
# Sources
###
source("functions.R", local = TRUE)$value

###
# Server
###
server <- function(input, output, session) {
  # initiate hints on startup with custom button and event
  hintjs(
    session,
    options = list("hintButtonLabel" = "Hope this hint was helpful"),
    events = list("onhintclose" = I('alert("Wasn\'t that hint helpful")'))
  )
  
  # edit module returns mapedit
  # output$edits <- callModule(
  #   editMod,
  #   "editor",
  
  # observeEvent(c(input$mymap_draw_edited_features, input$mymap_draw_new_feature), {
  #   if (!is.null(input$mymap_draw_edited_features)) {
  #     click_lon <- input$mymap_draw_edited_features$features[[1]]$geometry$coordinates[[1]]
  #     click_lat <- input$mymap_draw_edited_features$features[[1]]$geometry$coordinates[[2]]
  #     coordinatesFOI$lat <- c(click_lat)
  #     coordinatesFOI$lon <- c(click_lon)
  #     updateTextInput(session, "lat", value = click_lat)
  #     updateTextInput(session, "long", value = click_lon)
  #   }
  #   else
  #   click_lat <- input$mymap_draw_new_feature$geometry$coordinates[[2]]
  #   click_lon <- input$mymap_draw_new_feature$geometry$coordinates[[1]]
  #   coordinatesFOI$lat <- c(click_lat)
  #   coordinatesFOI$lon <- c(click_lon)
  #   updateTextInput(session, "lat", value = click_lat)
  #   updateTextInput(session, "long", value = click_lon)
  # 
  #   print(input$mymap_draw_edited_features$features[[1]]$geometry$coordinates)
  # })
  
  #xslObs.url <- "https://www.get-it.it/objects/sensors/xslt/sensor2ResultTemplate_4Shiny.xsl"
  xslObs.url <- "./sensor2ResultTemplate_4Shiny.xsl"
  style <- read_xml(xslObs.url, package = "xslt")
  
  observe({
    toggleState("sendQ",
                condition = (input$SensorMLURI != "" |
                               is.null(input$SensorMLURI)))
  })
  
  ### Codelist for dropdown menu of stations from procedure elements within capabilities XML
  outputsProcedures <- reactive({
    listProcedure <- getProcedureList(input$sosHost)
  })
  
  # coordinatesFOI <- reactiveValues(lat = NULL, lon = NULL)
  output$mymap <- renderLeaflet({
      lat <- outputsProcedures()[input$SensorMLURI][[1]][3][[1]]
      lon <- outputsProcedures()[input$SensorMLURI][[1]][2][[1]]
    
      #Get setView parameters
      new_zoom <- 2
      new_lat <- 0
      # if(!is.null(lat)) new_lat <- lat
      new_lon <- 0
      # if(!is.null(lon)) new_lon <- lon
      
      leaflet() %>% addTiles() %>%
        setView(new_lon, new_lat, zoom = new_zoom) #%>%
        addMarkers(lng = lon, lat = lat)
      # setView(lng = 0, lat = 0, zoom = 1) %>%
      # addSearchOSM() %>%
      # addDrawToolbar(
      #   #targetGroup = "new_points",
      #   polylineOptions = FALSE,
      #   polygonOptions = FALSE,
      #   rectangleOptions = FALSE,
      #   circleOptions = FALSE,
      #   circleMarkerOptions = FALSE,
      #   #markerOptions = TRUE,
      #   editOptions = editToolbarOptions(
      #     selectedPathOptions = selectedPathOptions()
      #     )
      # )
  })
  
  observe({
    updateSelectInput(session, "SensorMLURI", choices = outputsProcedures())
  })
  ### End codelist
  
  output$header <- renderUI({
    if (!input$SensorMLURI == "") {
      tags$div(
        HTML(
          "<h5>Click on <b>\"Upload XML request\"</b> button ... or, if you are a <i>geek</i> person copy the code produced below and paste in the SOS server where you have stored sensor metadata.</h5></br>"
        )
      )
    }
  })
  
  rvXML <- reactiveValues(XML = '')

  observe({
    req(input$sosHost, input$SensorMLURI)
    
    rvXML$XML <- xml_xslt((read_xml(
      paste0(
        input$sosHost,
        '/observations/sos/kvp?service=SOS&version=2.0.0&request=DescribeSensor&procedure=',
        input$SensorMLURI,
        '&procedureDescriptionFormat=http://www.opengis.net/sensorml/2.0'
      ),
      package = "xslt"
    )), style)
  })
  
  output$codeXML <- renderUI({
    # if (!input$SensorMLURI == "") {
    
    # Create a Progress object
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    progress$set(message = "Making XML request", value = 0)
    
    tags$form(tags$textarea(id = "code",
                            name = "code",
                            as.character(rvXML$XML)),
              tags$script(
                HTML(
                  "var editorXML = CodeMirror.fromTextArea(document.getElementById(\"code\"), {
          mode: \"xml\",
          lineNumbers: true,
          smartindent: true,
          extraKeys: {\"Ctrl-Space\": \"autocomplete\"}
          });
          editorXML.setSize(\"100%\",\"100%\");"
                )
              ))
    # }
    # else if (input$SensorMLURI == "Couldn't resolve host name.") {
    #     tags$textarea(
    #       id="code",
    #       name = "code",
    #       "Couldn't resolve host name. Please put in the SensorML URI valid URL."
    #     )
    # }
  })
  
  # event for upload XML button
  observeEvent(input$sendQ, {
    # Create a Progress object
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    
    progress$set(message = "Send request ...", value = 0)
    
    xmlRequest <- as.character(rvXML$XML)
    b <- gsub("\n", "§", gsub("\"", "'", xmlRequest))
    a <- strsplit(b, "<sos:InsertResultTemplate ")[[1]]
    e <- a[2:length(a)]
    c <-
      paste("<?xml version='1.0' encoding='UTF-8'?>§<sos:InsertResultTemplate ",
            e,
            sep = "")
    d <- gsub("§", "\n", gsub("'", "\"", c))
    
    for (f in 1:length(d)) {
      xmlFilePath <- paste("request", f, ".xml", sep = "")
      xmlFile <- file(xmlFilePath, "wt")
      xml2::write_xml(xml2::read_xml(d[f]), xmlFilePath)
      # change when GET-IT LTER-Italy will be installed
      if (input$sosHost == 'http://getit.lteritalia.it') {
        # provide the token of GET-IT LTER-italy
        tokenSOS <- paste0('Authorization = Token ', 'aayhb2087npouKKKaiu')
        response <- httr::POST(url = paste0(input$sosHost, '/observations/service'),
                               body = upload_file(xmlFilePath),
                               config = add_headers(c('Content-Type' = 'application/xml', tokenSOS)))
        paste0(response, collapse = '')
      }
      # 
      # if (input$sosHost == 'http://getit.lteritalia.it') {
      #   tokenSOS <- paste0('Token ', 'aayhb2087npouKKKaiu')
      #   response <-
      #     httr::POST(
      #       url = paste0(input$sosHost, '/observations/service'),
      #       body = upload_file(xmlFilePath),
      #       config = add_headers(
      #         c(
      #           'Content-Type' = 'application/xml',
      #           'Authorization' = tokenSOS
      #         )
      #       )
      #     )
      #   cat(paste0(response, collapse = ''))
      # } else {
      # provide the token of CDN
      #   tokenSOS <- paste0('Token ', 'xxxxxxxxxxxx')
      #   response <-
      #     httr::POST(
      #       url = paste0(input$sosHost, '/observations/service'),
      #       body = upload_file(xmlFilePath),
      #       config = add_headers(
      #         c(
      #           'Content-Type' = 'application/xml',
      #           'Authorization' = tokenSOS
      #         )
      #       )
      #     )
      #   paste0(response, collapse = '')
      # }
    }
  })
  
  # start introjs when button is pressed with custom options and events
  observeEvent(input$help,
               introjs(
                 session,
                 options = list(
                   "nextLabel" = "Next →",
                   "prevLabel" = "← Back",
                   "skipLabel" = "Skip"
                 ),
                 events = list("oncomplete" = I('alert("Overview completed.")'))
               ))
  
}

# Run the application
shinyApp(ui, server)
