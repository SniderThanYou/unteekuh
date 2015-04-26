Fabricator(:erik, from: :user) do
  password { 'password' }
  password_confirmation { 'password' }
  email { 'erik@unteekuh.com' }
end

Fabricator(:chris, from: :user) do
  password { 'password' }
  password_confirmation { 'password' }
  email { 'chris@unteekuh.com' }
end

Fabricator(:greg, from: :user) do
  password { 'password' }
  password_confirmation { 'password' }
  email { 'greg@unteekuh.com' }
end

Fabricator(:jason, from: :user) do
  password { 'password' }
  password_confirmation { 'password' }
  email { 'jason@unteekuh.com' }
end
