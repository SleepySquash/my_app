require('dotenv').config();
const express = require('express');
const cors = require('cors');
const multer  = require('multer')
const http = require('http');
const https = require('https');
const fs = require('fs');
const app = express();

const allowUserRegistrationUponRequest = true;
const User = require('./models/User')
const Condition = require('./models/Condition')
const Dyskinesia = require('./models/Dyskinesia')
const Medicine = require('./models/Medicine')
const TestFigure = require('./models/TestFigure')
const TestReport = require('./models/TestReport')
const TestTap = require('./models/TestTap')
const TestText = require('./models/TestText')
const TestVoice = require('./models/TestVoice')

console.log('Connecting to the Database...');
const mongoose = require('mongoose');
mongoose.connect(process.env.CONNECTION_STRING, { useNewUrlParser: true, useUnifiedTopology: true });

const db = mongoose.connection
db.once('open', _ => {
  console.log('Connected!');

  app.set('view engine', 'ejs')
  app.use(cors());
  app.use(express.urlencoded({ extended: true }));
  app.use(express.json({ extended: true }));
  app.use(express.static('public'))

  //////////////////////////////////////////
  // Home
  //////////////////////////////////////////
  app.get('/', (req, res) => res.sendFile(__dirname + '/index.html'));

  //////////////////////////////////////////
  // Testing
  //////////////////////////////////////////
  app.get('/ping', (req, res) => res.sendStatus(200));
  app.post('/post', (req, res) => {
    console.log(req.body);
    res.sendStatus(200);
  })

  var upload = multer({ dest: 'uploads/' })
  app.post('/upload', upload.single("file"), function (req,res) {
    console.log("Received file" + req.file.originalname);
    var src = fs.createReadStream(req.file.path);
    var dest = fs.createWriteStream('uploads/' + req.file.originalname);
    src.pipe(dest);
    src.on('end', function() {
    	fs.unlinkSync(req.file.path);
    	res.json('OK: received ' + req.file.originalname);
    });
    src.on('error', function(err) { res.json('Something went wrong!'); });
  
  })

  //////////////////////////////////////////
  // Users
  //////////////////////////////////////////
  app.get('/users', (req, res) => {
    if (req.query.phone != null) {
      User.findOne({ phone: req.body.phone })
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
    else {
      User.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  app.post('/users', (req, res) => {
    if (req.body.phone == null) return res.status(400).json('Phone must not be null');
    if (req.body.phone.length < 11) return res.status(400).json('Phone must be at least 11 characters long');
    if (req.body.phone.length > 20) return res.status(400).json('Phone must be at most 20 characters long');
    const user = new User({
      phone: req.body.phone,
      firstName: req.body.firstName,
      middleName: req.body.middleName,
      lastName: req.body.lastName,
      password: req.body.password,
    });
    user.save()
    .then(r => res.status(200).json(r))
    .catch(e => res.status(400).json(e));
  })

  app.put('/users', (req, res) => {
    if (req.body.phone == null) return res.status(400).json('Phone must not be null');
    if (req.body.phone.length < 11) return res.status(400).json('Phone must be at least 11 characters long');
    if (req.body.phone.length > 20) return res.status(400).json('Phone must be at most 20 characters long');
    User.findOne({ phone: req.body.phone })
    .then(result => {
      result.firstName = req.body.firstName;
      result.middleName = req.body.middleName;
      result.lastName = req.body.lastName;
      result.password = req.body.password;
      result.save()
      .then(r => res.status(200).json('Success'))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })

  app.delete('/users', (req, res) => {
    if (req.body.phone == null) return res.status(400).json('Phone must not be null');
    User.findOne({ phone: req.body.phone })
    .then(result => {
      result.remove()
      .then(r => res.status(200).json('Success'))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })

  function getUser(phone) {
    return new Promise((resolve, reject) => {
      User.findOne({ phone: phone })
      .then(result => {
        if (result == null) {
          if (!allowUserRegistrationUponRequest)
            reject('Error: no User found with such phone');

          var user = new User({ phone: phone });
          user.save()
          .then(r => resolve(r))
          .catch(e => reject(e));
        }
        else resolve(result);
      })
      .catch(e => reject(e));
    });
  }

  //////////////////////////////////////////
  // Dyskinesia
  //////////////////////////////////////////
  app.get('/dyskinesia', (req, res) => {
    if (req.query.phone != null) {
      getUser(req.query.phone)
      .then(u => {
        Dyskinesia.find({ userId: u._id })
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      })
      .catch(e => res.status(400).json(e))
    }
    else {
      Dyskinesia.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  app.post('/dyskinesia/phone', (req, res) => {
    getUser(req.body.phone)
    .then(u => {
      const dys = new Dyskinesia({ userId: u._id, date: req.body.date });
      dys.save()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })

  //////////////////////////////////////////
  // Medicine
  //////////////////////////////////////////
  app.get('/medicine', (req, res) => {
    if (req.query.phone != null) {
      getUser(req.query.phone)
      .then(u => {
        Medicine.find({ userId: u._id })
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      })
      .catch(e => res.status(400).json(e));
    }
    else {
      Medicine.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  app.post('/medicine/phone', (req, res) => {
    getUser(req.body.phone)
    .then(u => {
      const dys = new Medicine({
        userId: u._id,
        automated: req.body.automated,
        sector: req.body.sector,
        date: req.body.date });
      dys.save()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })

  //////////////////////////////////////////
  // Conditions
  //////////////////////////////////////////
  app.get('/conditions', (req, res) => {
    if (req.query.phone != null) {
      getUser(req.query.phone)
      .then(result => {
        Condition.find({ userId: result._id })
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      })
      .catch(e => res.status(400).json(e));
    }
    else {
      Condition.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  app.post('/conditions/phone', (req, res) => {
    getUser(req.body.phone)
    .then(u => {
      const condition = new Condition({
        userId: u._id,
        state: req.body.state,
        date: req.body.date,
      });
      condition.save()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })

  //////////////////////////////////////////
  // TestFigure
  //////////////////////////////////////////
  app.get('/TestFigure', (req, res) => {
    if (req.query.phone != null) {
      getUser(req.query.phone)
      .then(u => {
        TestFigure.find({ userId: u._id })
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      })
      .catch(e => res.status(400).json(e));
    }
    else {
      TestFigure.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  app.post('/TestFigure/phone', (req, res) => {
    getUser(req.body.phone)
    .then(u => {
      const dys = new TestFigure({
        userId: u._id,
        accuracy: req.body.accuracy,
        figure: req.body.figure,
        date: req.body.date });
      dys.save()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })

  //////////////////////////////////////////
  // TestReport
  //////////////////////////////////////////
  app.get('/TestReport', (req, res) => {
    if (req.query.phone != null) {
      getUser(req.query.phone)
      .then(u => {
        TestReport.find({ userId: u._id })
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      })
      .catch(e => res.status(400).json(e));
    }
    else {
      TestReport.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  app.post('/TestReport/phone', (req, res) => {
    getUser(req.body.phone)
    .then(u => {
      var keys = JSON.parse(req.body.keys);
      var backspaces = req.body.backspaces == '' ? '' : JSON.parse(req.body.backspaces);
      const dys = new TestReport({
        userId: u._id,
        text: req.body.text,
        backspaces: backspaces,
        date: req.body.date });
      keys.forEach(j => dys.keys.push({ pair: j.pair, elapsed: j.elapsed }));
      dys.save()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })

  //////////////////////////////////////////
  // TestText
  //////////////////////////////////////////
  app.get('/TestText', (req, res) => {
    if (req.query.phone != null) {
      getUser(req.query.phone)
      .then(u => {
        TestText.find({ userId: u._id })
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      })
      .catch(e => res.status(400).json(e));
    }
    else {
      TestText.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  app.post('/TestText/phone', (req, res) => {
    getUser(req.body.phone)
    .then(u => {
      var keys = JSON.parse(req.body.keys);
      var backspaces = req.body.backspaces == '' ? '' : JSON.parse(req.body.backspaces);
      const dys = new TestText({
        userId: u._id,
        accuracy: req.body.accuracy,
        backspaces: backspaces,
        date: req.body.date });
      keys.forEach(j => dys.keys.push({ pair: j.pair, elapsed: j.elapsed }));
      dys.save()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })
  
  //////////////////////////////////////////
  // TestTap
  //////////////////////////////////////////
  app.get('/TestTap', (req, res) => {
    if (req.query.phone != null) {
      getUser(req.query.phone)
      .then(u => {
        TestTap.find({ userId: u._id })
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      })
      .catch(e => res.status(400).json(e));
    }
    else {
      TestTap.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  app.post('/TestTap/phone', (req, res) => {
    getUser(req.body.phone)
    .then(u => {
      var leftJson = JSON.parse(req.body.left);
      var rightJson = JSON.parse(req.body.right);
      const dys = new TestTap({
        userId: u._id,
        duration: req.body.duration,
        left: {
          count: leftJson.count,
          accuracy: leftJson.accuracy,
          duration: leftJson.duration,
        },
        right: {
          count: rightJson.count,
          accuracy: rightJson.accuracy,
          duration: rightJson.duration,
        },
        date: req.body.date });
      leftJson.times.forEach(j => dys.left.times.push(j));
      rightJson.times.forEach(j => dys.right.times.push(j));
      dys.save()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    })
    .catch(e => res.status(400).json(e));
  })
  
  //////////////////////////////////////////
  // TestVoice
  //////////////////////////////////////////
  var voiceUpload = multer({ dest: 'public/voice' })
  app.post('/TestVoice/phone', voiceUpload.single("file"), function (req,res) {
    getUser(req.query.phone)
    .then(u => {
      var src = fs.createReadStream(req.file.path);
      var dest = fs.createWriteStream('public/voice/' + req.file.originalname);
      src.pipe(dest);
      src.on('end', function() {
        fs.unlinkSync(req.file.path);
        const dys = new TestVoice({
          userId: u._id,
          fileName: req.file.originalname,
          questionnaire: req.body.questionnaire,
          date: req.body.date });
        dys.save()
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      });
      src.on('error', function(err) { res.sendStatus(400).json('Error uploading file.'); });
    })
    .catch(e => res.status(400).json(e));
  })

  app.get('/TestVoice', (req, res) => {
    if (req.query.phone != null) {
      getUser(req.query.phone)
      .then(u => {
        TestVoice.find({ userId: u._id })
        .then(r => res.status(200).json(r))
        .catch(e => res.status(400).json(e));
      })
      .catch(e => res.status(400).json(e));
    }
    else {
      TestVoice.find()
      .then(r => res.status(200).json(r))
      .catch(e => res.status(400).json(e));
    }
  })

  //////////////////////////////////////////
  // Server start
  //////////////////////////////////////////
  const privateKey  = fs.readFileSync(__dirname + '/key.pem', 'utf8');
  const certificate = fs.readFileSync(__dirname + '/cert.pem', 'utf8');
  const credentials = { key: privateKey, cert: certificate, passphrase: process.env.CERT_PASSWORD };

  http.createServer(app).listen(3000, () => { console.log("HTTP server running on port 3000."); });
  https.createServer(credentials, app).listen(3001, () => { console.log("HTTPS server running on port 3001."); });
})

db.on('error', err => { console.error('Error: ', err) })