defmodule DataDrivenMicroscopy.Accounts.TeamJoinedUser do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  alias DataDrivenMicroscopy.Accounts
  alias DataDrivenMicroscopy.Accounts.RequirePasswordConfirmation

  postgres do
    repo(DataDrivenMicroscopy.Repo)
    table("team_joined_users")
  end

  actions do
    defaults [:read, :update, :destroy]

    read :get_by_team_and_user do
      get? true
      argument :team_id, :string, allow_nil?: false
      argument :user_id, :string, allow_nil?: false

      filter expr(team_id == ^arg(:team_id) and user_id == ^arg(:user_id))
    end

    create :create do
      primary? true
      upsert? true
      upsert_identity :unique_team_joined
    end

    destroy :destroy_with_password do
      argument :current_password, :string do
        allow_nil? false
      end

      change {RequirePasswordConfirmation, password: :current_password}
    end
  end

  code_interface do
    define_for Accounts
    define :get_by_team_and_user, action: :get_by_team_and_user, get?: true, args: [:team_id, :user_id]
  end

  attributes do
    uuid_primary_key :id
    timestamps()
  end

  relationships do
    belongs_to :user, DataDrivenMicroscopy.Accounts.User do
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :team, DataDrivenMicroscopy.Accounts.Team do
      attribute_writable? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_team_joined, [:user_id, :team_id]
  end
end
