const functions = require('firebase-functions');
const fetch = require("node-fetch");
const admin = require('firebase-admin');

admin.initializeApp();
let db = admin.firestore();

exports.getData = functions.https.onRequest(async(request, response) => {

    const huid = request.query.huid;
    const pass = request.query.pass;
    const url = `https://hazirapi.herokuapp.com/login?id=${huid}&pwd=${pass}`
    let userKey = '';

    let UserRef = db.collection('users');
    let userDoc = await UserRef.get()
        .then(snapshot => {
            snapshot.forEach(doc => {
                if (doc.id == huid) {
                    userKey = doc.data().key
                }
            });
        })

    try {
        fetch(url)
            .then(apiData => apiData.json())
            .then(apiData => {
                admin.database().ref(`/users/${userKey}`).set(apiData);
                response.send('Success')
            });
    } catch (err) {
        response.send('Error')
    }
});




exports.login = functions.https.onRequest(async(req, res) => {

    const huid = req.query.huid;
    const pass = req.query.pass;
    const token = req.query.token;
    let userExists = false;
    const data = {
        huid: huid,
        pass: pass,
        token: token
    }

    let UserRef = db.collection('users');
    let userDoc = await UserRef.get()
        .then(snapshot => {
            snapshot.forEach(doc => {
                if (doc.id == data.huid) {
                    userExists = true;
                }
            });
        })


    if (userExists === false) {
        var newUserReq = admin.database().ref('/users').push(data);
        var userUniqueKey = newUserReq.key;
        data['key'] = userUniqueKey
        db.collection('users').doc(data.huid).set(data)
        res.send('User Added')
    } else {
        res.send('User Already Exists')
    }
});

exports.generateNotifications = functions.https.onRequest((request, response) => {
    //request parameters
    const userid = request.query.userid;
    const token = request.query.token;
    const type = request.query.type;
    const coursename = request.query.coursename;
    const date = request.query.date;
 
    if (type == 'absent') {
        var message = {
            notification: {
                title: 'Absent Notification',
                body: `You were absent on ${date} in ${coursename}.`
            },
            data: {
                coursename: coursename,
                date: date,
            },
            token: token,
        };

        db.collection('notifications').doc(userid).collection('notifications').doc().set(message);



        admin.messaging().send(message)
            .then((res) => {

                response.send({
                    status: 'Message sent sucessfully',
                })
            })
            .catch((error) => {
                response.send({
                    status: 'Failed to send message',
                });

            });

    }


});



