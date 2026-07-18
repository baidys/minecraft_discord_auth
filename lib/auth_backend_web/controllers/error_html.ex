defmodule AuthBackendWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  alias AuthBackendWeb.Elements
  use AuthBackendWeb, :html

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/auth_backend_web/controllers/error_html/404.html.heex
  #   * lib/auth_backend_web/controllers/error_html/500.html.heex
  #
  # embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".

  def render("404.html", assigns) do
    ~H"""
    <.error message="Page not found" status={@status}/>
    """
  end

  def render("500.html", assigns) do
    ~H"""
    <.error message="Server error" status={@status}/>
    """
  end

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def error(assigns) do
    assigns =
      assign(assigns, :content, 
        ~H"""
        <Elements.navbar />
        <div class="h-screen content-center w-full">
          <div class="text-center px-4">
            <h1 class="scroll-m-20 text-4xl font-extrabold tracking-tight text-balance">
              {@status}
            </h1>
            <p class="mt-8 leading-7 [&:not(:first-child)]:mt-6 lg:px-[30%]">
              {@message}
            </p>
          </div>
        </div>    
        """ 
      )

    ~H"""
     <Layouts.root inner_content={@content} /> 
    """
  end
end
