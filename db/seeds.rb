# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AdminUser.create!(email: 'admin@lendatweet.org', password: 'password')

Page.create!(title: 'embed-login', body: <<-ERB
<% if current_user %>
<a class="btn logout" data-lat-action="logout">Logout</a>
<% else %>
<a class="btn btn--tw login" data-lat-action="login">Login</a>
<% end %>
ERB
, domains: ['http://localhost:5000'])