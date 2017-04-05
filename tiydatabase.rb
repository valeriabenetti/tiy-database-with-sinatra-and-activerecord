require 'sinatra'
require 'pg'
require 'sinatra/reloader' if development?

class Employee
  # Saving the correct data into class
  attr_reader 'id', 'name', 'phone', 'address', 'position', 'salary', 'slack', 'github'
  # Defining name, phone, address, position, salary,slack, github
  def initialize(account)
    @id = account["id"]
    @name = account["name"]
    @phone = account["phone"]
    @address = account["address"]
    @position = account["position"]
    @salary = account["salary"]
    @slack = account["slack"]
    @github = account["github"]
  end

  def self.create(params)
    database = PG.connect(dbname: "tiy-database")

    name = params["name"]
    phone = params["phone"]
    address = params["address"]
    position = params["position"]
    salary = params["salary"]
    github = params["github"]
    slack = params["slack"]
    @accounts = database.exec("INSERT INTO employees(name, phone, address, position, salary, github, slack) VALUES($1, $2, $3, $4, $5, $6, $7)", [name, phone, address, position, salary, github, slack])

  end

  def self.all
    database = PG.connect(dbname: "tiy-database")

    return database.exec("select * from employees").map { |account| Employee.new(account) }
  end

  def self.find(id)
    database = PG.connect(dbname: "tiy-database")

    accounts = database.exec("select * from employees where id = $1", [id]).map { |account| Employee.new(account) }

    return accounts.first
  end

  def self.search(text)
    database = PG.connect(dbname: "tiy-database")

    return database.exec("select * from employees where name like $1 or github= $2 or slack= $2", ["%#{text}%", text]).map { |account| Employee.new(account) }

  end
end

get '/' do
  erb :home
end

get '/employees' do
  @accounts = Employee.all

  erb :employees
end

get '/employee' do
  @account = Employee.find(params["id"])
  if @account
    erb :employee
  else
    erb :no_employee_in_database
  end
end

get '/add_person' do
  erb :add_person
end

get '/create_employee' do
  Employee.create(params)

  redirect to("/")
end

get '/search_person' do
  search = params["search"]
  @accounts = Employee.search(search)

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
  @accounts = database.exec("UPDATE employees SET name=$1, phone=$2, address=$3, position=$4, salary=$5, github=$6, slack=$7 WHERE id = $8", [name, phone, address, position, salary, github, slack, id])
  database = PG.connect(dbname: "tiy-database")

  redirect to("/")
end

get '/delete_person' do
  database = PG.connect(dbname: "tiy-database")

  id = params["id"]

  account = database.exec("DELETE FROM employees WHERE id=$1", [id])

  redirect to("/employees")
end
