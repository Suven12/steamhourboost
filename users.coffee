jf = require 'jsonfile'
chalk = require 'chalk'
inquirer = require 'inquirer'
Steam = require 'steam'

POSSIBLE_GAMES = [
  {name: 'PayDay2', value: '218620', checked: true}
  {name: 'Rocket League', value: '252950', checked: true}
  {name: 'CS GO', value: '730', checked: true}
  {name: 'SaintsRowThird', value: '55230', checked: true}
  {name: 'Sam3BFE', value: '41070', checked: true}
  {name: 'WolfenNewORder', value: '201810', checked: true}
  {name: 'h1z1', value: '295110', checked: true}
  {name: 'h1z1Serv', value: '362300', checked: true}
  {name: 'Postal2', value: '223470', checked: true}
  {name: 'DontStarve', value: '219740', checked: true}
  {name: 'CallOfDutyBO3', value: '311210', checked: true}
  {name: 'WhySoEvil', value: '331710', checked: true}
  {name: 'WhySoEvil2', value: '354850', checked: true}
  {name: 'WarThunder', value: '236390', checked: true}
  {name: 'GridAutosport', value: '255220', checked: true}
  {name: 'Nux', value: '307350', checked: true}
  {name: 'Dota 2', value: '570'}
]

account = null

class SteamAccount
  accountName: null
  password: null
  authCode: null
  shaSentryfile: null
  games: []

  constructor: (@accountName, @password, @games) ->
    @steamClient = new Steam.SteamClient
    @steamClient.on 'loggedOn', @onLogin
    @steamClient.on 'sentry', @onSentry
    @steamClient.on 'error', @onError

  testLogin: (authCode=null) =>
    @steamClient.logOn
      accountName: @accountName,
      password: @password,
      authCode: authCode,
      shaSentryfile: @shaSentryfile

  onSentry: (sentryHash) =>
    @shaSentryfile = sentryHash.toString('base64')

  onLogin: =>
    console.log(chalk.green.bold('✔ ') + chalk.white("Sucessfully logged into '#{@accountName}'"))
    setTimeout =>
      database.push {@accountName, @password, @games, @shaSentryfile}
      jf.writeFileSync('db.json', database)
      process.exit(0)
    , 1500

  onError: (e) =>
    if e.eresult == Steam.EResult.InvalidPassword
      console.log(chalk.bold.red("X ") + chalk.white("Logon failed for account '#{@accountName}' - invalid password"))
    else if e.eresult == Steam.EResult.AlreadyLoggedInElsewhere
      console.log(chalk.bold.red("X ") + chalk.white("Logon failed for account '#{@accountName}' - already logged in elsewhere"))
    else if e.eresult == Steam.EResult.AccountLogonDenied
      query = {type: 'input', name: 'steamguard', message: 'Please enter steamguard code: '}
      inquirer.prompt query, ({steamguard}) =>
        @testLogin(steamguard)

# Load database
try
  database = jf.readFileSync('db.json')
catch e
  database = []

query = [
  {type: 'input', name: 'u_name', message: 'Enter login name: '}
  {type: 'password', name: 'u_password', message: 'Enter password: '}
  {type: 'checkbox', name: 'u_games', message: 'Please select games to be boosted: ', choices: POSSIBLE_GAMES}
]

inquirer.prompt query, (answers) ->
  account = new SteamAccount(answers.u_name, answers.u_password, answers.u_games)
  account.testLogin()
