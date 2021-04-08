/* Build OpenSeaDragon Viewer and load in images */

const container = document.querySelector('#facsimile div.viewer')

if (container.id === 'openseadragon2') {
    const uri = container.dataset.url
    const viewer = OpenSeadragon({
        id: "openseadragon2",
        prefixUrl: "../resources/viewer/openseadragon/images/",
        tileSources: uri
    })
}

else if (container.id === 'openseadragon1') {
    const tileSources = []
    const uris = container.dataset.url.split(' ')
    uris.forEach(uri => tileSources.push(uri))
    console.log(tileSources)
    const viewer2 = OpenSeadragon({
        id: "openseadragon1",
        prefixUrl: "../resources/viewer/openseadragon/images/",
        //preserveViewport: true,
        //visibilityRatio: 1,
        minZoomLevel: 0,
        defaultZoomLevel: 0,
        sequenceMode: true,
        tileSources: tileSources
    })
}