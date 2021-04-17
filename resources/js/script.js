let titleSwitch = false
let numberSwitch = false
let idSwitch = false

function start() {
    
    const submit = document.querySelector('#btn-submit')
    if (window.location.href.includes('registryWorks')) {
        submit.addEventListener('click', sendUserInputWork)

        const showAllWorks = document.querySelector('#allWorks')
        showAllWorks.addEventListener('click', uncheckAll)
        
        const filterWorks = document.querySelectorAll('input[type="radio"]:not(#allWorks)')
        filterWorks.forEach(checkbox => checkbox.addEventListener('click', uncheckFirstBox))
        
        const sortWorks = document.querySelectorAll('div.item-content')
        sortWorks.forEach(column => column.addEventListener('click', sortTable))
        
        const checkboxes = document.querySelectorAll('input[type="radio"]')
        checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', () => {
                const checkedBoxes = document.querySelectorAll('input[type="radio"]:checked')
                checkedBoxes.forEach(checkbox => {
                    checkbox.removeEventListener('click', checkBox)
                    checkbox.addEventListener('click', uncheckBox)
                })
                const uncheckedBoxes = document.querySelectorAll('input[type="radio"]:not(:checked)')
                uncheckedBoxes.forEach(checkbox => {
                    checkbox.removeEventListener('click', uncheckBox)
                    checkbox.addEventListener('click', checkBox)
                })
            })
        })
    }
    else if (window.location.href.includes('registryPersons')) {
        document.querySelector('#load-icon').style.display = 'none'
        submit.addEventListener('click', sendUserInputPerson)
        console.log(document.getElementById('search-name'))
        document.getElementById('search-name').addEventListener('keydown', (event) => {
            if(event.keyCode == 13) {
                sendUserInputPerson()
                event.preventDefault()
            }
        })
        
        let scrollTop = document.querySelector('.catStickyTop')
        document.addEventListener('scroll', () => {
            if (window.scrollY > '600') {
                scrollTop.style.opacity = 1
                scrollTop.style.pointerEvents = 'auto'
            }
            else {
                scrollTop.style.opacity = 0;
                scrollTop.style.pointerEvents = 'none'
            }
        })
        scrollTop.addEventListener('click', () => {
                    window.scrollTo(0, 100);
        })
    }
}

function sendUserInputWork() {
    const searchTerm = document.querySelector('#freitextsuche').value
    const collection = document.querySelector('#choose').checked
    const url = `/exist/apps/silcherWerkverzeichnis/searchWork?searchTerm=${searchTerm}%26collection=${collection}`
    const searchResults = document.querySelector('#searchResults')
    fetch(url)
        .then(response => response.text())
        .then(data => {
            searchResults.innerHTML = data
            applyFilter()
        })
        .catch(error => console.error(error))
}

function sendUserInputPerson() {
    console.log('aaa')
    const searchTerm = document.querySelector('#search-name').value
    const relation = document.querySelector('#dropdown').value
    const url = `/exist/apps/silcherWerkverzeichnis/searchPerson?searchTerm=${searchTerm}%26relation=${relation}`
    const searchResults = document.querySelector('#searchResults')
    const cards = document.querySelectorAll('.card')
    cards.forEach(card => card.style.opacity = 0)
    const loadIcon = document.querySelector('#load-icon')
    loadIcon.style.display = 'block'
    fetch(url)
        .then(response => response.text())
        .then(data => {
            cards.forEach(card => card.style.opacity = 1)
            loadIcon.style.display = 'none'
            searchResults.innerHTML = data
            countRows()
        })
        .catch(error => console.error(error))
}

function applyFilter() {
    const dropdown = document.querySelector('#dropdown')
    const allWorks = document.querySelector('#allWorks')
    let param = []
    
    const choose = document.querySelector('#choose')
    if (choose.checked) {
        param.push('collection')
    } else {
        param.push('individualWork')
    }
    
    /*if (allWorks.checked && dropdown.value == 'all') {
        const shownWorks = document.querySelectorAll('.table tbody tr')
        shownWorks.forEach(work => work.setAttribute('style', 'display: visible'))
    }*/
    if (allWorks.checked && dropdown.value != 'all') {
        param.push(dropdown.value)
        filterWorklist(param)
    }
    else {
        const checked = document.querySelectorAll('input[type="radio"]:checked')
        checked.forEach(checkbox => param.push(checkbox.value))
        if (dropdown.value != 'all') {
            param.push(dropdown.value)
        }
        filterWorklist(param)
    }
    countRows()
}

function uncheckAll() {
    const checkboxes = document.querySelectorAll('input[type="radio"]:not(#allWorks)')
    checkboxes.forEach(checkbox => checkbox.checked = false)
}

function uncheckFirstBox() {
    const allWorks = document.querySelector('input#allWorks')
    allWorks.checked = false
}

function checkBox(event) {
    const boxClicked = event.target
    boxClicked.checked = true
    boxClicked.addEventListener('click', uncheckBox)
}

function uncheckBox(event) {
    const boxClicked = event.target
    let checked = 0
    const checkedBoxes = document.querySelectorAll('input[type="radio"]:checked')
    checkedBoxes.forEach(checkbox => checked++)
    if (checked > 1) {
        boxClicked.checked = false
        boxClicked.addEventListener('click', checkBox)
    }
}

function filterWorklist(param) {
    const class1 = param[0]
    let shownWorks
    let invisibleWorks
    if (param.length == 1) {
        shownWorks = document.querySelectorAll('.table tbody tr.' + CSS.escape(class1))
        invisibleWorks = document.querySelectorAll('.table tbody tr:not(.' + CSS.escape(class1) + ')')
    }
    if (param.length == 2) {
        const class2 = param[1];
        shownWorks = document.querySelectorAll('.table tbody tr.' + CSS.escape(class1) + '.' + CSS.escape(class2))
        invisibleWorks = document.querySelectorAll('.table tbody tr:not(.' + CSS.escape(class1) + '.' + CSS.escape(class2) + ')')
    }
    if (param.length == 3) {
        const class2 = param[1];
        const class3 = param[2];
        shownWorks = document.querySelectorAll('.table tbody tr.' + CSS.escape(class1) + '.' + CSS.escape(class2) + '.' + CSS.escape(class3))
        invisibleWorks = document.querySelectorAll('.table tbody tr:not(.' + CSS.escape(class1) + '.' + CSS.escape(class2) + '.' + CSS.escape(class3) + ')')
    }
    if (param.length == 4) {
        const class2 = param[1];
        const class3 = param[2];
        const class4 = param[3];
        shownWorks = document.querySelectorAll('.table tbody tr.' + CSS.escape(class1) + '.' + CSS.escape(class2) + '.' + CSS.escape(class3) + '.' + CSS.escape(class4))
        invisibleWorks = document.querySelectorAll('.table tbody tr:not(.' + CSS.escape(class1) + '.' + CSS.escape(class2) + '.' + CSS.escape(class3) + '.' + CSS.escape(class4) + ')')
    }
    shownWorks.forEach(work => work.setAttribute('style', 'display: visible'))
    invisibleWorks.forEach(work => work.setAttribute('style', 'display: none'))
}

function countRows() {
    let selectedWorks
    if (window.location.href.includes('registryWorks')) {
        selectedWorks = document.querySelectorAll('.table tbody tr[style = "display: visible"]')
    }
    else if (window.location.href.includes('registryPersons')) {
        selectedWorks = document.querySelectorAll('div.card')
    }
    const number = selectedWorks.length
    const div = document.querySelector('#countScore')
    if (div.hasChildNodes()) {
        div.removeChild(div.lastChild)
    }
    const count = document.createElement('div')
    count.id = 'searchCount'
    count.textContent = `Die Suche ergab ${number} Treffer.`
    div.appendChild(count)
}

function sortTable(event) {
    
    //for each table row create an object with its data and store it into an array
    let sortItems = []
    const sortContainer = document.querySelector('#searchResults')
    const rows = document.querySelectorAll('#searchResults > tr')
    rows.forEach(row => {
        const number = row.children.item(0).textContent
        const title = row.children.item(1).textContent
        const id = row.children.item(2).textContent
        sortItems.push({ elt: row, number: number, title: title, id: id })
    })
    
    //sort alphabetically or by number according to the clicked column
    if (event.target.parentElement.id === 'sort-title') {
        //call function sortData() with callback-function as argument
        sortData((a, b) => {
            if (!titleSwitch) {
                if (b.title > a.title) return -1
                else return 1
            } else {
                if (b.title < a.title) return -1
                else return 1
            }
        })
        titleSwitch = !titleSwitch
    }
    else if (event.target.parentElement.id === 'sort-number') {
        //sort by Opus Number
        sortData((a, b) => {
            a = a.number.split(/[\s,]/)[1]
            b = b.number.split(/[\s,]/)[1]
            if (!numberSwitch) return a - b
            else return b - a
        })
        //group all rows with the same Opus Number
        const grouped = groupBy(sortItems, item => item.number.split(/[\s,]/)[1]);
        //sort by Work Number inside every Opus group
        grouped.forEach((value, key) => {
            sortItems = value
            sortData((a, b) => {
                a = a.number.split(/[\s,]/)[4]
                b = b.number.split(/[\s,]/)[4]
                if (!numberSwitch) return a - b
                else return b - a
            })
        })
        numberSwitch = !numberSwitch
    }
    else if (event.target.parentElement.id === 'sort-id') {
        sortData((a, b) => {
            a = Number(Number(a.id.split('_')[1]) + a.id.split('_')[2])
            b = Number(Number(b.id.split('_')[1]) + b.id.split('_')[2])
            if (!idSwitch) return a - b
            else return b - a
        })
        idSwitch = !idSwitch
    }
    
    //sort-function
    function sortData(compare) {
        //delete all rows
        for (let item of sortItems) {
            item.elt.remove()
        }
        //compare items and rebuilt sorted table
        sortItems.sort(compare)
        for (let item of sortItems) {
            sortContainer.append(item.elt)
        }
    }
    
    //grouping function
    function groupBy(list, keyGetter) {
        const map = new Map();
        list.forEach((item) => {
             const key = keyGetter(item);
             const collection = map.get(key);
             if (!collection) {
                 map.set(key, [item]);
             } else {
                 collection.push(item);
             }
        });
        return map;
    }
}

addEventListener('load', start);