const {onCall} = require("firebase-functions/v2/https");
const functions = require("firebase-functions/v1");


const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.postchat = onCall(async (request) => {
  const from = request.data.from;
  const message = request.data.message;
  const time = request.data.time;
  const room = request.data.room;

  const path = "Rooms/" + room;
  const roomRef = db.doc(path);

  const newItem = {from: from, message: message, room: roomRef, time: time};
  try {
    await db.collection("Chats").add(newItem);
  } catch (error) {
    console.log(error);
  }

  return {data: true};
});

exports.createRoom = onCall(async (request) => {
  const name = request.data.name;
  const timestamp = new Date();

  const uid = request.auth.uid;
  const userPath = "Users/" + uid;
  const userRef = db.doc(userPath);

  const newItem = {createdAt: timestamp,
    name: name,
    calibratedUsers: 0,
    totalUsers: 1};

  try {
    const ref = await db.collection("Rooms").add(newItem);
    const path = ref.path;
    const connectItem = {room: ref,
      timeDifference: 0,
      user: userRef,
      calibrated: false};
    await db.collection("User_rooms").add(connectItem);
    return {value: path, result: true};
  } catch (error) {
    console.log(error);
  }

  return {result: false};
});

exports.joinRoom = onCall(async (request) => {
  const room = request.data.room;
  const path = "Rooms/" + room;
  const roomRef = db.doc(path);

  let roomName = "";

  const docSnap = await roomRef.get();
  if (docSnap.exists) {
    const data = docSnap.data();
    roomName = data["name"];
    const totalUsers = data["totalUsers"] + 1;
    try {
      await docSnap.ref.update({"totalUsers": totalUsers});
    } catch (error) {
      console.log(error);
      return {result: false};
    }
  } else {
    console.log("Document does not exist");
    return {result: false};
  }

  const uid = request.auth.uid;
  const userPath = "Users/" + uid;
  const userRef = db.doc(userPath);

  const username = (await userRef.get()).data()["username"];

  const connectItem = {room: roomRef,
    timeDifference: 0,
    user: userRef,
    calibrated: false};
  const joinMesasge = {from: "ChatManager@test.com",
    message: `User ${username} has joined the room`,
    room: roomRef,
    time: Date.now() / 1000};
  try {
    await db.collection("User_rooms").add(connectItem);
    await db.collection("Chats").add(joinMesasge);
    return {name: roomName, result: true};
  } catch (error) {
    console.log(error);
  }

  return {result: false};
});

exports.getRooms1 = onCall(async (request) => {
  const uid = request.auth.uid;
  const userPath = "Users/" + uid;
  const userRef = db.doc(userPath);

  const querySnapshot = await db.collection("User_rooms")
      .where("user", "==", userRef).get();
  if (querySnapshot.empty) {
    console.log("No documents");
    return {};
  }

  const returnArray = [];

  for (const doc of querySnapshot.docs) {
    const data = doc.data();
    const room = data["room"];

    const docSnap = await room.get();
    if (docSnap.exists) {
      const snapData = docSnap.data();
      const roomName = snapData["name"];
      const obj = {room: room.path, name: roomName};
      returnArray.push(obj);
    }
  }

  return {data: returnArray};
});

exports.leaveRoom = onCall(async (request) => {
  const room = request.data.room;
  const roomPath = "Rooms/" + room;
  const roomRef = db.doc(roomPath);

  const uid = request.auth.uid;
  const userPath = "Users/" + uid;
  const userRef = db.doc(userPath);

  const querySnapshot = await db.collection("User_rooms")
      .where("user", "==", userRef)
      .where("room", "==", roomRef).get();

  if (querySnapshot.empty) {
    console.log("No documents");
    return {result: false};
  }

  const data = querySnapshot.docs[0].data();
  const isCalibrated = data["calibrated"];
  await querySnapshot.docs[0].ref.delete();

  const docSnap = await roomRef.get();
  let totalUsers = 1;
  if (docSnap.exists) {
    const data = docSnap.data();
    totalUsers = data["totalUsers"] - 1;
    let calibratedUsers = data["calibratedUsers"];
    if (isCalibrated) {
      --calibratedUsers;
    }
    try {
      docSnap.ref.update({"totalUsers": totalUsers,
        "calibratedUsers": calibratedUsers});
      const username = (await userRef.get()).data()["username"];
      const leaveMesasge = {from: "ChatManager@test.com",
        message: `User ${username} has left the room`,
        room: roomRef,
        time: Date.now() / 1000};
      await db.collection("Chats").add(leaveMesasge);
    } catch (error) {
      console.log(error);
      return {result: false};
    }
  } else {
    console.log("Document does not exist");
  }

  if (totalUsers == 0) {
    // delete chats
    const chatsSnapshot = await db.collection("Chats")
        .where("room", "==", roomRef)
        .get();
    for (const doc of chatsSnapshot.docs) {
      try {
        await doc.ref.delete();
      } catch (error) {
        console.log(error);
      }
    }

    const calibrationsSnapshot = await db.collection("calibrations")
        .where("room", "==", roomRef)
        .get();
    for (const doc of calibrationsSnapshot.docs) {
      try {
        await doc.ref.delete();
      } catch (error) {
        console.log(error);
      }
    }

    try {
      await roomRef.delete();
    } catch (error) {
      console.log(error);
    }
  }

  return {result: true};
});

exports.createCalibration = onCall(async (request) => {
  const room = request.data.room;
  const roomPath = "Rooms/" + room;
  const roomRef = db.doc(roomPath);

  const uid = request.auth.uid;
  const userPath = "Users/" + uid;
  const userRef = db.doc(userPath);
  const event = request.data.event;

  const testSnapshot = await db.collection("calibrations")
      .where("room", "==", roomRef)
      .where("event", "==", event)
      .get();
  if (testSnapshot.docs.length > 0) {
    // already a calibration with the same name
    return {result: false};
  }

  const userSnapshot = await db.collection("User_rooms")
      .where("room", "==", roomRef)
      .where("user", "==", userRef)
      .get();

  if (userSnapshot.docs.length == 1) {
    const data = userSnapshot.docs[0].data();
    const isUserAbsolute = data["calibrated"];
    if (isUserAbsolute) {
      const roomDoc = await roomRef.get();
      const calibratedUsers = roomDoc.data()["calibratedUsers"];
      try {
        roomRef.update({"calibratedUsers": calibratedUsers - 1});
        userSnapshot.docs[0].ref.update({"calibrated": false});
      } catch (error) {
        console.log(error);
      }
    }
  } else {
    console.log(`Total number of documents is ${userSnapshot.length} not one`);
  }

  const item = {room: roomRef,
    userCalibrations: [],
    event: event,
    absolute: false};

  try {
    await db.collection("calibrations").add(item);
  } catch (error) {
    return {result: false};
  }

  return {result: true};
});

exports.calibrateUser = onCall(async (request) => {
  const room = request.data.room;
  const roomPath = "Rooms/" + room;
  const roomRef = db.doc(roomPath);

  const uid = request.auth.uid;
  const userPath = "Users/" + uid;
  const userRef = db.doc(userPath);

  const roomDoc = await roomRef.get();
  let calibratedUsers = roomDoc.data()["calibratedUsers"];
  const totalUsers = roomDoc.data()["totalUsers"];

  const userSnapshot = await db.collection("User_rooms")
      .where("room", "==", roomRef)
      .where("user", "==", userRef)
      .get();

  if (userSnapshot.docs.length != 1) {
    return {success: false};
  }

  const connecterRef = userSnapshot.docs[0].ref;
  const userData = userSnapshot.docs[0].data();
  const isUserAbsolute = userData["calibrated"];

  const event = request.data.event;
  const userTime = request.data.time;

  const querySnapshot = await db.collection("calibrations")
      .where("room", "==", roomRef)
      .where("event", "==", event)
      .get();

  if (querySnapshot.docs.length == 0) {
    return {success: false};
  }

  let returnObj = {success: false, offset: 0, message: "fell through"};
  const doc = querySnapshot.docs[0];
  const data = doc.data();
  const isRoomAbsolute = data["absolute"];
  const arr = data["userCalibrations"] || [];

  if (calibratedUsers == 0) {
    // user is first to calibrate, orientate around user
    try {
      await connecterRef.update({"calibrated": true, "timeDifference": 0});
      await roomRef.update({"calibratedUsers": 1});
      ++calibratedUsers;
      await doc.ref.update({"absolute": true,
        "userCalibrations": [{time: userTime,
          user: userRef,
          diff: 0,
          whereToUpdate: connecterRef}]});
    } catch (error) {
      console.log(error);
    }
    returnObj = {success: true, offset: 0, message: "case 0 - user is first"};
  } else if (isRoomAbsolute && isUserAbsolute) {
    // user is calibrated and calibration is absolute, just return
    returnObj = {success: true,
      offset: 0,
      message: "case 1 - already up to date"};
    return returnObj;
  } else if (isRoomAbsolute) {
    // calibration is absolue but user not calibrated
    // base calibration on first user
    const first = arr[0];
    const firstTime = first["time"];
    const firstDiff = first["diff"];
    const userDiff = userTime - firstTime + firstDiff;
    try {
      await connecterRef.update({"calibrated": true,
        "timeDifference": userDiff});
      ++calibratedUsers;
      await roomRef.update({"calibratedUsers": calibratedUsers});
    } catch (error) {
      console.log(error);
    }
    returnObj = {success: true, offset: userDiff,
      message: "case 2 - user got calibrated"};
  } else if (!isRoomAbsolute && isUserAbsolute) {
    // calibration not absolute but user is calibrated, set array to user
    // iterate over whole array basing calibration on user
    const userTimeDifference = userData["timeDifference"];
    try {
      doc.ref.update({"absolute": true});
    } catch (error) {
      console.log(error);
    }

    for (let i = 0; i < arr.length; ++i) {
      const arrDiff = arr[i]["time"] - userTime + userTimeDifference;

      const updateRef = arr[i]["whereToUpdate"];
      const whereToUpdateDoc = await updateRef.get();
      const whereToUpdateData = whereToUpdateDoc.data()["calibrated"];

      if (whereToUpdateData == false) {
        ++calibratedUsers;
        try {
          await updateRef.update({"calibrated": true,
            "timeDifference": arrDiff});
        } catch (error) {
          console.log(error);
        }
      }
    }
    try {
      await roomRef.update({"calibratedUsers": calibratedUsers});
      await doc.ref.update({"userCalibrations": [{time: userTime,
        user: userRef,
        diff: userTimeDifference,
        whereToUpdate: connecterRef}]});
    } catch (error) {
      console.log(error);
    }

    returnObj = {success: true, offset: userTimeDifference, message: "case 3"};
  } else {
    // calibration not absolute and user not calibrates, just add user to array
    for (const obj of arr) {
      if (obj["user"].path == userRef.path) {
        const returnObj = {success: true,
          offset: 0,
          message: "case 4 special - user already in array"};
        return returnObj;
      }
    }
    const obj = {time: userTime,
      user: userRef,
      diff: 0,
      whereToUpdate: connecterRef};
    arr.push(obj);
    try {
      await doc.ref.update({"userCalibrations": arr});
    } catch (error) {
      console.log(error);
    }
    returnObj = {success: true,
      offset: 0,
      message: "case 4 - user added to array"};
    return returnObj;
  }

  if (calibratedUsers == totalUsers) {
    const deletingSnapshot = await db.collection("calibrations")
        .where("room", "==", roomRef)
        .get();

    for (const deleteDoc of deletingSnapshot.docs) {
      try {
        await deleteDoc.ref.delete();
      } catch (error) {
        console.log(error);
      }
    }
  }

  return returnObj;
});

exports.newUser = functions.auth.user().onCreate(async (user) => {
  const path = "Users/" + user.uid;
  const ref = db.doc(path);
  const username = user.email.slice(- user.email.length, -9);
  const item = {email: user.email, username: username};

  try {
    await ref.set(item);
  } catch (error) {
    console.log(error);
  }
});
