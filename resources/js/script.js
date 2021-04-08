
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
        submit.addEventListener('click', sendUserInputPerson)
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
    const searchTerm = document.querySelector('#search-name').value
    const relation = document.querySelector('#dropdown').value
    const url = `/exist/apps/silcherWerkverzeichnis/searchPerson?searchTerm=${searchTerm}%26relation=${relation}`
    const searchResults = document.querySelector('#searchResults')
    fetch(url)
        .then(response => response.text())
        .then(data => {
            searchResults.innerHTML = data,
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
};

function sortTable(event) {
    let table, rows, switching, i, n, x, y, shouldSwitch, dir, switchcount = 0;
    let id = event.target.parentElement.id
    console.log(id)
    if (id == 'sort-number') {n = 0}
    else if (id == 'sort-title') {n = 1}
    else if (id == 'sort-id') {n = 2}
    console.log(n)
    table = document.getElementById("searchResults");
    switching = true;
    //Set the sorting direction to ascending:
    dir = "asc"; 
    /*Make a loop that will continue until no switching has been done:*/
    while (switching) {
        //start by saying: no switching is done:
        switching = false;
        rows = table.rows;
        /*Loop through all table rows (except the first, which contains table headers):*/
        for (i = 0; i < (rows.length - 1); i++) {
            //start by saying there should be no switching:
            shouldSwitch = false;
            /*Get the two elements you want to compare, one from current row and one from the next:*/
            x = rows[i].getElementsByTagName("TD")[n];
            y = rows[i + 1].getElementsByTagName("TD")[n];
            /*check if the two rows should switch place, based on the direction, asc or desc:*/
            if (n == 0) {
                xSubstringStart = x.innerText.substring(0, 3)
                ySubstringStart = y.innerText.substring(0, 3)
                xSubstringOpus = x.innerText.substring(5, x.innerText.indexOf(','))
                ySubstringOpus = y.innerText.substring(5, y.innerText.indexOf(','))
                xSubstringNumber = x.innerText.substring(x.innerText.lastIndexOf(' '))
                ySubstringNumber = y.innerText.substring(y.innerText.lastIndexOf(' '))
                if (dir == "asc") {
                    if (xSubstringStart.toLowerCase() > ySubstringStart.toLowerCase()) {
                        //if so, mark as a switch and break the loop:
                        shouldSwitch= true;
                        break;
                    }
                    else if (xSubstringStart.toLowerCase() == ySubstringStart.toLowerCase()) {
                        if (Number(xSubstringOpus) > Number(ySubstringOpus)) {
                            //if so, mark as a switch and break the loop:
                            shouldSwitch = true;
                            break;
                        }
                        else if (Number(xSubstringOpus) == Number(ySubstringOpus)) {
                            if (Number(xSubstringNumber) > Number(ySubstringNumber)) {
                                //if so, mark as a switch and break the loop:
                                shouldSwitch = true;
                                break;
                            }
                        }
                    }
                }
                else if (dir == "desc") {
                    if (xSubstringStart.toLowerCase() < ySubstringStart.toLowerCase()) {
                        //if so, mark as a switch and break the loop:
                        shouldSwitch= true;
                        break;
                    }
                    else if (xSubstringStart.toLowerCase() == ySubstringStart.toLowerCase()) {
                        if (Number(xSubstringOpus) < Number(ySubstringOpus)) {
                            //if so, mark as a switch and break the loop:
                            shouldSwitch = true;
                            break;
                        }
                        else if (Number(xSubstringOpus) == Number(ySubstringOpus)) {
                            if (Number(xSubstringNumber) < Number(ySubstringNumber)) {
                                //if so, mark as a switch and break the loop:
                                shouldSwitch = true;
                                break;
                            }
                        }
                    }
                }
            }
            if (n == 1) {
                if (dir == "asc") {
                    if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                        //if so, mark as a switch and break the loop:
                        shouldSwitch= true;
                        break;
                    }
                }
                else if (dir == "desc") {
                    if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                        //if so, mark as a switch and break the loop:
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if (n == 2) {
                xSubstringOpus = x.innerText.substr(5, 5)
                ySubstringOpus = y.innerText.substr(5, 5)
                if (dir == "asc") {
                    if (Number(xSubstringOpus) > Number(ySubstringOpus)) {
                        //if so, mark as a switch and break the loop:
                        shouldSwitch = true;
                        break;
                    }
                    else if (Number(xSubstringOpus) == Number(ySubstringOpus)) {
                        xSubstringNumber = x.innerText.substring(x.innerText.length - 3)
                        ySubstringNumber = y.innerText.substring(y.innerText.length - 3)
                        if (Number(xSubstringNumber) > Number(ySubstringNumber)) {
                            //if so, mark as a switch and break the loop:
                            shouldSwitch = true;
                            break;
                        }
                    }
                }
                else if (dir == "desc") {
                    if (Number(xSubstringOpus) < Number(ySubstringOpus)) {
                        //if so, mark as a switch and break the loop:
                        shouldSwitch = true;
                        break;
                    }
                    else if (Number(xSubstringOpus) == Number(ySubstringOpus)) {
                        xSubstringNumber = x.innerText.substring(x.innerText.length - 3)
                        ySubstringNumber = y.innerText.substring(y.innerText.length - 3)
                        if (Number(xSubstringNumber) < Number(ySubstringNumber)) {
                            //if so, mark as a switch and break the loop:
                            shouldSwitch = true;
                            break;
                        }
                    }
                }
            }
        }
        if (shouldSwitch) {
            /*If a switch has been marked, make the switch and mark that a switch has been done:*/
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
            //Each time a switch is done, increase this count by 1:
            switchcount ++;      
        }
        else {
            /*If no switching has been done AND the direction is "asc", set the direction to "desc" and run the while loop again.*/
            if (switchcount == 0 && dir == "asc") {
                dir = "desc";
                switching = true;
            }
        }
    }
};

addEventListener('load', start);