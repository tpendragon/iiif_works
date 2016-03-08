defmodule IiifWorks.PageController do
  use IiifWorks.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
