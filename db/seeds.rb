User.create!(
  name: "Example User",
  email: "hosithao1622004@gmail.com",
  password: "1234567",
  password_confirmation: "1234567",
  gender: "male",
  birthday: "2000-01-01",
  admin: true
)

30.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  gender = ["male", "female", "other"].sample
  birthday = Faker::Date.birthday(min_age: 18, max_age: 65)
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    gender: gender,
    birthday: birthday
  )
end
