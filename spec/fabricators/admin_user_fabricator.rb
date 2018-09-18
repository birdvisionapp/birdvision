Fabricator(:admin_user) do
  username "admin"
  password "password"
  email "superadminuser@mailinator.com"
  role AdminUser::Roles::SUPER_ADMIN
end

Fabricator(:reseller_admin_user, :from => :admin_user) do
  username { sequence(:username) { |i| "reseller-#{i}" } }
  role AdminUser::Roles::RESELLER
end

Fabricator(:super_admin_user, :from => :admin_user) do
  username { sequence(:username) { |i| "super_admin-#{i}" } }
  role AdminUser::Roles::SUPER_ADMIN
end

Fabricator(:client_manager_admin_user, :from => :admin_user) do
  username { sequence(:username) { |i| "client_manager-#{i}" } }
  role AdminUser::Roles::CLIENT_MANAGER
end
