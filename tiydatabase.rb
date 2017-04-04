require 'sinatra'
require 'pg'

require 'sinatra/reloader' if development?

get '/' do
  erb :home
end

get '/employees' do
  database = PG.connect(dbname: "tiy-database")
  @accounts = database.exec("select * from employees")

  erb :employees
end

get '/employee' do
  id = params["id"]
  database = PG.connect(dbname: "tiy-database")

  accounts = database.exec("select * from employees where id = $1", [id])

  @account = accounts.first

  erb :employee
end

get '/add_person' do
  erb :add_person
end

get '/create_employee' do
  name = params["name"]
  phone = params["phone"]
  address = params["address"]
  position = params["position"]
  salary = params["salary"]
  github = params["github"]
  slack = params["slack"]
  database = PG.connect(dbname: "tiy-database")
  @accounts = database.exec("INSERT INTO employees(name, phone, address, position, salary, github, slack) VALUES($1, $2, $3, $4, $5, $6, $7)", [name, phone, address, position, salary, github, slack])

 redirect to("/")
end

get '/search_person' do
  person_name = params["search"]
  slack = params["search"]
  github = params["search"]

  database = PG.connect(dbname: "tiy-database")
  @accounts = database.exec("select * from employees where name like '%#{person_name}%' or github= $1 or slack= $2", [github, slack])

  erb :search
end

get '/edit_person' do
  database = PG.connect(dbname: "tiy-database")

  id = params["id"]

  accounts = database.exec("select * from employees where id = $1", [id])

  @account = accounts.first

  erb :edit_person
end

get '/update' do
  id = params["id"]
  name = params["name"]
  phone = params["phone"]
  address = params["address"]
  position = params["position"]
  salary = params["salary"]
  github = params["github"]
  slack = params["slack"]
  database = PG.connect(dbname: "tiy-database")
  @accounts = database.exec("UPDATE employees SET name=$1, phone=$2, address=$3, position=$4, salary=$5, github=$6, slack=$7 WHERE id = $8", [name, phone, address, position, salary, github, slack, id])

  redirect to("/")
end

get '/delete_person' do
  database = PG.connect(dbname: "tiy-database")

  id = params["id"]

  account = database.exec("DELETE FROM employees WHERE id=$1", [id])

  redirect to("/employees")
end
