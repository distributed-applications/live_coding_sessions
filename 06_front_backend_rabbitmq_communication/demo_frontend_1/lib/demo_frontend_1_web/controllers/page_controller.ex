defmodule DemoFrontend1Web.PageController do
  use DemoFrontend1Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def logs_short(conn, _) do
    data = DemoFrontend1.LogDatabase.get_logs(:short) |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> text(data)
  end

  def logs_full(conn, _) do
    data = DemoFrontend1.LogDatabase.get_logs(:all) |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> text(data)
  end

  def create_can(conn, %{"can_id" => can_id}) do
    unique_tag = DemoFrontend1.GarbageCanPublisher.create_can(can_id)

    text(
      conn,
      "requested with tag #{unique_tag}, normally you should go to a loading page or have some javascript handle this..."
    )
  end
end
