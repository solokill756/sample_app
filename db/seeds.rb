User.create!(
  name: "Example User",
  email: "hosithao1622004@gmail.com",
  password: "1234567",
  password_confirmation: "1234567",
  gender: "male",
  birthday: "2000-01-01",
  admin: true,
  activated: true,
  activated_at: Time.zone.now
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
    birthday: birthday,
    activated: true,
    activated_at: Time.zone.now
  )
end

user = User.order(:created_at).take(6)

30.times do
  content = Faker::Lorem.sentence(word_count: 5)
  user.each { |u| u.microposts.create!(content: content) }
end
