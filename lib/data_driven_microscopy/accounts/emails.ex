defmodule DataDrivenMicroscopy.Accounts.Emails do
  @moduledoc """
  Delivers emails.
  """

  import Swoosh.Email

  def deliver_confirmation_instructions(user, url) do
    if !url do
      raise "Cannot deliver confirmation instructions without a url"
    end

    deliver(user.email, "Confirm Your Email", """
    <html>
      <p>
        Hi #{user.email},
      </p>

      <p>
        <a href="#{url}">Click here</a> to confirm your account
      </p>

      <p>
        If you didn't create an account with us, please ignore this.
      </p>
    </html>
    """)
  end

  def deliver_reset_password_instructions(user, url) do
    if !url do
      raise "Cannot deliver reset instructions without a url"
    end

    deliver(user.email, "Reset Your Password", """
    <html>
      <p>
        Hi #{user.email},
      </p>

      <p>
        <a href="#{url}">Click here</a> to reset your password.
      </p>

      <p>
        If you didn't request this change, please ignore this.
      </p>
    <html>
    """)
  end

  # not implemented
  def deliver_update_email_instructions(user, url) do
    if !url do
      raise "Cannot deliver update email instructions without a url"
    end

    deliver(user.email, "Confirm Your Email Change", """
    <html>
      <p>
        Hi #{user.email},
      </p>

      <p>
        <a href="#{url}">Click here</a> to confirm your new email.
      </p>

      <p>
        If you haven't created an account with us, please ignore this.
      </p>
    </html>
    """)
  end

  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  defp deliver(to, subject, body) do
    new()
    |> from({"Data Driven Admin", "admin@admin.com"})
    |> to(to_string(to))
    |> subject(subject)
    |> put_provider_option(:track_links, "None")
    |> html_body(body)
    |> DataDrivenMicroscopy.Mailer.deliver()
  end
end
