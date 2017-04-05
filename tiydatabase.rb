require 'sinatra'
require 'pg'
require 'sinatra/reloader' if development?
require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "tiy-database"
)
class Employee < ActiveRecord::Base
  validates :name, presence: true, length: { minimum: 3 }
  validates :position, inclusion: { in: %w{Instructor Student}, message: "%{value} must be Instructor or Student" }
  self.primary_key = "id"
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
  @account = Employee.new
  erb :add_person
end

get '/create_employee' do
  @account = Employee.create(params)
  if @account.valid?
    redirect to("/")
  else
    erb :add_person
  end
end

get '/search_person' do
  search = params["search"]

  @accounts = Employee.where("name like $1 or github = $2 or slack = $2", "#{search}", search)

  erb :search
end

get '/edit_person' do
  database = PG.connect(dbname: "tiy-database")

  @account = Employee.find(params["id"])

  erb :edit_person
end

get '/update' do
  database = PG.connect(dbname: "tiy-database")

  @account = Employee.find(params["id"])

  @account.update_attributes(params)
  if @account. valid?
    redirect to ("/employee?id=#{@account.id}")
  else
    erb :edit_person
  end
end

get '/delete_person' do
  database = PG.connect(dbname: "tiy-database")

  @account = Employee.find(params["id"])

  @account.destroy

  redirect to("/employees")
end
