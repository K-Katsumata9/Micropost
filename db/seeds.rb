User.create!(name:  "Koki Katsumata",
             email: "sample@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true)

99.times do |n|
    User.create!(
        name: Faker::Name.unique.name,
        email: "sample#{n+1}@gmail.com",
        password: "foobar",
        password_confirmation: "foobar"
    )
end