Fabricator(:valid_user, from: :user) do
  password { 'password' }
  password_confirmation { 'password' }
  email { 'me@unteekuh.com' }
end
