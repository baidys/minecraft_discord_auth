defmodule AuthBackendWeb.AuthHTML do
  alias AuthBackendWeb.Elements
  use AuthBackendWeb, :html

  def success(assigns) do
    ~H"""
    <Elements.navbar/>
    <div class="h-screen content-center w-full">
      <div class="text-center px-4">
        <h1 class="scroll-m-20 text-4xl font-extrabold tracking-tight text-balance">
          Authentication successful ✅
        </h1>
        <p class="mt-8 leading-7 [&:not(:first-child)]:mt-6 lg:px-[30%]">
          {@message}, you can go back to the game
        </p>
      </div>
    </div>
    """
  end

  def error(assigns) do
    ~H"""
    <Elements.navbar/>
    <div class="h-screen content-center w-full">
      <div class="text-center px-4">
        <h1 class="scroll-m-20 text-4xl font-extrabold tracking-tight text-balance">
          Authentication failed ❌
        </h1>
        <p class="mt-8 leading-7 [&:not(:first-child)]:mt-6 lg:px-[30%]">
          {@error}
        </p>
      </div>
    </div>    
    """
  end

 end
