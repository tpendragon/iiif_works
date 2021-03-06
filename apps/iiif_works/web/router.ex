defmodule IiifWorks.Router do
  use IiifWorks.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IiifWorks do
    pipe_through :api
    get "/*id", ManifestController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", IiifWorks do
  #   pipe_through :api
  # end
end
