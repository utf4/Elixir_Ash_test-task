defmodule DataDrivenMicroscopy.Senders.SendPasswordResetEmail do
    use AshAuthentication.Sender

    def send(user, reset_token, _opts) do
      DataDrivenMicroscopy.Accounts.Emails.deliver_reset_password_instructions(user, "/users/reset_password/#{reset_token}")
    end
  end
