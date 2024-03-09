User.create!(name:  "Koki Katsumata",
             email: "sample@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
    User.create!(
        name: Faker::Name.unique.name,
        email: "sample#{n+1}@gmail.com",
        password: "foobar",
        password_confirmation: "foobar",
        activated: true,
        activated_at: Time.zone.now)
end
# ユーザーの一部を対象にマイクロポストを生成する
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.posts.create!(content: content) }
end