CURRENTDIR=${pwd}

# Get project path
echo "what is the absolute path to your local project directory?"
read PROJECT_PATH

# go to path
cd "$PROJECT_PATH"

### Backend setup

#install dependencies
npm init -y
npm install express
npm install body-parser cors dotenv
npm install sequelize pg
npm install --save-dev sequelize-cli
npm install nodemon -D
npm install morgan
npm install multer
npm install nodemailer
npm install aws-sdk

# basic file setup
mkdir config controllers middleware models routes
touch server.js .gitignore routes/AppRouter.js config/config.js

# server setup
echo "const path = require('path')
const express = require('express')
const app = express()
const bodyParser = require('body-parser');
const cors = require('cors');
const AppRouter = require('./routes/AppRouter');

const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'client', 'build')))

app.use('/api', AppRouter);
app.get('*', (req, res) =>
  res.sendFile(path.join(__dirname, 'client', 'build', 'index.html'))
)
app.listen(PORT, () => console.log(\`Server Started On Port: \${PORT}\`));
" >> server.js

echo "require('dotenv').config()

module.exports = {
  development: {
   database: 'development',
    dialect: 'postgres'
  },
  test: {
    database: 'test',
    dialect: 'postgres'
  },
  production: {
    username: process.env.RDS_USERNAME,
    password: process.env.RDS_PASSWORD,
    database: process.env.RDS_DB_NAME,
    host: process.env.RDS_HOSTNAME,
    dialect: 'postgres'
  }
}" >> config/config.js

echo "const Router = require('express').Router()
Router.get('/', (req, res) => res.send('This is root!*'))
module.exports = Router" >> routes/AppRouter.js

# Auth middleware
echo "const jwt = require('jsonwebtoken')
require('dotenv').config()

const secretKey = process.env.SECRET_KEY

const getToken = (request, response, next) => {
    const token = request.headers['authorization'].split(' ')[1]
    response.locals.token = token
    next()
}

const verifyToken = (request, response, next) => {
    let token = response.locals.token
    jwt.verify(token, secretKey, (err, t) => {
        if (err) {
            return response.status(401).json({ msg: 'unauthorized' })
        }
        return next()
    })
}

const createToken = (request, response) => {
    const token = jwt.sign(response.locals.payload, secretKey)
    response.send({ user: response.locals.payload, token })
}

module.exports = {
    createToken,
    verifyToken,
    getToken
}" >> JwtHandler.js

# .gitignore
echo "
.env
client/.eslintcache
node_modules/
package-lock.json" >> .gitignore

### Front End Setup

#create react app
npx create-react-app client

cd client/src

mkdir components pages styles assets
rm -rf setupTests.js reportWebVitals.js logo.svg index.css App.test.js App.css

echo "import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);
" > index.js

echo "
function App() {
  return <div className='App'>It's alive! 🧟‍♂️</div>;
}
export default App;
" > App.js