defmodule Nexus.PasswordManager do
  use GenServer
  require Logger
  
  @encryption_key System.get_env("PASSWORD_ENCRYPTION_KEY")

  defmodule Credential do
    defstruct [:id, :domain, :username, :password, :notes, :last_used, created_at: DateTime.utc_now()]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{credentials: load_credentials() || %{}}}
  end

  def handle_call({:save_credential, params}, _from, state) do
    credential = %Credential{
      id: generate_id(),
      domain: params.domain,
      username: params.username,
      password: encrypt(params.password),
      notes: params.notes
    }
    
    new_state = put_in(state.credentials[credential.id], credential)
    save_credentials(new_state.credentials)
    
    {:reply, {:ok, credential}, new_state}
  end

  def handle_call({:get_credentials, domain}, _from, state) do
    credentials = Enum.filter(state.credentials, fn {_id, cred} -> 
      cred.domain == domain
    end)
    {:reply, credentials, state}
  end

  defp encrypt(password) do
    # Implement proper encryption using @encryption_key
    Base.encode64(password)
  end

  defp decrypt(encrypted) do
    # Implement proper decryption using @encryption_key
    Base.decode64!(encrypted)
  end

  defp generate_id, do: :crypto.strong_rand_bytes(16) |> Base.encode16()

  defp load_credentials do
    case File.read("credentials.enc") do
      {:ok, content} -> 
        content 
        |> decrypt()
        |> Jason.decode!()
      {:error, _} -> nil
    end
  end

  defp save_credentials(credentials) do
    credentials
    |> Jason.encode!()
    |> encrypt()
    |> then(&File.write!("credentials.enc", &1))
  end
end
