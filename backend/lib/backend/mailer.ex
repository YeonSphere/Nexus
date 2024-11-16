defmodule Backend.Mailer do
  use Swoosh.Mailer, otp_app: :backend

  @doc """
  Send an email with custom result handling.
  """
  @spec send_email(Swoosh.Email.t()) :: {:ok, String.t()} | {:error, String.t()}
  def send_email(email) do
    email
    |> deliver()
    |> handle_delivery_result()
  end

  @doc """
  Send an email asynchronously.
  """
  @spec deliver_later(Swoosh.Email.t()) :: {:ok, String.t()} | {:error, String.t()}
  def deliver_later(email) do
    Task.start(fn ->
      email
      |> deliver()
      |> handle_delivery_result()
    end)

    {:ok, "Email scheduled for delivery"}
  end

  defp handle_delivery_result({:ok, _metadata}), do: {:ok, "Email sent successfully"}
  defp handle_delivery_result({:error, term}), do: {:error, Exception.message(term)}
end
