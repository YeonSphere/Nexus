defmodule Backend.Auth.Token do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tokens" do

    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [])
    |> validate_required([])
  end
end
