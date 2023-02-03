# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DataDrivenMicroscopy.Repo.insert!(%DataDrivenMicroscopy.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

attributes = %{"name" => "Admin",
              "email" => "admin@admin.com",
              "hashed_password" => "$2b$12$C8CXHQVWSZKzcZuiJZhynO7sTbwVchsG7v.IqUfby/atnOSaeqdgO",
              "is_admin" => true
            }



DataDrivenMicroscopy.Accounts.User
  |> Ash.Changeset.for_create(:create, attributes)
  |> DataDrivenMicroscopy.Accounts.create!()
