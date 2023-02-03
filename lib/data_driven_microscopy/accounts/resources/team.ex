defmodule DataDrivenMicroscopy.Accounts.Team do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    repo(DataDrivenMicroscopy.Repo)
    table("teams")
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
    timestamps()
  end

  relationships do
    many_to_many :users, DataDrivenMicroscopy.Accounts.User do
      through DataDrivenMicroscopy.Accounts.TeamJoinedUser
      source_attribute_on_join_resource :team_id
      destination_attribute_on_join_resource :user_id
    end
  end
end
