
function randomString(len, charSet) {
    charSet = charSet || 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var randomString = '';
    for (var i = 0; i < len; i++) {
        var randomPoz = Math.floor(Math.random() * charSet.length);
        randomString += charSet.substring(randomPoz,randomPoz+1);
    }
    return randomString;
}

function updateUser(phone, firstName, middleName, lastName, password) {
    fetch('/users', {
    method: 'put',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
            phone: phone ?? '',
            firstName: randomString(10),
            middleName: middleName ?? '',
            lastName: lastName ?? '',
            password: password ?? '',
        })
    })
    .then(res => {
        if (res.ok) return res.json()
    })
    .then(response => {
        console.log(response)
        location.reload();
    })
}

function deleteUser(phone) {
    fetch('/users', {
    method: 'delete',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone: phone })
    })
    .then(res => {
        if (res.ok) return res.json()
    })
    .then(response => {
        console.log(response)
        location.reload();
    })
}