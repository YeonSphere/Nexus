defmodule BackendWeb.ProductController do
  use Phoenix.Controller  # Use Phoenix.Controller directly

  alias Backend.Catalog  # Keep this alias if you are using Catalog functions

  def index(conn, _params) do
    products = Catalog.list_products()
    json(conn, products)  # Return JSON response
  end

  def show(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)
    json(conn, product)  # Return JSON response
  end

  def create(conn, %{"product" => product_params}) do
    case Catalog.create_product(product_params) do
      {:ok, product} ->
        conn
        |> put_status(:created)
        |> json(product)  # Return created product as JSON

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(changeset)  # Return errors as JSON
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Catalog.get_product!(id)

    case Catalog.update_product(product, product_params) do
      {:ok, product} ->
        json(conn, product)  # Return updated product as JSON

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(changeset)  # Return errors as JSON
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)
    {:ok, _product} = Catalog.delete_product(product)

    conn
    |> put_status(:no_content)
    |> send_resp(:no_content, "")  # Return 204 No Content
  end
end