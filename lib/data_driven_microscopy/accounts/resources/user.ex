defmodule DataDrivenMicroscopy.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication]

    alias DataDrivenMicroscopy.Accounts.RequirePasswordConfirmation

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    attribute :is_admin, :boolean, allow_nil?: false, default: false
    timestamps()
  end

  relationships do
    many_to_many :teams, DataDrivenMicroscopy.Accounts.Team do
      through DataDrivenMicroscopy.Accounts.TeamJoinedUser
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :team_id
    end
  end

  authentication do
    api DataDrivenMicroscopy.Accounts

    strategies do
      password :password do
        identity_field :email
        hashed_password_field :hashed_password

        resettable do
          sender DataDrivenMicroscopy.Senders.SendPasswordResetEmail
        end
      end
    end

    tokens do
      enabled? true
      token_resource DataDrivenMicroscopy.Accounts.Token
      signing_secret fn _, _ ->
        Application.fetch_env(:data_driven_microscopy, :token_signing_secret)
      end
      store_all_tokens? true
      require_token_presence_for_authentication? true
    end

    add_ons do
      confirmation :confirm do
        monitor_fields [:email]

        sender DataDrivenMicroscopy.Accounts.SendConfirmationEmail
      end
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    update :update_name do
      accept [:name]
    end

    update :change_password do
      accept []

      argument :current_password, :string do
        sensitive? true
        allow_nil? false
      end

      argument :password, :string do
        sensitive? true
        allow_nil? false
      end

      argument :password_confirmation, :string do
        sensitive? true
        allow_nil? false
      end

      change set_context(%{strategy_name: :password})

      validate confirm(:password, :password_confirmation)

      validate {AshAuthentication.Strategy.Password.PasswordValidation,
                strategy_name: :password, password_argument: :current_password} do
        only_when_valid? true
        before_action? true
      end

      change {RequirePasswordConfirmation, password: :current_password}
      change AshAuthentication.Strategy.Password.HashPasswordChange
    end

    update :update_email do
      accept [:email]

      argument :current_password, :string do
        sensitive? true
        allow_nil? false
      end

      change set_context(%{strategy_name: :password})

      validate {AshAuthentication.Strategy.Password.PasswordValidation,
                password_argument: :current_password} do
        only_when_valid? true
        before_action? true
      end
      change {RequirePasswordConfirmation, password: :current_password}
    end
  end

  postgres do
    table "users"
    repo DataDrivenMicroscopy.Repo
  end

  identities do
    identity :unique_email, [:email] do
      eager_check_with DataDrivenMicroscopy.Accounts
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:update_email) do
      description "A logged in user can update their email"
      authorize_if expr(id == ^actor(:id))
    end
    
    policy action(:resend_confirmation_instructions) do
      description "A logged in user can request an email confirmation"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:change_password) do
      description "A logged in user can reset their password"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:update_name) do
      description "A logged in user can update their name"
      authorize_if expr(id == ^actor(:id))
    end
  end
end
