defmodule AuthBackendWeb.Router do
  use AuthBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AuthBackendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/players", AuthBackendWeb do
    pipe_through :api

    post "/create", ApiController, :create
    get "/logged", ApiController, :logged
    get "/templog", ApiController, :templog
    get "/show", ApiController, :show
    post "/edit", ApiController, :edit
    get "/resetip", ApiController, :reset_ip
    delete "/", ApiController, :delete
  end

  scope "/auth", AuthBackendWeb do
    pipe_through :browser

    get "/", AuthController, :login
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", AuthBackendWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:auth_backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AuthBackendWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
