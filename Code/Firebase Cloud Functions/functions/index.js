const functions = require('firebase-functions');
const fetch = require("node-fetch");
const admin = require('firebase-admin');
const runtimeOpts = {
    timeoutSeconds: 540,
    memory: '512MB'
}

admin.initializeApp();
let db = admin.firestore();


exports.getData = functions.https.onRequest(async(request, response) => {

    const huid = request.query.huid;
    const pass = request.query.pass;
    const url = `https://hazirapi.herokuapp.com/login?id=${huid}&pwd=${pass}`

    try {
        fetch(url)
            .then(apiData => apiData.json())
            .then(apiData => {
                var newUserReq = admin.database().ref('/users')
                newUserReq.child(huid).set(apiData)
                var normalDate = new Date(0); // The 0 there is the key, which sets the date to the epoch
                normalDate.setUTCSeconds(apiData.last_updated);
                db.collection('users').doc(huid).update({ lastupdated: normalDate })
                let userToken = db.collection('users').doc(huid).get()
                    .then(doc => {
                        admin.database().ref(`/users/${huid}`).update({ token: doc.data().token, password: doc.data().pass });
                    })
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

exports.changePass = functions.https.onRequest(async(request, response) => {

    const huid = request.query.huid;
    const newPass = request.query.pass;
    const logincheckUrl = `https://hazirapi.herokuapp.com/logincheck?id=${huid}&pwd=${newPass}`
    let loginCheck = false;

    try {
        await fetch(logincheckUrl)
            .then(apiData => apiData.json())
            .then(apiData => {
                if (apiData.status == 'success') {
                    loginCheck = true
                    userName = apiData.name
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
        db.collection('users').doc(userdata.huid).update({ pass: newPass })
        admin.database().ref(`/users/${huid}`).update({ password: newPass })
    }


})

exports.login = functions.https.onRequest(async(request, response) => {

    const huid = request.query.huid;
    const pass = request.query.pass;
    const token = request.query.token;
    let userExists = false;
    let userName = '';
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
                if (doc.id == userdata.huid && doc.data().pass == userdata.pass) {
                    userExists = true;
                }
            });
        })


    if (userExists == false) {

        try {
            await fetch(logincheckUrl)
                .then(apiData => apiData.json())
                .then(apiData => {
                    if (apiData.status == 'success') {
                        loginCheck = true
                        userName = apiData.name
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
            db.collection('users').doc(userdata.huid).set(userdata)
            response.send({
                status: 'user added',
                name: userName
            })
        }
    } else {
        response.send({
            status: 'user already exists'
        })
    }
});

// schedule function
exports.dataUpdateprocess = functions.runWith(runtimeOpts).pubsub.schedule('every 12 hours').onRun(async(context) => {


    let usertoUpdate = [];
    const currentTime = Date.now()
    let userlastupdatedTime = null;
    let huid = null;
    let pass = null;
    let token = null;

    let UserRef = db.collection('users');
    let userDoc = await UserRef.get()
        .then(snapshot => {
            snapshot.forEach(doc => {
                userlastupdatedTime = doc.data().lastupdated
                const timeDifference = currentTime - userlastupdatedTime

                if (usertoUpdate.length < 26 && timeDifference > 180) {
                    usertoUpdate.push(doc.data())
                }
            });
        })

    console.log(usertoUpdate)

    if (usertoUpdate.length > 0) {
        for (const eachUser of usertoUpdate) {

            huid = eachUser.huid
            pass = eachUser.pass
            token = eachUser.token
            let Name = null;
            let userLoginCheck = false;

            const loginCheckUrl = `https://hazirapi.herokuapp.com/logincheck?id=${huid}&pwd=${pass}`
            const url = `https://hazirapi.herokuapp.com/login?id=${huid}&pwd=${pass}`

            await fetch(loginCheckUrl)
                .then(apiData => apiData.json())
                .then(apiData => {
                    if (apiData.status == 'success') {
                        userLoginCheck = true
                        Name = apiData.name
                    }
                });

            if (userLoginCheck == false) {
                try {
                    await fetch(url)
                        .then(apiData => apiData.json())
                        .then(apiData => {
                            admin.database().ref(`/users/${huid}`).set(apiData);
                            db.collection('users').doc(huid).update({ lastupdated: apiData.last_updated })
                            console.log(`Data updated for user: ${huid}`)
                        });
                } catch (err) {
                    console.log(`Failed to update ${huid}`)
                }
            } else {
                var message = {
                    notification: {
                        title: 'Invalid Password',
                        body: `${Name} your password is outdated. Failed to update. `
                    },
                    data: {
                        coursename: coursename,
                        date: date,
                    },
                    token: token,
                };
                db.collection('notifications').doc(huid).collection('notifications').doc().set(message);
                admin.messaging().send(message)
                    .then((res) => {
                        console.log('Notification sent successfully:', res)
                    })
                    .catch((err) => {
                        console.log('Notification sent failed:', err)
                    });
            }

        }
    }
});



// exports.generateNotifications = functions.https.onRequest((request, response) => {
//     //request parameters
//     const userid = request.query.userid;
//     const token = request.query.token;
//     const type = request.query.type;
//     const coursename = request.query.coursename;
//     const date = request.query.date;

//     if (type == 'absent') {
//         var message = {
//             notification: {
//                 title: 'Absent Notification',
//                 body: `You were absent on ${date} in ${coursename}.`
//             },
//             data: {
//                 coursename: coursename,
//                 date: date,
//             },
//             token: token,
//         };

//         db.collection('notifications').doc(userid).collection('notifications').doc().set(message);
//         admin.messaging().send(message)
//             .then((res) => {
//                 response.send({
//                     status: 'Message sent sucessfully',
//                 })
//             })
//             .catch((error) => {
//                 response.send({
//                     status: 'Failed to send message',
//                 });
//             });
//     }
// });

exports.makeUppercase = functions.database.ref(`/users/{updatingUser}`)
    .onUpdate((change, context) => {


        prevData = change.before.val() // JS object
        updatedData = change.after.val() // JS object
        const huid = updatedData.id
        const token = updatedData.token
        const oldDataKeys = Object.keys(prevData.coursedata) // list of keys
        const newDataKeys = Object.keys(updatedData.coursedata) // list of keys
        let date = '';
        let courseName = '';
        let formatedDate = '';

        console.log('func is working')
        for (eachCourse = 0; eachCourse < newDataKeys.length; eachCourse++) {

            //  absent check and generate notification
            if (prevData.coursedata[eachCourse].absentclasses < updatedData.coursedata[eachCourse].absentclasses) {
                const insideCourse = updatedData.coursedata[eachCourse]
                courseName = insideCourse.coursename
                for (absentDate = 0; absentDate < insideCourse.attendances.length; absentDate++) {
                    if (insideCourse.attendances[absentDate].Status == 'Absent') {
                        date = insideCourse.attendances[absentDate].Date
                        let formatDate = new Date(date)
                        let mainDate = String(formatDate).split(' ').slice(0, 4)
                        formatedDate = ''.concat(mainDate[0], ' ', mainDate[1], ' ', mainDate[2], ' ', mainDate[3])
                    }
                }
                var message = {
                    notification: {
                        title: 'Absent Notification',
                        body: `You were absent on ${formatedDate} in ${courseName}.`
                    },
                    data: {
                        coursename: courseName,
                        date: date,
                    },
                    token: token,
                }
            }

            // present check and generate notification
            if (prevData.coursedata[eachCourse].presentclasses < updatedData.coursedata[eachCourse].presentclasses) {
                const insideCourse = updatedData.coursedata[eachCourse]
                courseName = insideCourse.coursename
                for (presentDate = 0; presentDate < insideCourse.attendances.length; presentDate++) {
                    if (insideCourse.attendances[presentDate].Status == 'Present') {
                        date = insideCourse.attendances[presentDate].Date
                        let formatDate = new Date(date)
                        let mainDate = String(formatDate).split(' ').slice(0, 4)
                        formatedDate = ''.concat(mainDate[0], ' ', mainDate[1], ' ', mainDate[2], ' ', mainDate[3])
                    }
                }
                var message = {
                    notification: {
                        title: 'Present Notification',
                        body: `You were present on ${formatedDate} in ${courseName}`
                    },
                    data: {
                        coursename: courseName,
                        date: date,
                    },
                    token: token,
                }
            }
        }

        console.log(message)
        db.collection('notifications').doc(huid).collection('notifications').doc().set(message);
        admin.messaging().send(message)
            .then((res) => {
                console.log('Notification sent successfully:', res)
            })
            .catch((err) => {
                console.log('Notification sent failed:', err)
            });
        return null
    });
