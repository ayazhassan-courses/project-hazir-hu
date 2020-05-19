const functions = require('firebase-functions');
const fetch = require("node-fetch");
const admin = require('firebase-admin');
const runtimeOpts = {
    timeoutSeconds: 540,
    memory: '512MB'
}

admin.initializeApp();
let db = admin.firestore();


// this function will be used to get new user data, it returns json response
// if user's data has been added to database : { status : "data updated"  }
// if invalid credentials : { status : 'invalid credentials' }
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
                db.collection('users').doc(huid).update({ lastupdated: apiData.last_updated })
                response.send({
                    status: 'data updated'
                })
            });
    } catch (err) {
        response.send({
            status: 'invalid credentials'
        })
    }
});


// this is a login function
// response: if user exists: { status : ''user already exists'' }
// if user does not exists: {status : 'user added', name = 'user name' }
// if new user fails login check : {status : 'invalid credentials' }
// if network error : { status : 'network error }
// if anyother error : { status: 'something is wrong'}

exports.login = functions.https.onRequest(async(request, response) => {

    const huid = request.query.huid;
    const pass = request.query.pass;
    const token = request.query.token;
    let userExists = false;
    const logincheckUrl = `https://hazirapi.herokuapp.com/logincheck?id=${huid}&pwd=${pass}`
    let loginCheck = false;
    const userdata = {
        huid: huid,
        pass: pass,
        token: token
    }

    let UserRef = db.collection('users');
    let userDoc = await UserRef.get()
        .then(snapshot => {
            snapshot.forEach(doc => {
                if (doc.id == userdata.huid) {
                    userExists = true;
                }
            });
        })


    if (userExists === false) {

        try {
            await fetch(logincheckUrl)
                .then(apiData => apiData.json())
                .then(apiData => {
                    if (apiData.status == 'success') {
                        loginCheck = true
                        let userName = apiData.name
                    } else if (apiData.status == 'invalid credentials') {
                        response.send({
                            status: 'invalid credentials'
                        })
                    }
                });
        } catch (err) {
            response.send({
                status: 'network error'
            })
        }

        if (loginCheck == true) {
            var newUserReq = admin.database().ref('/users').push(userdata);
            var userUniqueKey = newUserReq.key;
            userdata['key'] = userUniqueKey
            db.collection('users').doc(userdata.huid).set(userdata)
            response.send({
                status: 'user added',
                name: userName
            })
        } else {
            response.send({
                status: 'something is wrong'
            })
        }
    } else {
        response.send({
            status: 'user already exists'
        })
    }
});

// schedule function
// this is not a callable function
// this will update all the user's data that is outdated for more than 3 hours
// error handling responses can be found in function logs.
exports.scheduledFunction = functions.runWith(runtimeOpts).pubsub.schedule('every 20 minutes').onRun(async(context) => {


    let usertoUpdate = [];
    const currentTime = Date.now()

    let UserRef = db.collection('users');
    let userDoc = await UserRef.get()
        .then(snapshot => {
            snapshot.forEach(doc => {
                if (usertoUpdate.length < 26) {
                    usertoUpdate.push(doc.data())
                }
            });
        })

    console.log(usertoUpdate)

    if (usertoUpdate.length > 0) {
        for (const eachUser of usertoUpdate) {
            const userlastupdatedTime = eachUser.lastupdated
            const timeDifference = currentTime - userlastupdatedTime
            const huid = eachUser.huid
            const pass = eachUser.pass
            const userKey = eachUser.key
            const url = `https://hazirapi.herokuapp.com/login?id=${huid}&pwd=${pass}`

            if (timeDifference > 180) {
                try {
                    await fetch(url)
                        .then(apiData => apiData.json())
                        .then(apiData => {
                            admin.database().ref(`/users/${userKey}`).set(apiData);
                            db.collection('users').doc(huid).update({ lastupdated: apiData.last_updated })
                            console.log(`Data updated for user: ${huid}`)
                        });
                } catch (err) {
                    console.log(`Failed to update ${huid}`)
                }
            }
        }

    } else {
        console.log('All users are upto date')
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