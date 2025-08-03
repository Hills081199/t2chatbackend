defmodule T2chatbackendWeb.Router do
  use T2chatbackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", T2chatbackendWeb do
    pipe_through :api
    post "register", AuthController, :register
    post "/login", AuthController, :login
    post "/logout", AuthController, :logout
    post "/refresh", AuthController, :refresh
    get "/me", AuthController, :me
    get "/verify", AuthController, :verify_token
  end

  scope "/api", T2chatbackendWeb do
    pipe_through [:api, T2chatbackendWeb.AuthPlug]

    # get "/me", UserController, :me
    # get "/users", UserController, :index
    # put "/users", UserController, :update
    # delete "/users", UserController, :delete
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:t2chatbackend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: T2chatbackendWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
