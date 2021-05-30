import 'https://www.verovio.org/javascript/app/verovio-app.js'

// Create the app
const app = new Verovio.App(document.getElementById("app"), {defaultZoom: 3})

//Get workId
const url = window.location.href.split("/")
const work = url[url.length - 1]

//Make request and load the returned file
const mei = `http://localhost:8080/exist/apps/silcherWerkverzeichnis/data/works/${work}.xml`
fetch(mei)
    .then(response => response.text())
    .then(text => app.loadData(text))