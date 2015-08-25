.pragma library

function test() {

}

function findFlickable(item) {
    var parentItem = item.parent
    while (parentItem) {
        if (parentItem.maximumFlickVelocity && !parentItem.hasOwnProperty('__silica_hidden_flickable')) {
            return parentItem
        }
        parentItem = parentItem.parent
    }
    return null
}

function findListView(item) {
    var parentItem = item.parent
    while (parentItem) {
        if (parentItem.maximumFlickVelocity && parentItem.hasOwnProperty("model") && !parentItem.hasOwnProperty('__silica_hidden_flickable')) {
            return parentItem
        }
        parentItem = parentItem.parent
    }
    return null
}

function findPage(item) {
    var parentItem = item.parent
    while (parentItem) {
        if (parentItem.hasOwnProperty('__silica_page')) {
            return parentItem
        }
        parentItem = parentItem.parent
    }
    return null
}
